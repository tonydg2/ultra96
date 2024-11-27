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

void readSpi(u8 addr, int printDbg);
void writeSpi(u8 addr, u32 data, int printDbg);
void writeSpiBit(u8 addr, int bitVal, int bitIdx, int printDbg);
void readSpiAll();
int SpiRXEmpty(int printDbg);
int is_bit_set(int value, int bit_position);
void CS_Assert(int CSval);
void CS_Deassert();
void SPI_Start();
int SpiTXEmpty(int printDbg);
u32 readSpiRXFIFO(int printRX);
void LCDDisplayOff();
void LCDDisplayOn();
void configMCP();
int SpiConfig();
void Spi_MCP_WR(u8 RegAddrMCP, u8 data);
u8 Spi_MCP_RD(u8 RegAddrMCP);



int main()
{
    init_platform();
    int Status;
    u8 val;
    
    xil_printf("\n\rSPI **** SPI CUSTOM 666\n\r");
    //check0();    
    versionCtrl();

    //Status = SpiConfig();
    //if (Status != XST_SUCCESS) {xil_printf("SpiConfig FAIL\r\n"); return XST_FAILURE;}
    configMCP();
    
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
      
      } else if (Ch == 'c') {   val = Spi_MCP_RD(0x05); xil_printf("val = %02x\r\n",val);
      } else if (Ch == 'd') {   val = Spi_MCP_RD(0x00); xil_printf("val = %02x\r\n",val);
      } else if (Ch == 'e') {   val = Spi_MCP_RD(0x10); xil_printf("val = %02x\r\n",val);
      } else if (Ch == 'f') {   
      } else if (Ch == 'g') {   
      } else if (Ch == 'h') {   
      } else if (Ch == 'i') {   
      } else if (Ch == 'j') {   
      } else if (Ch == 'k') {   
      } else if (Ch == 'l') {   
      } else if (Ch == 'm') {   
      } else if (Ch == 'n') {   
      } else if (Ch == 'o') {   
      } else if (Ch == 'q') {   
      } else if (Ch == 'r') {   
      } else if (Ch == 's') {   
      } else if (Ch == 't') {   
      } else if (Ch == 'u') {   
      } else if (Ch == 'v') {   
      }
    }
    xil_printf("\n\r----------------------------------------\n\r");
    xil_printf("** END **\n\r");
    xil_printf("----------------------------------------\n\r\n\r");

    cleanup_platform();
    
    return XST_SUCCESS;
}
/*********************************************************************************************/
//
/*********************************************************************************************/



int SpiConfig()
{
    int Status;
    u32 rdata;

    writeSpi(SPI_EN, 0x0, 0); // disable SPI
    readSpi(SPI_ISR, 0);
    readSpi(SPI_RXD, 0);
    writeSpi(SPI_CFG, 0x2FC29, 0); //  manual start, manual CS, CS inactive, BAUD64, CLK_PH=0, CLK_POL=0, MASTER mode
    writeSpi(SPI_TXTHR, 0x1, 0);//set TX threshold
    writeSpi(SPI_EN, 0x1, 0);// enable
    
    SpiRXEmpty(0);
    rdata = readSpiRXFIFO(0);
    if (rdata != 0x00) {
        xil_printf("ERROR PRE verifying empty RX : 0x%2x\n\r",rdata);
        return XST_FAILURE;
    }
    SpiTXEmpty(0);
    Status = SpiRXEmpty(0);
    if (Status != XST_SUCCESS) {xil_printf("SpiRXEmpty FAIL\r\n");}
    Status = SpiTXEmpty(0);
    if (Status != XST_SUCCESS) {xil_printf("SpiTXEmpty FAIL\r\n");}

    return XST_SUCCESS;
}

// single byte write to MCP23S17 
void Spi_MCP_WR(u8 RegAddrMCP, u8 data) {

    int val,Status;
    u8 rdata;

    /******************************************/
    SpiConfig();
    /******************************************/

    Xil_Out32(SPI_ADDR + SPI_TXD, 0x40);        // TX 0x41 = READ, 0x40 = WRITE
    Xil_Out32(SPI_ADDR + SPI_TXD, RegAddrMCP);  // TX
    Xil_Out32(SPI_ADDR + SPI_TXD, data);        // TX

    CS_Assert(0);
    SPI_Start();
    while (1) {
        val = SpiTXEmpty(0);
        if (val == 1) {
            CS_Deassert();
            break;
        }
        usleep(20000);//20ms
    }

    SpiRXEmpty(0);
    for (int x = 0;x < 3;x++){readSpiRXFIFO(0);} // no RX, ignore/drop all
    
    rdata = readSpiRXFIFO(0);
    if (rdata != 0x00) {xil_printf("ERROR POST verifying empty RX : 0x%2x\n\r",rdata);}

    Status = SpiRXEmpty(0);
    if (Status != XST_SUCCESS) {xil_printf("SpiRXEmpty FAIL\r\n");}
    Status = SpiTXEmpty(0);
    if (Status != XST_SUCCESS) {xil_printf("SpiTXEmpty FAIL\r\n");}

}

u8 Spi_MCP_RD(u8 RegAddrMCP) {
    int val,Status;
    u8 readData;

    /******************************************/
    SpiConfig();
    /******************************************/

    Xil_Out32(SPI_ADDR + SPI_TXD, 0x41);        // TX 0x41 = READ, 0x40 = WRITE
    Xil_Out32(SPI_ADDR + SPI_TXD, RegAddrMCP);  // TX
    Xil_Out32(SPI_ADDR + SPI_TXD, 0x00);        // RX

    CS_Assert(0);
    SPI_Start();
    while (1) {
        val = SpiTXEmpty(0);
        if (val == XST_SUCCESS) {
            CS_Deassert();
            break;
        }
        //usleep(1000);//1ms
    }

    SpiRXEmpty(0);
    for (int x = 0;x < 2;x++){readSpiRXFIFO(0);} // ignore first 2 TX bytes
    readData = readSpiRXFIFO(1); // RX byte

    readData = readSpiRXFIFO(0);
    if (readData != 0x00) {xil_printf("ERROR POST verifying empty RX : 0x%2x\n\r",readData);}

    Status = SpiRXEmpty(0);
    if (Status != XST_SUCCESS) {xil_printf("SpiRXEmpty FAIL\r\n");}
    Status = SpiTXEmpty(0);
    if (Status != XST_SUCCESS) {xil_printf("SpiTXEmpty FAIL\r\n");}

    return readData;
}

// single command to the LCD module
void sendCmdLCD(u8 command) {
    u8 cmd,cmdEn;
    
    cmd = command & 0xF0;   // first 4 bits
    cmdEn = cmd | 0x08;     // E bit3
    
    Spi_MCP_WR(0x1A,cmd);   // write first 4bits to OLATB
    Spi_MCP_WR(0x1A,cmdEn); // write first 4bits and E to OLATB (ASSERT E)
    usleep(1);              // delay 1us 
    Spi_MCP_WR(0x1A,cmd);   // write first 4bits to OLATB (DEASSERT E)

    // repeat for second 4bits
    cmd = (command & 0x0F) << 4;
    cmdEn = cmd | 0x08;     // E bit3
    Spi_MCP_WR(0x1A,cmd);   // write second 4bits to OLATB
    Spi_MCP_WR(0x1A,cmdEn); // write second 4bits and E to OLATB (ASSERT E)
    usleep(1);              // delay 1us 
    Spi_MCP_WR(0x1A,cmd);   // write second 4bits to OLATB (DEASSERT E)

}

// config MCP device for BANK1 and GPIO outputs
void configMCP()
{
    u32 rdata0,rdata1;
    rdata0 = Spi_MCP_RD(0x05);
    usleep(2000);//2ms
    rdata1 = Spi_MCP_RD(0x10);
    usleep(2000);//2ms

    if (rdata0 == 0xA0) {
        xil_printf("**** Config already set addr 0x05 = %02x ****\n\r",rdata0);
        if (rdata1 != 0x03) {xil_printf("OUTPUTS NOT SET addr 0x10 = %02x\n\r",rdata1);}
        return;
    }

    Spi_MCP_WR(0x0A,0xA0);// sets device to BANK1 config non-seq addr NO incr
    usleep(2000);//2ms
    Spi_MCP_WR(0x10,0x03);// set GPIO [7:2] as outputs
    usleep(2000);//2ms
}

void LCDDisplayOff()
{
    // Function DB7:0 = 0 0 1 DL, N F x x
    // DL=0, 4bit mode  (1= 8bit)
    // N=1, 2line mode  (0= 1line)
    // F=0, 5x8 mode    (1= 5x11)
    // 0x33 = 8bit mode :Puts in 8bit mode and sends the command twice, so should be assured in 8bit mode follow this with 4bit mode
    // 0x28 = 4bit mode, 2line, 5x8
    
    sendCmdLCD(0x33);   // 8bit
    usleep(20000);//20ms
    sendCmdLCD(0x28);   // 4bit
    usleep(20000);//20ms
    sendCmdLCD(0x08);   // display all OFF
    usleep(20000);//20ms
    
}

void LCDDisplayOn()
{
    sendCmdLCD(0x33);   // 8bit
    usleep(20000);//20ms
    sendCmdLCD(0x28);   // 4bit
    usleep(20000);//20ms
    sendCmdLCD(0x0F);   // display all ON
    usleep(20000);//20ms
}


int SpiTXEmpty(int printDbg) 
{
    int val;
    // bit2 = 1 means EMPTY
    // bit2 will be 1 if FIFO has less than THRESHOLD, 0 if more or equal
    // setting THRESHOLD=1(default), makes this an empty flag
    val = Xil_In32(SPI_ADDR + SPI_ISR); 
    if (is_bit_set(val, 2)) {
        if (printDbg) {xil_printf("TX EMPTY\n\r");}
        return XST_SUCCESS;
    } else {
        if (printDbg) {xil_printf("TX NOT empty\n\r");}
        return XST_FAILURE;
    }
}


int SpiRXEmpty(int printDbg)
{
    int val;
    val = Xil_In32(SPI_ADDR + SPI_ISR); 
    if (~is_bit_set(val, 4)) {
        if (printDbg) {xil_printf("RX EMPTY\n\r");}
        return XST_SUCCESS;
    }
    
    // check bit 4 RX_FIFO_not_empty
    while (is_bit_set(val, 4)) {
        val = Xil_In32(SPI_ADDR + SPI_RXD); // RX fifo
        if (printDbg) {xil_printf("RX fifo = 0x%02x\n\r",val);}
        val = Xil_In32(SPI_ADDR + SPI_ISR); 
    }
    return XST_SUCCESS;
}

/*
int SpiTXEmpty(int printDbg) 
{
    int val;
    // bit2 = 1 if FIFO has less than THRESHOLD, 0 if more or equal
    // setting THRESHOLD=1(default), makes this an empty flag if 1
    val = Xil_In32(SPI_ADDR + SPI_ISR); 
    if (~is_bit_set(val, 2)) {
        if (printDbg) {xil_printf("TX NOT EMPTY\n\r");}
        return XST_FAILURE;
    } 
    return XST_SUCCESS;
}


int SpiRXEmpty(int printDbg)
{
    int val;
    val = Xil_In32(SPI_ADDR + SPI_ISR); 
    // bit4 = 0 if FIFO has less than threshold. threshold=1 default makes this in empty flag if 0
    if (is_bit_set(val, 4)) {
        if (printDbg) {xil_printf("RX NOT EMPTY\n\r");}
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}
*/

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


u32 readSpiRXFIFO(int printRX) 
{
    u32 val;
    val = Xil_In32(SPI_ADDR + SPI_RXD); // RX fifo
    if (printRX) {xil_printf("RX fifo = 0x%02x\n\r",val);}
    return val;
}

int is_bit_set(int value, int bit_position) 
{
    return (value & (1 << bit_position)) != 0;
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


