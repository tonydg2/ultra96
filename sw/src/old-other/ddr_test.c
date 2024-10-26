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
#include <stdlib.h>
#include <time.h>
#include <stdint.h>
#include "xiltimer.h"
#include "xil_types.h"


#define DDR_BASE_ADDR 0x00000000  // Base address of DDR (change as appropriate)
#define SIZE_MB 2               // Size of memory block to test in MB

#define PL_REG32_ADDR  XPAR_AXIL_REG32_0_BASEADDR

static void versionCtrl(void);
static void ddrBWTest(int);

int main()
{
    init_platform();

    xil_printf("\n\rtesting adg2\n\r");
    int x;
    //versionCtrl();
    versionCtrl0();

    ddrBWTest(4);
    ddrBWTest(10);
    
    for(x=0;x<10;x++) {ddrBWTest(0x100);}
    for(x=0;x<10;x++) {ddrBWTest(0x400);}

    xil_printf("\n\r----------------------------------------\n\r");
    xil_printf("** END **\n\r");
    xil_printf("----------------------------------------\n\r\n\r");

    cleanup_platform();
    return 0;
}

void ddrBWTest(int sizeVal) {

    volatile uint32_t *ddr_mem = (uint32_t *)DDR_BASE_ADDR;
    int size = sizeVal;
    uint32_t i;
    XTime tStart, tEnd;
    double elapsedTime;

    xil_printf("\n\r------  %d  ----------------------------\n\r",size);

    // Fill memory with a pattern
    XTime_GetTime(&tStart);
    for (i = 0; i < size; i++) {
        ddr_mem[i] = i;
    }
    XTime_GetTime(&tEnd);
    elapsedTime = (tEnd - tStart);
    //printf("tStart:%lx , tEnd:%lx \n\r",tStart, tEnd);
    printf("Write (%d) counts: %f \n\r",size, elapsedTime);

    // Read memory and verify pattern
    XTime_GetTime(&tStart);
    for (i = 0; i < size; i++) {
        if (ddr_mem[i] != i) {
            xil_printf("Data mismatch at index %x!\n\r", i);
            //return -1;
        }
    }
    XTime_GetTime(&tEnd);
    elapsedTime = (tEnd - tStart);
    //printf("tStart:%lx , tEnd:%lx \n\r",tStart, tEnd);
    printf("Read (%d) counts: %f \n\r",size, elapsedTime);
    xil_printf("----------------------------------------\n\r");
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