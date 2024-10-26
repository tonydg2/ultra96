/******************************************************************************
* Copyright (C) 2017 - 2022 Xilinx, Inc.  All rights reserved.
* Copyright (C) 2022 - 2023 Advanced Micro Devices, Inc.  All rights reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/

/*****************************************************************************/
/**
 *
 * @file xmcdma_polled_example.c
 *
 * This file demonstrates how to use the mcdma driver on the Xilinx AXI
 * MCDMA core (AXI MCDMA) to transfer packets in polling mode.
 *
 * This examples shows how to do multiple packets and multiple BD's
 * per packet transfers.
 *
 * H/W Requirements:
 * In order to test this example at the h/w level AXI MCDMA MM2S should
 * be connected to the S2MM channel.
 *
 * System level considerations for Zynq UltraScale+ designs:
 * On ZU+ MPSOC for PL IP's 3 different ports are available HP, HPC and ACP.
 *
 * The explanation below talks about HPC and HP port.
 *
 * HPC design considerations:
 * ZU+ MPSOC has in-built cache coherent interconnect(CCI) to take care of
 * Coherency through HPC port. CCI is only support at EL1 NS level.
 * Following needs to be done by the system components before running the
 * example-
 * 1) Snooping should be enabled in the S3 (0xFD6E4000)
 * 2) Mark the DDR memory being used for buffers as outer-shareable.
 * translation_table.S.
 * .set Memory,	0x405 | (2 << 8) | (0x0).
 *
 * It is recommended to use HPC to make use of H/W coherency feature.
 *
 * HP design considerations:
 * The example uses un-cached memory for buffer descriptors and uses
 * Normal memory for buffers..
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date       Changes
 * ----- ---- --------   -------------------------------------------------------
 * 1.0	 adk  18/07/2017 Initial Version.
 * 1.2	 rsp  07/19/2018 Read channel count from IP config.
 *       rsp  08/17/2018 Fix typos and rephrase comments.
 *	 rsp  08/17/2018 Read Length register value from IP config.
 * 1.3   rsp  02/05/2019 Remove snooping enable from application.
 *       rsp  02/06/2019 Programmatically select cache maintenance ops for HPC
 *                       and non-HPC designs. In Rx remove arch64 specific dsb
 *                       instruction by performing cache invalidate operation
 *                       for all supported architectures.
 * 1.7   sa   08/12/22  Updated the example to use latest MIG cannoical define
 * 		        i.e XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR.
 * 1.8   sa   09/29/22  Fix infinite loops in the example.
 * 1.9	 aj   07/19/23   Updated the example to support the system device tree
 * 			 flow
 * </pre>
 *
 * ***************************************************************************
 */
/***************************** Include Files *********************************/

#include "xmcdma.h"
#include "xparameters.h"
#include "xdebug.h"
#include "xmcdma_hw.h"
#include "sleep.h"
#include "helpFunctions.h"

#ifdef __aarch64__
#include "xil_mmu.h"
#endif


/******************** Constant Definitions **********************************/

/*
 * Device hardware build related constants.
 */

/*
#ifndef SDT
    #define MCDMA_DEV_ID	XPAR_MCDMA_0_DEVICE_ID

    #ifdef  XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
    #define DDR_BASE_ADDR		XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
    #elif   XPAR_MIG7SERIES_0_BASEADDR
    #define DDR_BASE_ADDR	XPAR_MIG7SERIES_0_BASEADDR
    #elif   XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR
    #define DDR_BASE_ADDR	XPAR_MIG_0_C0_DDR4_MEMORY_MAP_BASEADDR
    #elif   XPAR_PSU_DDR_0_S_AXI_BASEADDR
    #define DDR_BASE_ADDR	XPAR_PSU_DDR_0_S_AXI_BASEADDR
    #endif

    #ifdef  XPAR_PSU_DDR_0_S_AXI_BASEADDR
    #define DDR_BASE_ADDR	XPAR_PSU_DDR_0_S_AXI_BASEADDR
    #endif

    #ifdef  XPAR_PSU_R5_DDR_0_S_AXI_BASEADDR
    #define DDR_BASE_ADDR	XPAR_PSU_R5_DDR_0_S_AXI_BASEADDR
    #endif

#else

    #ifdef  XPAR_MEM0_BASEADDRESS
    #define DDR_BASE_ADDR		XPAR_MEM0_BASEADDRESS
    #endif
    #define MCDMA_BASE_ADDR		XPAR_XMCDMA_0_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
    #warning "CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, DEFAULT SET TO 0x01000000"
    #define MEM_BASE_ADDR		0x01000000
#else
    #define MEM_BASE_ADDR		(DDR_BASE_ADDR + 0x10000000)
#endif
*/

#define MCDMA_BASE_ADDR		XPAR_XMCDMA_0_BASEADDR

#define MEM_BASE_ADDR		0xC0000000
#define SG_BASE_ADDR        0xA0010000

#define TX_BD_SPACE_BASE	(SG_BASE_ADDR)
#define RX_BD_SPACE_BASE	(SG_BASE_ADDR + 0x1000)

#define TX_BUFFER_BASE		(MEM_BASE_ADDR)
//#define RX_BUFFER_BASE		(MEM_BASE_ADDR + 0x4000)
#define RX_BUFFER_BASE		(MEM_BASE_ADDR)


#define NUMBER_OF_BDS_PER_PKT		1
#define NUMBER_OF_PKTS_TO_TRANSFER 	2
#define NUMBER_OF_BDS_TO_TRANSFER	(NUMBER_OF_PKTS_TO_TRANSFER * NUMBER_OF_BDS_PER_PKT)

#define MAX_PKT_LEN		256*4   // bytes
//#define BLOCK_SIZE_2MB 0x200000U

#define NUM_MAX_CHANNELS	16

#define POLL_TIMEOUT_COUNTER    1000000U

//int TxPattern[NUM_MAX_CHANNELS + 1];
//int RxPattern[NUM_MAX_CHANNELS + 1];
//int TestStartValue[] = {0xC, 0xB, 0x3, 0x55, 0x33, 0x20, 0x80, 0x66, 0x88};

/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/
static int RxSetup(XMcdma *McDmaInstPtr);
static int TxSetup(XMcdma *McDmaInstPtr);

/************************** Variable Definitions *****************************/
/*
 * Device instance definitions
 */
XMcdma AxiMcdma;

volatile int TxDone;
volatile int RxDone;
//int num_channels;
u32 num_channels;

/*
 * Buffer for transmit packet. Must be 32-bit aligned to be used by DMA.
 */
UINTPTR *Packet = (UINTPTR *) TX_BUFFER_BASE;

/*****************************************************************************/
/**
*
* Main function
*
* This function is the main entry of the tests on DMA core. It sets up
* DMA engine to be ready to receive and send packets, then a packet is
* transmitted and will be verified after it is received via the DMA.
*
* @param	None
*
* @return
*		- XST_SUCCESS if test passes
*		- XST_FAILURE if test fails.
*
* @note		None.
*
******************************************************************************/
int main(void)
{
	int Status;
    //int i;

	TxDone = 0;
	RxDone = 0;

	XMcdma_Config *Mcdma_Config;
	int TimeOut = POLL_TIMEOUT_COUNTER;
    
    versionCtrl0();
	xil_printf("\r\n--- Entering main() --- \r\n");

#ifdef __aarch64__
    /*#if (TX_BD_SPACE_BASE < 0x100000000UL)
	    for (i = 0; i < (RX_BD_SPACE_BASE - TX_BD_SPACE_BASE) / BLOCK_SIZE_2MB; i++) {
		    Xil_SetTlbAttributes(TX_BD_SPACE_BASE + (i * BLOCK_SIZE_2MB), NORM_NONCACHE);
		    Xil_SetTlbAttributes(RX_BD_SPACE_BASE + (i * BLOCK_SIZE_2MB), NORM_NONCACHE);
	    }
    #else*/
	    Xil_SetTlbAttributes(TX_BD_SPACE_BASE, NORM_NONCACHE);
    //#endif
#endif



	Mcdma_Config = XMcdma_LookupConfig(MCDMA_BASE_ADDR);
	if (!Mcdma_Config) {
		xil_printf("No config found for %llx\r\n", MCDMA_BASE_ADDR);
		return XST_FAILURE;
	}


	Status = XMcDma_CfgInitialize(&AxiMcdma, Mcdma_Config);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}

	/* Read numbers of channels from IP config */
	num_channels = Mcdma_Config->RxNumChannels;
	

//while(1) {
	Status = RxSetup(&AxiMcdma);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


    Status = TxSetup(&AxiMcdma);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
//}

/*
    // adg
    while (TimeOut) {
		TimeOut--;
		usleep(1U);
	}

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
*/
	
    return XST_SUCCESS;

}

/*****************************************************************************/
/**
*
* This function sets up RX channel of the DMA engine to be ready for packet
* reception
*
* @param	McDmaInstPtr is the pointer to the instance of the AXI MCDMA engine.
*
* @return	XST_SUCCESS if the setup is successful, XST_FAILURE otherwise.
*
* @note		None.
*
******************************************************************************/
static int RxSetup(XMcdma *McDmaInstPtr)
{
	XMcdma_ChanCtrl *Rx_Chan;
	//int ChanId;
	u32 ChanId;
	int BdCount = NUMBER_OF_BDS_TO_TRANSFER;
	UINTPTR RxBufferPtr;
	UINTPTR RxBdSpacePtr;
	int Status;
	u32 i, j;
	u32 buf_align;

	RxBufferPtr = RX_BUFFER_BASE;
	RxBdSpacePtr = RX_BD_SPACE_BASE;

	for (ChanId = 1; ChanId <= num_channels; ChanId++) {
		Rx_Chan = XMcdma_GetMcdmaRxChan(McDmaInstPtr, ChanId);

		/* Disable all interrupts */
		XMcdma_IntrDisable(Rx_Chan, XMCDMA_IRQ_ALL_MASK);

		Status = XMcDma_ChanBdCreate(Rx_Chan, RxBdSpacePtr, BdCount);
		if (Status != XST_SUCCESS) {
			xil_printf("Rx bd create failed with %d\r\n", Status);
			return XST_FAILURE;
		}

		for (j = 0 ; j < NUMBER_OF_PKTS_TO_TRANSFER; j++) {
			for (i = 0 ; i < NUMBER_OF_BDS_PER_PKT; i++) {
				Status = XMcDma_ChanSubmit(Rx_Chan, RxBufferPtr, MAX_PKT_LEN);
				if (Status != XST_SUCCESS) {
					xil_printf("ChanSubmit failed\n\r");
					return XST_FAILURE;
				}

				/* Clear the receive buffer, so we can verify data */
				//memset((void *)RxBufferPtr, 0, MAX_PKT_LEN);                  // gets stuck here ADG

				if (!McDmaInstPtr->Config.IsRxCacheCoherent) {
					Xil_DCacheInvalidateRange(RxBufferPtr, MAX_PKT_LEN);
				}

				RxBufferPtr += MAX_PKT_LEN;
				if (!Rx_Chan->Has_Rxdre) {
					buf_align = RxBufferPtr % 64;
					if (buf_align > 0) {
						buf_align = 64 - buf_align;
					}
					RxBufferPtr += buf_align;
				}
			}
		}

		Status = XMcDma_ChanToHw(Rx_Chan);
		if (Status != XST_SUCCESS) {
			xil_printf("XMcDma_ChanToHw failed\n\r");
			return XST_FAILURE;
		}

		RxBufferPtr += MAX_PKT_LEN;
		if (!Rx_Chan->Has_Rxdre) {
			buf_align = RxBufferPtr % 64;
			if (buf_align > 0) {
				buf_align = 64 - buf_align;
			}
			RxBufferPtr += buf_align;
		}
		RxBdSpacePtr += BdCount * Rx_Chan->Separation;
		XMcdma_IntrEnable(Rx_Chan, XMCDMA_IRQ_ALL_MASK);
	}

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function sets up the TX channel of a DMA engine to be ready for packet
* transmission
*
* @param	McDmaInstPtr is the instance pointer to the AXI MCDMA engine.
*
* @return	XST_SUCCESS if the setup is successful, XST_FAILURE otherwise.
*
* @note		None.
*
******************************************************************************/
static int TxSetup(XMcdma *McDmaInstPtr)
{
	XMcdma_ChanCtrl *Tx_Chan;
	//int ChanId;
	u32 ChanId;
	int BdCount = NUMBER_OF_BDS_TO_TRANSFER;
	UINTPTR TxBufferPtr;
	UINTPTR TxBdSpacePtr;
	int Status;
	u32 i, j;
	u32 buf_align;

	TxBufferPtr = TX_BUFFER_BASE;
	TxBdSpacePtr = TX_BD_SPACE_BASE;

	for (ChanId = 1; ChanId <= num_channels; ChanId++) {
		Tx_Chan = XMcdma_GetMcdmaTxChan(McDmaInstPtr, ChanId);

		/* Disable all interrupts */
		XMcdma_IntrDisable(Tx_Chan, XMCDMA_IRQ_ALL_MASK);

		Status = XMcDma_ChanBdCreate(Tx_Chan, TxBdSpacePtr, BdCount);
		if (Status != XST_SUCCESS) {
			xil_printf("Tx bd create failed with %d\r\n", Status);
			return XST_FAILURE;
		}

		for (j = 0 ; j < NUMBER_OF_PKTS_TO_TRANSFER; j++) {
			for (i = 0 ; i < NUMBER_OF_BDS_PER_PKT; i++) {
				Status = XMcDma_ChanSubmit(Tx_Chan, TxBufferPtr, MAX_PKT_LEN);
				if (Status != XST_SUCCESS) {
					xil_printf("ChanSubmit failed\n\r");
					return XST_FAILURE;
				}

				TxBufferPtr += MAX_PKT_LEN;
				if (!Tx_Chan->Has_Txdre) {
					buf_align = TxBufferPtr % 64;
					if (buf_align > 0) {
						buf_align = 64 - buf_align;
					}
					TxBufferPtr += buf_align;
				}

				/* Clear the receive buffer, so we can verify data */
				//memset((void *)TxBufferPtr, 0, MAX_PKT_LEN);  // adg this gets stuck

			}
		}

		TxBufferPtr += MAX_PKT_LEN;
		if (!Tx_Chan->Has_Txdre) {
			buf_align = TxBufferPtr % 64;
			if (buf_align > 0) {
				buf_align = 64 - buf_align;
			}
			TxBufferPtr += buf_align;
		}

		TxBdSpacePtr += BdCount * Tx_Chan->Separation;
		XMcdma_IntrEnable(Tx_Chan, XMCDMA_IRQ_ALL_MASK);

		Status = XMcDma_ChanToHw(Tx_Chan);
		if (Status != XST_SUCCESS) {
			xil_printf("XMcDma_ChanToHw failed for Channel %d\n\r", ChanId);
			return XST_FAILURE;
		}

	}


	return XST_SUCCESS;
}


