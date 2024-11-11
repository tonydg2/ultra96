// !! ADG - ripped out all non-SDT stuff











/******************************************************************************
* Copyright (C) 2010 - 2022 Xilinx, Inc.  All rights reserved.
* Copyright (c) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/

/******************************************************************************/
/**
*
* @file xscugic_low_level_example.c
*
* This file contains a design example using the low level driver, interface
* of the Interrupt Controller driver.
*
* This example shows the use of the Interrupt Controller with the ARM
* processor.
*
* @note
*
* none
*
* <pre>
*
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- ---------------------------------------------------------
* 1.00a drg  01/30/10 First release
* 3.10  mus  09/19/18 Update prototype of LowInterruptHandler to fix the GCC
*                     warning
* 4.0   mus  01/28/19  Updated to support Cortexa72 GIC (GIC500).
* 5.0   adk  04/18/22 Replace infinite while loop with
* 		      Xil_WaitForEventSet() API.
*       adk  20/07/22 Update the Xil_WaitForEventSet() API arguments as
*      		      per latest API.
* 5.1   mus  02/15/23 Added support for VERSAL_NET.
* 5.2   dp   06/20/23 Make interrupt as Group1 interrupt for Cortex-R52.
* </pre>
******************************************************************************/

/***************************** Include Files *********************************/

#include <stdio.h>
#include "xparameters.h"
#include "xil_exception.h"
#include "xscugic_hw.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_util.h"
#include "helpFunctions.h"

/************************** Constant Definitions *****************************/

#define BD_REG32_ADDR XPAR_AXIL_REG32_0_BASEADDR


/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define CPU_BASEADDR		XPAR_GIC_A53_BASEADDR_1 //0xf9020000 // CPU see UG1087 GIC400 ADG
#define DIST_BASEADDR		XPAR_GIC_A53_BASEADDR   //0xf9010000 // Distributor see UG1087 GIC400 ADG

#define GIC_DEVICE_INT_MASK        0x02010003 /* Bit [25:24] Target list filter
                                                 Bit [23:16] 16 = Target CPU iface 0
                                                 Bit [3:0] identifies the SFI */
#define XSCUGIC_SW_TIMEOUT_VAL	10000000U /* Wait for 10 sec */
/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

static int ScuGicLowLevelExample(u32 CpuBaseAddress, u32 DistBaseAddress);

void SetupInterruptSystem();

void LowInterruptHandler(u32 CallbackRef);

static void GicDistInit(u32 BaseAddress);

static void GicCPUInit(u32 BaseAddress);


/************************** Variable Definitions *****************************/

/*
 * Create a shared variable to be used by the main thread of processing and
 * the interrupt processing
 */
volatile static u32 InterruptProcessed = FALSE;

/*****************************************************************************/
/**
*
* This is the main function for the Interrupt Controller Low Level example.
*
* @param	None.
*
* @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
int main(void)
{
	int Status;
    xil_printf("adg Test 0\r\n");
    versionCtrl0();

	/*
	 * Run the low level example of Interrupt Controller, specify the Base
	 * Address generated in xparameters.h
	 */
	xil_printf("Low Level GIC Example Test\r\n");
	Status = ScuGicLowLevelExample(CPU_BASEADDR, DIST_BASEADDR);
	if (Status != XST_SUCCESS) {
		xil_printf("Low Level GIC Example Test Failed\r\n");
		return XST_FAILURE;
	}
    
    
    s8 Ch;
    while (1) {
      Ch = inbyte();
      if (Ch == '\r') {
          outbyte('\n');
      }
      outbyte(Ch);
      xil_printf("\r\n");

      if (Ch == 'p') {
        xil_printf("\r\n POWER OFF");
        powerOff();
        //break;
      } else if (Ch == 'b') {break;
      } else if (Ch == 'a') {
        Xil_Out32(BD_REG32_ADDR + 0x1C, 0x001); // div1 43sec
        Xil_Out32(BD_REG32_ADDR + 0x20, 0x700);// div2 
        Xil_Out32(BD_REG32_ADDR + 0x24, 0x89B);// div3 0x89B ~51Hz?
        Xil_Out32(BD_REG32_ADDR + 0x28, 0x0AC);// div4 yellow ~0.25sec
      } else if (Ch == '0') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x0);
      } else if (Ch == '1') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x1);
      } else if (Ch == '2') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x2);
      } else if (Ch == '3') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x3);
      } else if (Ch == '4') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x4);
      } else if (Ch == '5') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x5);
      }
    }

	//xil_printf("Successfully ran Low Level GIC Example Test\r\n");
    //powerOff();

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function is an example of how to use the interrupt controller driver
* (XScuGic) and the hardware device.  This function is designed to
* work without any hardware devices to cause interrupts.  It may not return
* if the interrupt controller is not properly connected to the processor in
* either software or hardware.
*
* This function relies on the fact that the interrupt controller hardware
* has come out of the reset state such that it will allow interrupts to be
* simulated by the software.
*
* @param	CpuBaseAddress is Base Address of the Interrupt Controller
*		Device
*
* @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE
*
* @note		None.
*
******************************************************************************/
static int ScuGicLowLevelExample(u32 CpuBaseAddress, u32 DistBaseAddress)
{
	int Status;
	GicDistInit(DistBaseAddress);

	GicCPUInit(CpuBaseAddress);

	/*
	 * This step is processor specific, connect the handler for the
	 * interrupt controller to the interrupt source for the processor
	 */
	SetupInterruptSystem();

	/*
	 * Enable the software interrupts only.
	 */
	//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET, 0x0000FFFF); //PPIs 31:16,  SGIs 15:0, 

    // PL_PS_Group0 121:128
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0xFE000000); // IDs 127:121 = PL to PS ints 6:0
    XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0x02000000); // ID 121 = PL to PS int 0



	/*
	 * Cause (simulate) an interrupt so the handler will be called.
	 * This is done by changing the interrupt source to be software driven,
	 * then set a bit which simulates an interrupt.
	 */
	//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_SFI_TRIG_OFFSET, GIC_DEVICE_INT_MASK);


	/*
	 * Wait for the interrupt to be processed, if the interrupt does not
	 * occur return failure after timeout.
	 */
	Status = Xil_WaitForEventSet(XSCUGIC_SW_TIMEOUT_VAL, 1,
				     &InterruptProcessed);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
/*****************************************************************************/
/**
*
* This function connects the interrupt handler of the interrupt controller to
* the processor.  This function is separate to allow it to be customized for
* each application.  Each processor or RTOS may require unique processing to
* connect the interrupt handler.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void SetupInterruptSystem(void)
{
	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the ARM processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
				     (Xil_ExceptionHandler) LowInterruptHandler,
				     (void *)CPU_BASEADDR);

	/*
	 * Enable interrupts in the ARM
	 */
	Xil_ExceptionEnable();
}

/*****************************************************************************/
/**
*
* This function is designed to look like an interrupt handler in a device
* driver. This is typically a 2nd level handler that is called from the
* interrupt controller interrupt handler.  This handler would typically
* perform device specific processing such as reading and writing the registers
* of the device to clear the interrupt condition and pass any data to an
* application using the device driver.
*
* @param    CallbackRef is passed back to the device driver's interrupt handler
*           by the XScuGic driver.  It was given to the XScuGic driver in the
*           XScuGic_Connect() function call.  It is typically a pointer to the
*           device driver instance variable if using the Xilinx Level 1 device
*           drivers.  In this example, we are passing it as scugic cpu
*           interface base address to access ack and EOI registers.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
void LowInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;

    //xil_printf("INTERRUPT HANDLER begin\r\n");

	BaseAddress = CallbackRef;

	/*
	 * Read the int_ack register to identify the interrupt and
	 * make sure it is valid.
	 */
	IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) &
		XSCUGIC_ACK_INTID_MASK;

	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
		return;
	}

	/*
	 * If the interrupt is shared, do some locking here if there are
	 * multiple processors.
	 */

	/*
	 * Execute the ISR. For this example set the global to 1.
	 * The software trigger is cleared by the ACK.
	 */
	InterruptProcessed = 1;

	/*
	 * Write to the EOI register, we are all done here.
	 * Let this function return, the boot code will restore the stack.
	 */
	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);

    xil_printf("INTERRUPT HANDLER done. IntID = %x\r\n",IntID);


}


static void GicDistInit(u32 BaseAddress)
{
	u32 Int_Id;

	XScuGic_WriteReg(BaseAddress, 
        XSCUGIC_DIST_EN_OFFSET, 
        //0x00000001UL); // enable dist, this is done below at end of this function ADG
        0UL);


	/*
	 * Set the security domains in the int_security registers for non-secure interrupts
	 * All are secure, so leave at the default. Set to 1 for non-secure interrupts.
	 */


	/*
	 * For the Shared Peripheral Interrupts INT_ID[MAX..32], set:
	 */

	/*
	 * 1. The trigger mode in the int_config register
	 */
	for (Int_Id = 32; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 16) {
		/*
		 * Each INT_ID uses two bits, or 16 INT_ID per register
		 * Set them all to be level sensitive, active HIGH.
		 */
		XScuGic_WriteReg(BaseAddress, 
                            XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16, 
                            0xFFFFFFFFUL);//0UL); //ADG
	}


#define DEFAULT_PRIORITY    0xa0a0a0a0UL
#define DEFAULT_TARGET    0x01010101UL


	for (Int_Id = 0; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 4) {
		/*
		 * 2. The priority using int the priority_level register
		 * The priority_level and spi_target registers use one byte
		 * per INT_ID.
		 * Write a default value that can be changed elsewhere.
		 */
		XScuGic_WriteReg(BaseAddress,
				 XSCUGIC_PRIORITY_OFFSET + ((Int_Id * 4) / 4),
				 DEFAULT_PRIORITY);
	}
	for (Int_Id = 32; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 4) {
		/*
		 * 3. The CPU interface in the spi_target register
		 */
		XScuGic_WriteReg(BaseAddress,
				 XSCUGIC_SPI_TARGET_OFFSET + ((Int_Id * 4) / 4),
				 DEFAULT_TARGET);
	}

	for (Int_Id = 0; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 32) {
		/*
		 * 4. Enable the SPI using the enable_set register.
		 * Leave all disabled for now.
		 */
		XScuGic_WriteReg(BaseAddress,
				 XSCUGIC_DISABLE_OFFSET + ((Int_Id * 4) / 32), 0x0UL);//0xFFFFFFFFUL);

	}
	XScuGic_WriteReg(BaseAddress, XSCUGIC_DIST_EN_OFFSET, 0x01UL);

}

static void GicCPUInit(u32 BaseAddress)
{
	/*
	 * Program the priority mask of the CPU using the Priority mask register
	 */
	XScuGic_WriteReg(BaseAddress, XSCUGIC_CPU_PRIOR_OFFSET, 0xF0); //GICC_PMR


	/*
	 * If the CPU operates in both security domains, set parameters in the control_s register.
	 * 1. Set FIQen=1 to use FIQ for secure interrupts,
	 * 2. Program the AckCtl bit
	 * 3. Program the SBPR bit to select the binary pointer behavior
	 * 4. Set EnableS = 1 to enable secure interrupts
	 * 5. Set EnbleNS = 1 to enable non secure interrupts
	 */

	/*
	 * If the CPU operates only in the secure domain, setup the control_s register.
	 * 1. Set FIQen=1,
	 * 2. Set EnableS=1, to enable the CPU interface to signal secure interrupts.
	 */
	XScuGic_WriteReg(BaseAddress, XSCUGIC_CONTROL_OFFSET, 0x01);

}
