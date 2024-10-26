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
#include <time.h>
#include "sleep.h"
#include "platform.h"
#include "xil_printf.h"
#include <xil_io.h>
#include "xparameters.h"
#include "helpFunctions.h"

#define PL_REG32_ADDR  XPAR_AXIL_REG32_0_BASEADDR

#define ADDR_SG  0xA0010000
#define ADDR_DMA 0xA0000000
#define ADDR_MEM 0xC0000000
#define ADDR_REG 0xA0012000
#define NXDS_S0  0x00
#define BADD_S0  0x08
#define CTRL_S0  0x14
#define NXDS_S1  0x40
#define BADD_S1  0x48
#define CTRL_S1  0x54
#define NXDS_M0  0x80
#define BADD_M0  0x88
#define CTRL_M0  0x94
#define NXDS_M1  0xC0
#define BADD_M1  0xC8
#define CTRL_M1  0xD4
#define MM2S_CR  0x000
#define MM2S_SR  0x004
#define MM2S_CH  0x008
#define MM2S_PR  0x00C
#define MM2S_ER  0x010
#define MM2S_CQ  0x014
#define MM2S_CC  0x020
#define M_CH0CR  0x040
#define M_CH0CD  0x048
#define M_CH0TD  0x050
#define M_CH1CR  0x080
#define M_CH1CD  0x088
#define M_CH1TD  0x090
#define S2MM_CR  0x500
#define S2MM_SR  0x504
#define S2MM_CH  0x508
#define S2MM_PR  0x50C
#define S2MM_ER  0x510
#define S2MM_CQ  0x514
#define S2MM_CC  0x520
#define S_CH0CR  0x540
#define S_CH0CD  0x548
#define S_CH0TD  0x550
#define S_CH1CR  0x580
#define S_CH1CD  0x588
#define S_CH1TD  0x590

static void mcdmaCfg(void);
static void mcdmaReset(void);
static void mcdmaStatus(void);
static void readSG(void);
static void clearSG(void);

//static void delaySec(int);
//static void delayMs(int);
//static void xilWr(int, int, int, int);

int main()
{
    init_platform();

    xil_printf("\n\rtesting adg555\n\r");
    versionCtrl0();

/*************************************************************************************************/

/*************************************************************************************************/
    //readSG();
    //mcdmaStatus();
    mcdmaCfg();
    //readSG();
    
    //readSG();

    //mcdmaStatus();
    mcdmaReset();
    clearSG();
    //mcdmaStatus();
    
    for(int x=0;x<10;x++){
        mcdmaCfg();
        mcdmaReset();
        clearSG();
    }

    //int val2 = 0;
    //val2 = (1<<31) | (1<<30) | 0x40;
    //xil_printf("val2=%x\n\r",val2);
    
    //int x;
    //for(x=0;x<10;x++) {
    //    xil_printf("sec%d\n",x);
    //    usleep(500000); //500ms
    //}
    
    

/*************************************************************************************************/

    xil_printf("\n\r----------------------------------------\n\r");
    xil_printf("** END **\n\r");
    xil_printf("----------------------------------------\n\r\n\r");

    cleanup_platform();
    return 0;
}

void readSG(void) {
    
    int val,reg;
    
    for(int x=0;x<=0x10C;x=x+0x4) {
      reg = x; val = Xil_In32(ADDR_SG + reg);  xil_printf("%x = %x\n\r",reg,val);
    }

    /*
    reg = NXDS_S0; val = Xil_In32(ADDR_SG + reg);  xil_printf("NXDS_S0(%x) = %x\n\r",reg, val);
    reg = 0x04   ; val = Xil_In32(ADDR_SG + reg);  xil_printf("%x = %x\n\r"         ,reg, val);
    reg = BADD_S0; val = Xil_In32(ADDR_SG + reg);  xil_printf("BADD_S0(%x) = %x\n\r",reg, val);
    reg = 0x10   ; val = Xil_In32(ADDR_SG + reg);  xil_printf("%x = %x\n\r"         ,reg, val);
    reg = CTRL_S0; val = Xil_In32(ADDR_SG + reg);  xil_printf("CTRL_S0(%x) = %x\n\r",reg, val);
    reg = NXDS_S1; val = Xil_In32(ADDR_SG + reg);  xil_printf("NXDS_S1(%x) = %x\n\r",reg, val);
    reg = BADD_S1; val = Xil_In32(ADDR_SG + reg);  xil_printf("BADD_S1(%x) = %x\n\r",reg, val);
    reg = CTRL_S1; val = Xil_In32(ADDR_SG + reg);  xil_printf("CTRL_S1(%x) = %x\n\r",reg, val);
    reg = NXDS_M0; val = Xil_In32(ADDR_SG + reg);  xil_printf("NXDS_M0(%x) = %x\n\r",reg, val);
    reg = BADD_M0; val = Xil_In32(ADDR_SG + reg);  xil_printf("BADD_M0(%x) = %x\n\r",reg, val);
    reg = CTRL_M0; val = Xil_In32(ADDR_SG + reg);  xil_printf("CTRL_M0(%x) = %x\n\r",reg, val);
    reg = NXDS_M1; val = Xil_In32(ADDR_SG + reg);  xil_printf("NXDS_M1(%x) = %x\n\r",reg, val);
    reg = BADD_M1; val = Xil_In32(ADDR_SG + reg);  xil_printf("BADD_M1(%x) = %x\n\r",reg, val);
    reg = CTRL_M1; val = Xil_In32(ADDR_SG + reg);  xil_printf("CTRL_M1(%x) = %x\n\r",reg, val);
    
    reg = 0xD8 ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xDC ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xE0 ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xE4 ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xE8 ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xEC ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xF0 ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xF4 ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xF8 ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0xFC ; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0x100; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0x104; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0x108; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    reg = 0x10C; val = Xil_In32(ADDR_SG + reg);     xil_printf("%x= %x\n\r",reg,val);
    */
    xil_printf("\n\r*************** SG READ ****************\n\r");
}

void clearSG(void) {

    int reg;

    for(int x=0;x<=0x10C;x=x+0x4) {
      reg = x; Xil_Out32(ADDR_SG + reg, 0x0);
    }

/*
    Xil_Out32(ADDR_SG + NXDS_S0 ,0x0);
    Xil_Out32(ADDR_SG + BADD_S0 ,0x0);
    Xil_Out32(ADDR_SG + CTRL_S0 ,0x0);
    Xil_Out32(ADDR_SG + NXDS_S1 ,0x0);
    Xil_Out32(ADDR_SG + BADD_S1 ,0x0);
    Xil_Out32(ADDR_SG + CTRL_S1 ,0x0);
    Xil_Out32(ADDR_SG + NXDS_M0 ,0x0);
    Xil_Out32(ADDR_SG + BADD_M0 ,0x0);
    Xil_Out32(ADDR_SG + CTRL_M0 ,0x0);
    Xil_Out32(ADDR_SG + NXDS_M1 ,0x0);
    Xil_Out32(ADDR_SG + BADD_M1 ,0x0);
    Xil_Out32(ADDR_SG + CTRL_M1 ,0x0);
    Xil_Out32(ADDR_SG + 0xD8    ,0x0);
    Xil_Out32(ADDR_SG + 0xDC    ,0x0);
    Xil_Out32(ADDR_SG + 0xE0    ,0x0);
    Xil_Out32(ADDR_SG + 0xE4    ,0x0);
    Xil_Out32(ADDR_SG + 0xE8    ,0x0);
    Xil_Out32(ADDR_SG + 0xEC    ,0x0);
    Xil_Out32(ADDR_SG + 0xF0    ,0x0);
    Xil_Out32(ADDR_SG + 0xF4    ,0x0);
    Xil_Out32(ADDR_SG + 0xF8    ,0x0);
    Xil_Out32(ADDR_SG + 0xFC    ,0x0);
    Xil_Out32(ADDR_SG + 0x100   ,0x0);
    Xil_Out32(ADDR_SG + 0x104   ,0x0);
    Xil_Out32(ADDR_SG + 0x108   ,0x0);
    Xil_Out32(ADDR_SG + 0x10C   ,0x0);
*/
    xil_printf("\n\r*************** SG CLEAR ****************\n\r");


}

void mcdmaStatus(void) {

    int val;
    val = Xil_In32(ADDR_DMA + MM2S_CR);   xil_printf("MM2S_CR = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + MM2S_SR);   xil_printf("MM2S_SR = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + MM2S_CH);   xil_printf("MM2S_CH = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + MM2S_PR);   xil_printf("MM2S_PR = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + MM2S_ER);   xil_printf("MM2S_ER = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + MM2S_CQ);   xil_printf("MM2S_CQ = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + MM2S_CC);   xil_printf("MM2S_CC = %x\n\r",val);

    val = Xil_In32(ADDR_DMA + S2MM_CR);   xil_printf("S2MM_CR = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + S2MM_SR);   xil_printf("S2MM_SR = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + S2MM_CH);   xil_printf("S2MM_CH = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + S2MM_PR);   xil_printf("S2MM_PR = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + S2MM_ER);   xil_printf("S2MM_ER = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + S2MM_CQ);   xil_printf("S2MM_CQ = %x\n\r",val);
    val = Xil_In32(ADDR_DMA + S2MM_CC);   xil_printf("S2MM_CC = %x\n\r",val);

    xil_printf("\n\r*************** MCDMA STATUS ****************\n\r");

}

void mcdmaReset(void) {

    //Xil_Out32(ADDR_DMA + S2MM_CR, 0x4);        // reset DMA
    Xil_Out32(ADDR_DMA + MM2S_CR, 0x4);        // reset DMA both MM2S and SS2M
    usleep(4);
    xil_printf("\n\r*************** MCDMA RESET ****************\n\r");

}

void mcdmaCfg(void) {

    //S2MM descriptors
    /* CH0 1st descriptor, store 8bytes - two 32bit words */
    Xil_Out32(ADDR_SG + NXDS_S0, ADDR_SG + NXDS_S0); // point to next descriptor
    Xil_Out32(ADDR_SG + BADD_S0, 0xC0000000); // location to store data
    //Xil_Out32(ADDR_SG + CTRL_S0, ((1<<31) | (1<<30) | 0x40));// 0xC0000040 //(0x0, 0x1, 0x1, 0x0, 0x40)); // RXSOF, REOF, Reserved, Len
    Xil_Out32(ADDR_SG + CTRL_S0, 0xC0000040);// 0xC0000040 //(0x0, 0x1, 0x1, 0x0, 0x40)); // RXSOF, REOF, Reserved, Len
    /* CH1 1st descriptor, store 8bytes - two 32bit words */
    Xil_Out32(ADDR_SG + NXDS_S1, ADDR_SG + NXDS_S1); // point to next descriptor
    Xil_Out32(ADDR_SG + BADD_S1, 0xC0001000); // location to store data
    Xil_Out32(ADDR_SG + CTRL_S1, 0xC0000040); // RXSOF, REOF, Reserved, Len

    //MM2S descriptors different location
    //CH0
    Xil_Out32(ADDR_SG + NXDS_M0, ADDR_SG + NXDS_M0); // point to next descriptor
    Xil_Out32(ADDR_SG + BADD_M0, 0xC0001000); // location to get data
    Xil_Out32(ADDR_SG + CTRL_M0, 0xC0000040); // RXSOF, REOF, Reserved, Len
    //CH1
    Xil_Out32(ADDR_SG + NXDS_M1, ADDR_SG + NXDS_M1); // point to next descriptor
    Xil_Out32(ADDR_SG + BADD_M1, 0xC0000000); // location to get data
    Xil_Out32(ADDR_SG + CTRL_M1, 0xC0000040); // RXSOF, REOF, Reserved, Len

    //---------------------------------------------------------------------------------------------
    //S2MM DMA config
    //---------------------------------------------------------------------------------------------
    // config. DMA for descriptor location and initiate/start transfers
    Xil_Out32(ADDR_DMA + S2MM_CH, 0x3);              // enable channels
    Xil_Out32(ADDR_DMA + S_CH0CD, ADDR_SG + NXDS_S0);  // CD for ch0
    Xil_Out32(ADDR_DMA + S_CH1CD, ADDR_SG + NXDS_S1);  // CD for ch1
    Xil_Out32(ADDR_DMA + S_CH0CR, 0x1);        // ch0 fetch bit
    Xil_Out32(ADDR_DMA + S_CH1CR, 0x1);        // ch1 fetch bit
    Xil_Out32(ADDR_DMA + S2MM_CR, 0x1);        // start DMA
    Xil_Out32(ADDR_DMA + S_CH0TD, ADDR_SG + NXDS_S0);  // TD for ch0
    Xil_Out32(ADDR_DMA + S_CH1TD, ADDR_SG + NXDS_S1);  // TD for ch1

    //#200;
    //done<=1;
    //#4us;
    usleep(4);
    //---------------------------------------------------------------------------------------------
    //MM2S DMA config
    //---------------------------------------------------------------------------------------------
    Xil_Out32(ADDR_DMA + MM2S_CH, 0x3);        // enable channels
    Xil_Out32(ADDR_DMA + M_CH0CD, ADDR_SG + NXDS_M0);  // CD for ch0
    Xil_Out32(ADDR_DMA + M_CH1CD, ADDR_SG + NXDS_M1);  // CD for ch1
    Xil_Out32(ADDR_DMA + M_CH0CR, 0x1);        // ch0 fetch bit
    Xil_Out32(ADDR_DMA + M_CH1CR, 0x1);        // ch1 fetch bit
    Xil_Out32(ADDR_DMA + MM2S_CR, 0x1);        // start DMA
    Xil_Out32(ADDR_DMA + M_CH0TD, ADDR_SG + NXDS_M0);  // TD for ch0
    Xil_Out32(ADDR_DMA + M_CH1TD, ADDR_SG + NXDS_M1);  // TD for ch1

    xil_printf("\n\r*************** MCDMA DONE ****************\n\r");

}

//void xilWr(int val1a, int val1b, int val2a, int val2b) {
//    int val1 = val1a + val1b;
//    int val2 = val2a + val2b;
//    Xil_Out32(val1,val2);
//}

//void delaySec(int number_of_seconds)
//{
//    // Converting time into milli_seconds
//    int milli_seconds = 1000 * number_of_seconds;
//
//    // Storing start time
//    clock_t start_time = clock();
//
//    // looping till required time is not achieved
//    while (clock() < start_time + milli_seconds);
//}
//
//void delayMs(int number_of_ms)
//{
//    // Storing start time
//    clock_t start_time = clock();
//
//    // looping till required time is not achieved
//    while (clock() < start_time + number_of_ms);
//}