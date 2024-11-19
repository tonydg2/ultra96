/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"
#include <xil_io.h>
#include "xparameters.h"
#include "helpFunctions.h"
#include <unistd.h>
#include "xspips.h"		/* SPI device driver */


#define BD_REG32_ADDR   XPAR_AXIL_REG32_0_BASEADDR
//#define BD_REG32_2_ADDR 0xa0010000
#define BD_REG32_2_ADDR 0xa0001000

#define BUFFER_SIZE 3
typedef u8 SPI0_DataBuffer[BUFFER_SIZE];

int SpiPsEepromPolledExample(XSpiPs *SpiInstancePtr, UINTPTR BaseAddress);

static XSpiPs SpiInstance;

SPI0_DataBuffer ReadBuffer;
SPI0_DataBuffer WriteBuffer;


int main()
{
    init_platform();

    xil_printf("\n\rtesting adg0000\n\r");
    
    check0();    
    versionCtrl();
    
    int Status;

	//Status = SpiPsEepromPolledExample(&SpiInstance, XPAR_XSPIPS_0_BASEADDR);
	Status = SpiPsEepromPolledExample(&SpiInstance, XPAR_XSPIPS_1_BASEADDR); //emio
	if (Status != XST_SUCCESS) {xil_printf("FAIL\r\n"); return XST_FAILURE;}



    //int val = 11;
    //val = Xil_In32(0xa0010000);
    //Xil_Out32(0xa0010000,0x5);
    //xil_printf("Val = %d\n\r",val);
    //xil_printf("Val = %x\n\r",val);
    
    xil_printf("Running...\r\n");
    s8 Ch;
    while (1) {
      Ch = inbyte();
      if (Ch == '\r') {
          outbyte('\n');
      }
      outbyte(Ch);
      xil_printf("\r\n");

      if (Ch == 'p') {
        xil_printf("\r\n POWER OFF\r\n");
        usleep(10000);
        powerOff();
      } else if (Ch == 'b') {break;
      } else if (Ch == 'c') {
        //Status = SpiPsEepromPolledExample(&SpiInstance, XPAR_XSPIPS_0_BASEADDR);
        Status = SpiPsEepromPolledExample(&SpiInstance, XPAR_XSPIPS_1_BASEADDR); //emio
      } else if (Ch == 'd') {
        Status = SpiPsEepromPolledExample(&SpiInstance, XPAR_XSPIPS_0_BASEADDR);
      }
      //} else if (Ch == '0') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x0);
      //} else if (Ch == '1') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x1);
      //} else if (Ch == '2') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x2);
      //} else if (Ch == '3') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x3);
      //} else if (Ch == '4') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x4);
      //} else if (Ch == '5') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x5);
      //}
    }
    xil_printf("\n\r----------------------------------------\n\r");
    xil_printf("** END **\n\r");
    xil_printf("----------------------------------------\n\r\n\r");

    cleanup_platform();
    
    return 0;
}

int SpiPsEepromPolledExample(XSpiPs *SpiInstancePtr, UINTPTR BaseAddress)
{
	int Status;
    u8 SpiWriteData,SpiReadData,val;
    XSpiPs_Config *SpiConfig;
    
    SpiConfig = XSpiPs_LookupConfig(BaseAddress);//Initialize the SPI driver so that it's ready to use
	if (NULL == SpiConfig) {return XST_FAILURE;}

    Status = XSpiPs_CfgInitialize(SpiInstancePtr, SpiConfig,SpiConfig->BaseAddress);
	if (Status != XST_SUCCESS) {return XST_FAILURE;}

    Status = XSpiPs_SelfTest(SpiInstancePtr); // self-test to check hardware build
	if (Status != XST_SUCCESS) {return XST_FAILURE;}

    XSpiPs_SetSlaveSelect(SpiInstancePtr, 0xF); // all off
    //Set the Spi device as a master. External loopback is required.
    XSpiPs_SetOptions(SpiInstancePtr, XSPIPS_MASTER_OPTION | XSPIPS_FORCE_SSELECT_OPTION);

	XSpiPs_SetClkPrescaler(SpiInstancePtr, XSPIPS_CLK_PRESCALE_64);

    /*  0x0 = MIO41 SPI0_CS     ClickMezz Slot1
    *   0x1 = MIO40 SPI0_CS1    ClickMezz Slot2
    *   0x2 = MIO39 SPI0_CS2    ClickMezz ADC?
    */
    XSpiPs_SetSlaveSelect(SpiInstancePtr, 0x0); // slot1
    XSpiPs_SetSlaveSelect(SpiInstancePtr, 0x1); // slot2
    XSpiPs_SetSlaveSelect(SpiInstancePtr, 0xF); // all off


    WriteBuffer[0] = (u8)(0x41); //data to write OPCODE 0100 & 000 & R/W 0x40 = WRITE, 0x41 = READ
    WriteBuffer[1] = (u8)(0x01); //data to write ADDRESS
    WriteBuffer[2] = (u8)(0x5A); //data to write DATA byte
    //SpiWriteData = (u8)(0x01); //data to write

    XSpiPs_SetSlaveSelect(SpiInstancePtr, 0x0); // CS slot1
    // write data 1byte
    //s32 XSpiPs_PolledTransfer(XSpiPs *InstancePtr, u8 *SendBufPtr, u8 *RecvBufPtr, u32 ByteCount)
 //   XSpiPs_PolledTransfer(SpiInstancePtr, &WriteBuffer[0], NULL, 0x3); // write     //&WriteBuffer[0] is pointer to start of buffer (that's why [0])
    //XSpiPs_PolledTransfer(SpiInstancePtr, &SpiWriteData, NULL, 0x1);// send one byte

    // Now wait until done... or check somehow
    // while (1) {

    ReadBuffer[0] = (u8)(0x0); 
    ReadBuffer[1] = (u8)(0x0); 
    ReadBuffer[2] = (u8)(0x0); 
    //val = ReadBuffer[0];
    //xil_printf("val0 = %x\r\n",val);
    //val = ReadBuffer[1];
    //xil_printf("val0 = %x\r\n",val);

    // read back
    XSpiPs_PolledTransfer(SpiInstancePtr, &WriteBuffer[0], &ReadBuffer[0], 0x4); 
    XSpiPs_SetSlaveSelect(SpiInstancePtr, 0xF); // all off
    usleep(10000);//10ms

    val = ReadBuffer[0];
    xil_printf("val = %x\r\n",val);
    val = ReadBuffer[1];
    xil_printf("val = %x\r\n",val);
    val = ReadBuffer[2];
    xil_printf("val = %x\r\n",val);



    /*********************************************************************************************/
    return XST_SUCCESS;
}