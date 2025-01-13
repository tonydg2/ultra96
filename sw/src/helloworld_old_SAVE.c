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
#include <xil_io.h>
#include "xparameters.h"
#include "helpFunctions.h"

#define PL_REG32_ADDR  XPAR_AXIL_REG32_0_BASEADDR

static void versionCtrl(void);


int main()
{
    init_platform();

    xil_printf("\n\rtesting adg2\n\r");

    versionCtrl();
    versionCtrl0();

    int val = 11;
    //val = Xil_In32(0xa0010000);
    //val = Xil_In32(0xa0020000);
    //Xil_Out32(0xa0010000,0x5);

    xil_printf("Val = %d\n\r",val);
    xil_printf("Val = %x\n\r",val);
    
    val = Xil_In32(0xa001200C);
    xil_printf("Reg3 = %x\n\r",val);
    val = Xil_In32(0xa0012010);
    xil_printf("Reg4 = %x\n\r",val);

    

    xil_printf("\n\r----------------------------------------\n\r");
    xil_printf("** END **\n\r");
    xil_printf("----------------------------------------\n\r\n\r");

    cleanup_platform();
    return 0;
}

void versionCtrl(void) {

    static unsigned gitL,gitM,timeStamp;
    gitL = Xil_In32(PL_REG32_ADDR + 0); // gitl
    gitM = Xil_In32(PL_REG32_ADDR + 0x4); // gitm
    timeStamp = Xil_In32(PL_REG32_ADDR + 0x8); // timestamp
    
    static unsigned sec,min,hr,yr,mon,day;
    //sec = (timeStamp & (((1 << numBits) - 1) << startBit)) >> startBit;   //  09B1219F  Fri Mar  1 18:06:31 2024
    sec = (timeStamp & (((1 << 6) - 1) << 0)) >> 0;
    min = (timeStamp & (((1 << 6) - 1) << 6)) >> 6;
    hr  = (timeStamp & (((1 << 5) - 1) << 12)) >> 12;
    yr  = (timeStamp & (((1 << 6) - 1) << 17)) >> 17;
    mon = (timeStamp & (((1 << 4) - 1) << 23)) >> 23;
    day = (timeStamp & (((1 << 5) - 1) << 27)) >> 27;

    xil_printf("\n\r*************** VERSION ****************\n\r");
    xil_printf("  Git Hash: %x%x\n\r",gitM,gitL);
    xil_printf("  TIMESTAMP:%x = %d/%d/%d - %d:%d:%d\n\r",timeStamp,mon,day,yr,hr,min,sec);
    xil_printf("****************************************\n\r\n\r");

}