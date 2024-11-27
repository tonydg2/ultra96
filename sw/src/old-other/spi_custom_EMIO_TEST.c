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

#define SPI1_ADDR   XPAR_XSPIPS_1_BASEADDR
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

u8 SpiRegAddrsRD[] = {SPI_CFG, SPI_ISR, SPI_IER, SPI_IDR, SPI_IMR, 
                    SPI_EN, SPI_DLY, 
                    //SPI_TXD, 
                    //SPI_RXD, 
                    SPI_SIC, SPI_TXTHR, SPI_RXTHR, SPI_MODID};


#define BUFFER_SIZE 3
typedef u8 SPI0_DataBuffer[BUFFER_SIZE];

int SpiCustom0(void);
void readSpi(u8 addr);
void writeSpi(u8 addr, u32 data);
void writeSpiBit(u8 addr, int bitVal, int bitIdx);
void readSpiAll();
void checkSpiRX();
int is_bit_set(int value, int bit_position);
void CS_ON();   //only CS0
void CS_OFF();  //only CS0
void CS_Assert(int CSval);
void CS_Deassert();
void SPI_Start();
void writeSpiTX();
int SpiTXEmpty();
void readSpiRXFIFO();

int main()
{
    init_platform();
    xil_printf("\n\rtesting adg1234\n\r");
    //check0();    
    versionCtrl();
    
    int Status;

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
      } else if (Ch == 'b') {break;
      } else if (Ch == 'c') {Status = SpiCustom0(); //emio
      } else if (Ch == 'd') {readSpiAll();
        //Status = SpiCustom0(&SpiInstance, XPAR_XSPIPS_0_BASEADDR);
      } else if (Ch == 'e') {   checkSpiRX();
      } else if (Ch == 'f') {   readSpiRXFIFO();
      } else if (Ch == 'g') {   Xil_Out32(BD_REG32_ADDR + 0x74, 0x1); //29 td0
      } else if (Ch == 'h') {   Xil_Out32(BD_REG32_ADDR + 0x78, 0x3); //31 td1
      } else if (Ch == 'i') {   Xil_Out32(BD_REG32_ADDR + 0x74, 0x7); //29 td0
      } else if (Ch == 'j') {   Xil_Out32(BD_REG32_ADDR + 0x78, 0x7); //31 td1
      } else if (Ch == 'k') {   Xil_Out32(BD_REG32_ADDR + 0x74, 0x6); //29 td0
      } else if (Ch == 'l') {   Xil_Out32(BD_REG32_ADDR + 0x78, 0x9); //31 td1
      } else if (Ch == 'm') {   Xil_Out32(BD_REG32_ADDR + 0x74, 0xa); //29 td0
      } else if (Ch == 'n') {   Xil_Out32(BD_REG32_ADDR + 0x78, 0xb); //31 td1
      } else if (Ch == 'o') {   Xil_Out32(BD_REG32_ADDR + 0x74, 0xf); //29 td0
      } else if (Ch == 'q') {   Xil_Out32(BD_REG32_ADDR + 0x78, 0xe); //31 td1
      } else if (Ch == 'r') {   
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

int SpiCustom0(void)
{
    int val,x;
    // SPI_CFG, SPI_ISR, SPI_IER, SPI_IDR, SPI_IMR,   SPI_EN   
    // SPI_DLY, SPI_TXD, SPI_RXD, SPI_SIC, SPI_TXTHR, SPI_RXTHR, SPI_MODID

    writeSpi(SPI_EN, 0x0);
    readSpi(SPI_ISR);
    readSpi(SPI_RXD);
    //writeSpi(SPI_ISR, 0x0);// clear mode fault bit1
    //writeSpi(SPI_CFG, 0x0); //enable mode fail bit17    0x20000

    //writeSpi(SPI_CFG, 0x27C29); //  auto start, manual CS, CS inactive, BAUD64, CLK_PH=0, CLK_POL=0,  MASTER mode
    writeSpi(SPI_CFG, 0x2FC29); //  manual start, manual CS, CS inactive, BAUD64, CLK_PH=0, CLK_POL=0, MASTER mode
    //writeSpi(SPI_CFG, 0x2FC2B); //  manual start, manual CS, CS inactive, BAUD64, CLK_PH=0, CLK_POL=1, MASTER mode
    //writeSpi(SPI_CFG, 0x2FC2D); //  manual start, manual CS, CS inactive, BAUD64, CLK_PH=1, CLK_POL=0, MASTER mode

    //writeSpi(SPI_EN, 0x1);// enable
    //writeSpiBit(SPI_CFG, 0, 10); // bit 10 CS0 enable
    //writeSpiBit(SPI_CFG, 1, 10); // bit 10 CS0 disable
    
    writeSpi(SPI_TXTHR, 0x1);//set TX threshold 
    
    writeSpi(SPI_EN, 0x1);// enable

    checkSpiRX();
    readSpiRXFIFO();
    SpiTXEmpty();

    Xil_Out32(SPI1_ADDR + SPI_TXD, 0x41);// TX
    Xil_Out32(SPI1_ADDR + SPI_TXD, 0x01);// TX
    Xil_Out32(SPI1_ADDR + SPI_TXD, 0x00);// TX
    Xil_Out32(SPI1_ADDR + SPI_TXD, 0x00);// TX


    //CS_ON(); // CS0 enable
    SpiTXEmpty();
    xil_printf("SPI transfer...\n\r");
    CS_Assert(0);
    SPI_Start();
    x=0;
    while (1) {
        xil_printf("Check TX empty %d\r\n",x);
        x++;
        val = SpiTXEmpty();
        if (val == 1) {
            CS_Deassert();
            break;
        }
        usleep(1000);//1ms
    }
    //usleep(1000);//1ms
    //CS_OFF();
    checkSpiRX();
    for (int x = 0;x < 5;x++){readSpiRXFIFO();}

    checkSpiRX();
    SpiTXEmpty();

    /*********************************************************************************************/
    xil_printf("----------------------------------------\n\r\n\r");
    return XST_SUCCESS;
}


/*********************************************************************************************/
//
/*********************************************************************************************/
int SpiTXEmpty() 
{
    int val;
    // bit2 will be 1 if FIFO has less than THRESHOLD, 0 if more or equal
    // setting THRESHOLD=1(default), makes this an empty flag
    val = Xil_In32(SPI1_ADDR + SPI_ISR); 
    if (is_bit_set(val, 2)) {
        xil_printf("TX EMPTY\n\r");
        return 1;
    } else {
        xil_printf("TX NOT empty\n\r");
        return 0;
    }
}

void readSpi(u8 addr)
{
    int val;
    val = Xil_In32(SPI1_ADDR + addr);
    xil_printf("Addr %x = %x\n\r",addr,val);
}

void writeSpi(u8 addr, u32 data)
{
    int val;
    Xil_Out32(SPI1_ADDR + addr,data);
    val = Xil_In32(SPI1_ADDR + addr);
    xil_printf("Verified WR Addr %x = %x\n\r",addr,val);
}

void writeSpiBit(u8 addr, int bitVal, int bitIdx)
{
    int val;
    val = Xil_In32(SPI1_ADDR + addr);

    if (bitVal == 0) {
        val &= ~(1 << bitIdx); // clear the bit
    } else {
        val |= (1 << bitIdx);  // set the bit
    }

    Xil_Out32(SPI1_ADDR + addr,val);
    val = Xil_In32(SPI1_ADDR + addr);
    xil_printf("Verified bitIDX %d WR Addr %x = %x\n\r",bitIdx,addr,val);

}

void readSpiAll()
{
    int val;

    for (unsigned long i = 0; i < sizeof(SpiRegAddrsRD); i++) {
        val = Xil_In32(SPI1_ADDR + SpiRegAddrsRD[i]);
        xil_printf("Addr %x = %x\n\r",SpiRegAddrsRD[i],val);
    }

}

void checkSpiRX()
{
    int val;
    val = Xil_In32(SPI1_ADDR + SPI_ISR); 
    if (~is_bit_set(val, 4)) {
        xil_printf("RX EMPTY\n\r");
        return;
    }
    // check bit 4 RX_FIFO_not_empty
    while (is_bit_set(val, 4)) {
        val = Xil_In32(SPI1_ADDR + SPI_RXD); // RX fifo
        xil_printf("RX fifo = %x\n\r",val);
        val = Xil_In32(SPI1_ADDR + SPI_ISR); 
    }
}

void readSpiRXFIFO() 
{
    int val;
    val = Xil_In32(SPI1_ADDR + SPI_RXD); // RX fifo
    xil_printf("RX fifo = %x\n\r",val);
}

void writeSpiTX()
{

}

int is_bit_set(int value, int bit_position) 
{
    return (value & (1 << bit_position)) != 0;
}

void CS_ON() {
    writeSpiBit(SPI_CFG, 0, 10); // bit 10 CS0 enable active-low
}

void CS_OFF() {
    writeSpiBit(SPI_CFG, 1, 10); // bit 10 CS0 disable active-low
}

void SPI_Start() {
    writeSpiBit(SPI_CFG, 1, 16); // write a 1 to bit 16
}

void CS_Assert(int CSval)
{
    switch (CSval) {
        case 0: 
            writeSpiBit(SPI_CFG, 0, 10); // bit 10 CS0 enable active-low
            break;
        case 1: 
            writeSpiBit(SPI_CFG, 0, 11); // CS1
            break;
        case 2: 
            writeSpiBit(SPI_CFG, 0, 12); // CS2
            break;
        default: break;
    }
}

void CS_Deassert()
{
    int val;
    val = Xil_In32(SPI1_ADDR + SPI_CFG); //get current
    val |= (0xF << 10); //set all CS high to disable
    Xil_Out32(SPI1_ADDR + SPI_CFG,val);
}


