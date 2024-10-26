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

// GPIO MIO LEDs - Zynq U+ registers UG1087
// GPIO 0x00FF0A0000
// MIO 20:17 all on BANK0
//  need to configure direction as outputs (DIRM 0x204) and enable the outputs (OEN 0x208), 
//  then write the value (DATA 0x40)

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include <xil_io.h>
#include "xparameters.h"
#include "helpFunctions.h"

#define PL_REG32_ADDR   XPAR_AXIL_REG32_0_BASEADDR
#define GPIO_MIO_ADDR   XPAR_GPIO_BASEADDR

#define MIO_WR_0_25_OFFSET      0x40
#define MIO_WR_26_51_OFFSET     0x44

#define MIO_RD_0_25_OFFSET      0x60
#define MIO_RD_26_51_OFFSET     0x64

#define MIO_DIRM_0  0x204
#define MIO_OEN_0   0x208

#define MIO_DIRM_1  0x244
#define MIO_OEN_1   0x248

static void ledCtrl(void);
static void ledCfg(void);
static void powerOff(void);

int main()
{
    init_platform();

    xil_printf("\n\rtesting adg2\n\r");

    powerOff();

    versionCtrl0();
    ledCfg();
    ledCtrl();

    int val = 11;
    //val = Xil_In32(GPIO_MIO_ADDR + MIO_RD_0_25_OFFSET);
    //val = Xil_In32(GPIO_MIO_ADDR + MIO_DIRM_0);
    //Xil_Out32(0xa0010000,0x5);
    //xil_printf("Val = %d\n\r",val);
    //xil_printf("Val = %x\n\r",val);
    //Xil_Out32(GPIO_MIO_ADDR + MIO_WR_0_25_OFFSET,0);
    //Xil_Out32(GPIO_MIO_ADDR + MIO_WR_0_25_OFFSET,0xffffffff);
    

    xil_printf("\n\r----------------------------------------\n\r");
    xil_printf("** END **\n\r");
    xil_printf("----------------------------------------\n\r\n\r");

    cleanup_platform();
    return 0;
}


void powerOff(void) {
    int shift, mask, val, pwrRD, pwrWR, pwrOFF;
    
    shift = 8;
    mask = 0x1 << shift; // 1bits
    val = 0x1 << shift; // set output and enable
    pwrOFF = 0x0 << shift;
    pwrRD = Xil_In32(GPIO_MIO_ADDR + MIO_DIRM_1);
    xil_printf("pwrRD = %x\n\r",pwrRD);
    pwrWR = (pwrRD & ~mask) | (val & mask);
    xil_printf("pwrWR = %x\n\r",pwrWR);
    Xil_Out32(GPIO_MIO_ADDR + MIO_DIRM_1,pwrWR);
    //pwrRD = Xil_In32(GPIO_MIO_ADDR + MIO_DIRM_0);
    //xil_printf("pwrRD = %x\n\r",pwrRD);

    pwrRD = Xil_In32(GPIO_MIO_ADDR + MIO_OEN_1);
    xil_printf("pwrRD = %x\n\r",pwrRD);
    pwrWR = (pwrRD & ~mask) | (val & mask);
    xil_printf("pwrWR = %x\n\r",pwrWR);
    Xil_Out32(GPIO_MIO_ADDR + MIO_OEN_1,pwrWR);

    pwrRD = Xil_In32(GPIO_MIO_ADDR + MIO_RD_26_51_OFFSET);
    xil_printf("pwrRD = %d\n\r",val);
    pwrWR = (pwrRD & ~mask) | (pwrOFF & mask);
    Xil_Out32(GPIO_MIO_ADDR + MIO_WR_26_51_OFFSET,pwrWR);


}

void ledCfg(void) {
    int shift, mask, val, ledRD, ledWR;
    
    shift = 17;
    mask = 0xF << shift; // 4bits
    val = 0xF << shift; // set LEDs bits 20:17 as outputs and enable them
    ledRD = Xil_In32(GPIO_MIO_ADDR + MIO_DIRM_0);
    xil_printf("ledRD = %x\n\r",ledRD);
    ledWR = (ledRD & ~mask) | (val & mask);
    xil_printf("ledWR = %x\n\r",ledWR);
    Xil_Out32(GPIO_MIO_ADDR + MIO_DIRM_0,ledWR);
    //ledRD = Xil_In32(GPIO_MIO_ADDR + MIO_DIRM_0);
    //xil_printf("ledRD = %x\n\r",ledRD);

    ledRD = Xil_In32(GPIO_MIO_ADDR + MIO_OEN_0);
    xil_printf("ledRD = %x\n\r",ledRD);
    ledWR = (ledRD & ~mask) | (val & mask);
    xil_printf("ledWR = %x\n\r",ledWR);
    Xil_Out32(GPIO_MIO_ADDR + MIO_OEN_0,ledWR);


}


void ledCtrl(void) {
    int shift, mask, val, ledRD, ledWR;

    shift = 17;
    mask = 0xF << shift; // 4bits
    val = 0x5 << shift;
    ledRD = Xil_In32(GPIO_MIO_ADDR + MIO_RD_0_25_OFFSET);
    xil_printf("ledRD = %x\n\r",ledRD);
    ledWR = (ledRD & ~mask) | (val & mask);
    xil_printf("ledWR = %x\n\r",ledWR);
    Xil_Out32(GPIO_MIO_ADDR + MIO_WR_0_25_OFFSET,ledWR);
    ledRD = Xil_In32(GPIO_MIO_ADDR + MIO_RD_0_25_OFFSET);
    xil_printf("ledRD = %x\n\r",ledRD);
    ledRD = Xil_In32(GPIO_MIO_ADDR + MIO_WR_0_25_OFFSET);
    xil_printf("read ledWR = %x\n\r",ledRD);

}
