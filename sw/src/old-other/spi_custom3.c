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

#define SPI_ADDR   XPAR_XSPIPS_0_BASEADDR
//#define SPI_ADDR   XPAR_XSPIPS_1_BASEADDR
#define SPI_CFG     0x00      
#define SPI_ISR     0x04      
#define SPI_IER     0x08      
#define SPI_IDR     0x0C      
#define SPI_IMR     0x10      
#define SPI_EN      0x14  
#define SPI_DLY     0x18      
#define SPI_TXD     0x1C      
#define SPI_RXD     0x20      
#define SPI_SIC     0x24      
#define SPI_TXTHR   0x28
#define SPI_RXTHR   0x2C       
#define SPI_MODID   0xFC       

#define CMD_READ    0x41
#define CMD_WRITE   0x40

u8 SpiRegAddrsRD[] = {SPI_CFG, SPI_ISR, SPI_IER, SPI_IDR, SPI_IMR, 
                    SPI_EN, SPI_DLY, 
                    //SPI_TXD, 
                    //SPI_RXD, 
                    SPI_SIC, SPI_TXTHR, SPI_RXTHR, SPI_MODID};


#define BUFFER_SIZE 3
typedef u8 SPI0_DataBuffer[BUFFER_SIZE];

u32 SpiCustom0(u8 deviceRegAddr, u8 deviceRW, u8 data0);
void readSpi(u8 addr, int printDbg);
void writeSpi(u8 addr, u32 data, int printDbg);
void writeSpiBit(u8 addr, int bitVal, int bitIdx, int printDbg);
void readSpiAll();
void checkSpiRX(int printDbg);
int is_bit_set(int value, int bit_position);
void CS_ON();   //only CS0
void CS_OFF();  //only CS0
void CS_Assert(int CSval);
void CS_Deassert();
void SPI_Start();
void writeSpiTX();
int SpiTXEmpty(int printDbg);
u32 readSpiRXFIFO(int printRX);
void spiDisplayOff();
void spiDisplayOn();
void configSpiDevice();

int main()
{
    init_platform();
    int Status;
    u8 devAddr;
    
    xil_printf("\n\rtesting adg1234\n\r");
    //check0();    
    versionCtrl();
    configSpiDevice();

	//Status = SpiCustom0(); //emio
	//if (Status != XST_SUCCESS) {xil_printf("FAIL\r\n"); return XST_FAILURE;}
    
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
        usleep(10000);//10ms
        powerOff();
      } else if (Ch == 'b') {   break;
      } else if (Ch == 'c') {   SpiCustom0(0x01,CMD_READ,0); //emio
      } else if (Ch == 'd') {   readSpiAll();
      } else if (Ch == 'e') {   checkSpiRX(0);
      } else if (Ch == 'f') {   readSpiRXFIFO(1);
      } else if (Ch == 'g') {   SpiCustom0(0x05,CMD_READ,0);
      } else if (Ch == 'h') {   SpiCustom0(0x0A,CMD_READ,0);
      } else if (Ch == 'i') {   SpiCustom0(0x0B,CMD_READ,0);
      } else if (Ch == 'j') {   SpiCustom0(0x19,CMD_WRITE,0x38);
      } else if (Ch == 'k') {   SpiCustom0(0x1A,CMD_READ,0);
      } else if (Ch == 'l') {   
      } else if (Ch == 'm') {   spiDisplayOff();
      } else if (Ch == 'n') {   spiDisplayOn();
      } else if (Ch == 'o') {   SpiCustom0(0x10,CMD_READ,0x00);
      } else if (Ch == 'q') {   
      } else if (Ch == 'r') {   SpiCustom0(0x1A,CMD_WRITE,0x5a);
      } else if (Ch == 's') {   SpiCustom0(0x1A,CMD_WRITE,0);
      } else if (Ch == 't') {   SpiCustom0(0x19,CMD_WRITE,0);
      } else if (Ch == 'u') {   SpiCustom0(0x10,CMD_READ,0);
      } else if (Ch == 'v') {   SpiCustom0(0x11,CMD_READ,0);
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

u32 SpiCustom0(u8 deviceRegAddr, u8 deviceRW, u8 data0)
{
    int val,x;
    u32 rdata, readData;
    // SPI_CFG, SPI_ISR, SPI_IER, SPI_IDR, SPI_IMR,   SPI_EN   
    // SPI_DLY, SPI_TXD, SPI_RXD, SPI_SIC, SPI_TXTHR, SPI_RXTHR, SPI_MODID

    writeSpi(SPI_EN, 0x0, 0);
    readSpi(SPI_ISR, 0);
    readSpi(SPI_RXD, 0);
    //writeSpi(SPI_ISR, 0x0);// clear mode fault bit1
    //writeSpi(SPI_CFG, 0x0); //enable mode fail bit17    0x20000

    writeSpi(SPI_CFG, 0x2FC29, 0); //  manual start, manual CS, CS inactive, BAUD64, CLK_PH=0, CLK_POL=0, MASTER mode
    writeSpi(SPI_TXTHR, 0x1, 0);//set TX threshold 
    writeSpi(SPI_EN, 0x1, 0);// enable

    checkSpiRX(0);
        
    //xil_printf("Verify RX empty 0's\n\r");
    rdata = readSpiRXFIFO(0);
    if (rdata != 0x00) {
        xil_printf("ERROR PRE verifying empty RX : 0x%2x\n\r",rdata);
        return 0xFFFFFFFF;
    }

    SpiTXEmpty(0);

    Xil_Out32(SPI_ADDR + SPI_TXD, deviceRW);// TX 0x41 = READ, 0x40 = WRITE
    //Xil_Out32(SPI_ADDR + SPI_TXD, 0x01);// TX
    Xil_Out32(SPI_ADDR + SPI_TXD, deviceRegAddr);// TX
    Xil_Out32(SPI_ADDR + SPI_TXD, data0);// TX
    //Xil_Out32(SPI_ADDR + SPI_TXD, data1);// TX


    //CS_ON(); // CS0 enable
    SpiTXEmpty(0);
    xil_printf("SPI transfer...\n\r");
    CS_Assert(0);
    SPI_Start();
    x=0;
    while (1) {
        //xil_printf("Check TX empty %d\r\n",x);
        x++;
        val = SpiTXEmpty(0);
        if (val == 1) {
            CS_Deassert();
            break;
        }
        usleep(20000);//20ms
    }
    //usleep(1000);//1ms
    //CS_OFF();
    checkSpiRX(0);
    for (int x = 0;x < 2;x++){readSpiRXFIFO(0);} // command words
    //xil_printf("\n\rRX data:\n\r");   //deviceRegAddr, deviceRW TX 0x41 = READ, 0x40 = WRITE, data0,data1
    if (deviceRW == 0x41) {
        xil_printf("\n\rREAD RX addr 0x%02x\n\r",deviceRegAddr);
        for (int x = 0;x < 1;x++){readData = readSpiRXFIFO(1);} // read words
    } else if (deviceRW == 0x40) {
        xil_printf("\n\r WRITE addr 0x%02x, data 0x%02x\n\r",deviceRegAddr,data0);
        for (int x = 0;x < 1;x++){readSpiRXFIFO(0);} // write words
    } else {
        xil_printf("\n\r Error OPCODE command = 0x%02x\n\r",deviceRW);
    }

    //xil_printf("\n\rVerify RX empty 0's\n\r");
    //readSpiRXFIFO(1);
    rdata = readSpiRXFIFO(0);
    if (rdata != 0x00) {
        xil_printf("ERROR POST verifying empty RX : 0x%2x\n\r",rdata);
        return 0xFFFFFFFF;
    }


    checkSpiRX(0);
    SpiTXEmpty(0);

    /*********************************************************************************************/
    xil_printf("----------------------------------------\n\r\n\r");
    return readData;
}


/*********************************************************************************************/
//
/*********************************************************************************************/
void configSpiDevice()
{
    u32 rdata0,rdata1;
    rdata0 = SpiCustom0(0x05,CMD_READ,0);
    rdata1 = SpiCustom0(0x10,CMD_READ,0);
    if (rdata0 == 0xA0) {
        xil_printf("**** Config already set addr 0x05 = %02x ****\n\r",rdata0);
        if (rdata1 != 0x03) {xil_printf("OUTPUTS NOT SET addr 0x10 = %02x\n\r",rdata1);}
        return;
    }

    SpiCustom0(0x0A,CMD_WRITE,0xA0);// sets device to BANK1 config non-seq addr NO incr
    SpiCustom0(0x10,CMD_WRITE,0x03);//set GPIO [7:2] as outputs
}

void spiDisplayOff()
{
    SpiCustom0(0x1A,CMD_WRITE,0x38); 
    SpiCustom0(0x1A,CMD_WRITE,0x30); 
    usleep(100);
    SpiCustom0(0x1A,CMD_WRITE,0x28);
    SpiCustom0(0x1A,CMD_WRITE,0x20);
    SpiCustom0(0x1A,CMD_WRITE,0x48);
    SpiCustom0(0x1A,CMD_WRITE,0x40);
    usleep(100);
    SpiCustom0(0x1A,CMD_WRITE,0x08);
    SpiCustom0(0x1A,CMD_WRITE,0x00);
    SpiCustom0(0x1A,CMD_WRITE,0x88); //OFF
    SpiCustom0(0x1A,CMD_WRITE,0x80); //OFF
}

void spiDisplayOn()
{
    SpiCustom0(0x1A,CMD_WRITE,0x38); // 0x19 GPIO outputs BANK=1
    SpiCustom0(0x1A,CMD_WRITE,0x30); // 0x19 GPIO outputs BANK=1
    usleep(100);
    SpiCustom0(0x1A,CMD_WRITE,0x28);
    SpiCustom0(0x1A,CMD_WRITE,0x20);
    SpiCustom0(0x1A,CMD_WRITE,0x48);
    SpiCustom0(0x1A,CMD_WRITE,0x40);
    usleep(100);
    SpiCustom0(0x1A,CMD_WRITE,0x08);
    SpiCustom0(0x1A,CMD_WRITE,0x00);
    SpiCustom0(0x1A,CMD_WRITE,0xF8); //ON
    SpiCustom0(0x1A,CMD_WRITE,0xF0); //ON
}

int SpiTXEmpty(int printDbg) 
{
    int val;
    // bit2 will be 1 if FIFO has less than THRESHOLD, 0 if more or equal
    // setting THRESHOLD=1(default), makes this an empty flag
    val = Xil_In32(SPI_ADDR + SPI_ISR); 
    if (is_bit_set(val, 2)) {
        if (printDbg) {xil_printf("TX EMPTY\n\r");}
        return 1;
    } else {
        if (printDbg) {xil_printf("TX NOT empty\n\r");}
        return 0;
    }
}

void readSpi(u8 addr, int printDbg)
{
    int val;
    val = Xil_In32(SPI_ADDR + addr);
    if (printDbg) {xil_printf("Addr 0x%02x = 0x%02x\n\r",addr,val);}
}

void writeSpi(u8 addr, u32 data, int printDbg)
{
    int val;
    Xil_Out32(SPI_ADDR + addr,data);
    val = Xil_In32(SPI_ADDR + addr);
    if (printDbg) {xil_printf("Verified WR Addr 0x%02x = 0x%02x\n\r",addr,val);}
}

void writeSpiBit(u8 addr, int bitVal, int bitIdx, int printDbg)
{
    int val;
    val = Xil_In32(SPI_ADDR + addr);

    if (bitVal == 0) {
        val &= ~(1 << bitIdx); // clear the bit
    } else {
        val |= (1 << bitIdx);  // set the bit
    }

    Xil_Out32(SPI_ADDR + addr,val);
    val = Xil_In32(SPI_ADDR + addr);
    if (printDbg) {xil_printf("Verified bitIDX %d WR Addr 0x%02x = 0x%02x\n\r",bitIdx,addr,val);}

}

void readSpiAll()
{
    int val;

    for (unsigned long i = 0; i < sizeof(SpiRegAddrsRD); i++) {
        val = Xil_In32(SPI_ADDR + SpiRegAddrsRD[i]);
        xil_printf("Addr 0x%02x = 0x%02x\n\r",SpiRegAddrsRD[i],val);
    }

}

void checkSpiRX(int printDbg)
{
    int val;
    val = Xil_In32(SPI_ADDR + SPI_ISR); 
    if (~is_bit_set(val, 4)) {
        if (printDbg) {xil_printf("RX EMPTY\n\r");}
        return;
    }
    // check bit 4 RX_FIFO_not_empty
    while (is_bit_set(val, 4)) {
        val = Xil_In32(SPI_ADDR + SPI_RXD); // RX fifo
        if (printDbg) {xil_printf("RX fifo = 0x%02x\n\r",val);}
        val = Xil_In32(SPI_ADDR + SPI_ISR); 
    }
}

u32 readSpiRXFIFO(int printRX) 
{
    u32 val;
    val = Xil_In32(SPI_ADDR + SPI_RXD); // RX fifo
    if (printRX) {xil_printf("RX fifo = 0x%02x\n\r",val);}
    return val;
}

void writeSpiTX()
{

}

int is_bit_set(int value, int bit_position) 
{
    return (value & (1 << bit_position)) != 0;
}

void CS_ON() {
    writeSpiBit(SPI_CFG, 0, 10, 0); // bit 10 CS0 enable active-low
}

void CS_OFF() {
    writeSpiBit(SPI_CFG, 1, 10, 0); // bit 10 CS0 disable active-low
}

void SPI_Start() {
    writeSpiBit(SPI_CFG, 1, 16, 0); // write a 1 to bit 16
}

void CS_Assert(int CSval)
{
    switch (CSval) {
        case 0: 
            writeSpiBit(SPI_CFG, 0, 10, 0); // bit 10 CS0 enable active-low
            break;
        case 1: 
            writeSpiBit(SPI_CFG, 0, 11, 0); // CS1
            break;
        case 2: 
            writeSpiBit(SPI_CFG, 0, 12, 0); // CS2
            break;
        default: break;
    }
}

void CS_Deassert()
{
    int val;
    val = Xil_In32(SPI_ADDR + SPI_CFG); //get current
    val |= (0xF << 10); //set all CS high to disable
    Xil_Out32(SPI_ADDR + SPI_CFG,val);
}


