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
#include <xstatus.h>
#include "xspips.h"		/* SPI device driver */
//#include "xuartlite_l.h"
#include "xuartps_hw.h"

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

#define CMD_READ    1
#define CMD_WRITE   0


#define CTRL1_XL    0x10
#define CTRL2_G     0x11
#define STATUS_REG  0x1E
#define OUT_TEMP_L  0x20
#define OUT_TEMP_H  0x21
#define OUTX_L_G    0x22
#define OUTX_H_G    0x23
#define OUTY_L_G    0x24
#define OUTY_H_G    0x25
#define OUTZ_L_G    0x26
#define OUTZ_H_G    0x27
#define OUTX_L_XL   0x28
#define OUTX_H_XL   0x29
#define OUTY_L_XL   0x2A
#define OUTY_H_XL   0x2B
#define OUTZ_L_XL   0x2C
#define OUTZ_H_XL   0x2D

#define myUartAddr  STDIN_BASEADDRESS

u8 SpiRegAddrsRD[] = {SPI_CFG, SPI_ISR, SPI_IER, SPI_IDR, SPI_IMR, 
                    SPI_EN, SPI_DLY, 
                    //SPI_TXD, 
                    //SPI_RXD, 
                    SPI_SIC, SPI_TXTHR, SPI_RXTHR, SPI_MODID};


#define BUFFER_SIZE 3
typedef u8 SPI0_DataBuffer[BUFFER_SIZE];

u8 SpiCmd(u8 deviceRegAddr, int RW, u8 data0);
void readSpi(u8 addr, int printDbg);
void writeSpi(u8 addr, u32 data, int printDbg);
void writeSpiBit(u8 addr, int bitVal, int bitIdx, int printDbg);
void readSpiAll();
void checkSpiRX(int printDbg);
int is_bit_set(int value, int bit_position);
void CS_Assert(int CSval);
void CS_Deassert();
void SPI_Start();
int SpiTXEmpty(int printDbg);
u32 readSpiRXFIFO(int printRX);
void whoAmI();
void gyroRead();
void accelRead();
void tempRead();
void LSMConfig();

int main()
{
    init_platform();
    int Status, loopTemp=0,loopGyro=0,loopAccel=0;
    u32 data;
    u8 Ch;

    xil_printf("\n\rtesting adg 666\n\r");
    //check0();    
    versionCtrl();
    
    whoAmI(); // gyro device
    LSMConfig(); // config, enable gyro/accel/temp

    xil_printf("Running...\r\n");
    
    while (1) {
        
        if (XUartPs_IsReceiveData(XPAR_XUARTPS_1_BASEADDR)) {
            data = XUartPs_ReadReg(XPAR_XUARTPS_1_BASEADDR, XUARTPS_FIFO_OFFSET);
            Ch = data;
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
            } else if (Ch == 'c') {   SpiCmd(0x01,CMD_READ,0); //emio
            } else if (Ch == 'd') {   readSpiAll();
            } else if (Ch == 'e') {   checkSpiRX(0);
            } else if (Ch == 'f') {   readSpiRXFIFO(1);
            } else if (Ch == 'g') {   SpiCmd(0x05,CMD_READ,0);
            } else if (Ch == 'h') {   SpiCmd(0x0A,CMD_READ,0);
            } else if (Ch == 'i') {   
            } else if (Ch == 'j') {   whoAmI();
            } else if (Ch == 'k') {   accelRead();
            } else if (Ch == 'l') {   gyroRead();
            } else if (Ch == 'm') {   tempRead(); // 65-70F = 18-21C
            } else if (Ch == 'n') {   
            } else if (Ch == 'o') {   loopTemp = 1;
            } else if (Ch == 'q') {   loopTemp = 0;
            } else if (Ch == 'r') {   loopGyro = 1;
            } else if (Ch == 's') {   loopGyro = 0;
            } else if (Ch == 't') {   loopAccel= 1;
            } else if (Ch == 'u') {   loopAccel= 0;
            } else if (Ch == 'v') {   
            }
        }
        if (loopTemp)   {tempRead();}
        if (loopGyro)   {gyroRead();}
        if (loopAccel)  {accelRead();}
        
        //sleep(1);
    }
    xil_printf("\n\r----------------------------------------\n\r");
    xil_printf("** END **\n\r");
    xil_printf("----------------------------------------\n\r\n\r");

    cleanup_platform();
    
    return 0;
}

// LSM6DSL 
void LSMConfig() {
    /*  CTRL1_XL (10h)  accel ODR_XL=0101   0x50
        CTRL2_G  (11h)   gyro  ODR_G=0101    0x50
        
    */
    SpiCmd(CTRL1_XL,CMD_WRITE,0x50);
    SpiCmd(CTRL2_G,CMD_WRITE,0x50);

}

void gyroRead() {
    /*  0x1E - STATUS_REG  [2:0] = TDA,GDA,XLDA = new data avalable temp,gyro,accel
        0x20 - OUT_TEMP_L  [7:0] temp
        0x21 - OUT_TEMP_H  [15:8] two's comp sign extended on MSB
        0x22 - OUTX_L_G    [7:0]    Angular rate(gyro) pitch axis
        0x23 - OUTX_H_G    [15:0] 
        0x24 - OUTY_L_G             roll axis
        0x25 - OUTY_H_G             
        0x26 - OUTZ_L_G             yaw
        0x27 - OUTZ_H_G             
        0x28 - OUTX_L_XL            Accel 
        0x29 - OUTX_H_XL            
        0x2A - OUTY_L_XL            
        0x2B - OUTY_H_XL            
        0x2C - OUTZ_L_XL            
        0x2D - OUTZ_H_XL            
    */
    u8 dataH,dataL;
    s16 gyroX,gyroY,gyroZ;
    //dataL = SpiCmd(STATUS_REG,CMD_READ,0);
    //xil_printf("STATUS_REG = %x\n\r",dataL);

    dataL = SpiCmd(OUTX_L_G,CMD_READ,0);
    //xil_printf("OUTX_L_G = %x\n\r",dataL);
    dataH = SpiCmd(OUTX_H_G,CMD_READ,0);
    //xil_printf("OUTX_H_G = %x\n\r",dataH);
    gyroX = (dataH << 8) | dataL;
    xil_printf("gyroX = %d\n\r",gyroX);

    dataL = SpiCmd(OUTY_L_G,CMD_READ,0);
    //xil_printf("OUTY_L_G = %x\n\r",dataL);
    dataH = SpiCmd(OUTY_H_G,CMD_READ,0);
    //xil_printf("OUTY_H_G = %x\n\r",dataH);
    gyroY = (dataH << 8) | dataL;
    xil_printf("gyroY = %d\n\r",gyroY);

    dataL = SpiCmd(OUTZ_L_G,CMD_READ,0);
    //xil_printf("OUTZ_L_G = %x\n\r",dataL);
    dataH = SpiCmd(OUTZ_H_G,CMD_READ,0);
    //xil_printf("OUTZ_H_G = %x\n\r",dataH);
    gyroZ = (dataH << 8) | dataL;
    xil_printf("gyroZ = %d\n\r",gyroZ);

}

void accelRead() {
    /*  0x1E - STATUS_REG  [2:0] = TDA,GDA,XLDA = new data avalable temp,gyro,accel
        0x20 - OUT_TEMP_L  [7:0] temp
        0x21 - OUT_TEMP_H  [15:8] two's comp sign extended on MSB
        0x22 - OUTX_L_G    [7:0]    Angular rate(gyro) pitch axis
        0x23 - OUTX_H_G    [15:0] 
        0x24 - OUTY_L_G             roll axis
        0x25 - OUTY_H_G             
        0x26 - OUTZ_L_G             yaw
        0x27 - OUTZ_H_G             
        0x28 - OUTX_L_XL            Accel 
        0x29 - OUTX_H_XL            
        0x2A - OUTY_L_XL            
        0x2B - OUTY_H_XL            
        0x2C - OUTZ_L_XL            
        0x2D - OUTZ_H_XL            
    */
    u8 dataH,dataL;
    s16 accX,accY,accZ;

    //dataL = SpiCmd(STATUS_REG,CMD_READ,0);
    //xil_printf("STATUS_REG = %x\n\r",dataL);

    dataL = SpiCmd(OUTX_L_XL,CMD_READ,0);
    //xil_printf("OUTX_L_XL = %x\n\r",dataL);
    dataH = SpiCmd(OUTX_H_XL,CMD_READ,0);
    //xil_printf("OUTX_H_XL = %x\n\r",dataH);
    accX = (dataH << 8) | dataL;
    xil_printf("accX = %d\n\r",accX);

    dataL = SpiCmd(OUTY_L_XL,CMD_READ,0);
    //xil_printf("OUTY_L_XL = %x\n\r",dataL);
    dataH = SpiCmd(OUTY_H_XL,CMD_READ,0);
    //xil_printf("OUTY_H_XL = %x\n\r",dataH);
    accY = (dataH << 8) | dataL;
    xil_printf("accY = %d\n\r",accY);

    dataL = SpiCmd(OUTZ_L_XL,CMD_READ,0);
    //xil_printf("OUTZ_L_XL = %x\n\r",dataL);
    dataH = SpiCmd(OUTZ_H_XL,CMD_READ,0);
    //xil_printf("OUTZ_H_XL = %x\n\r",dataH);
    accZ = (dataH << 8) | dataL;
    xil_printf("accZ = %d\n\r",accZ);

}

// 25C = 0, 256 LSB/C...
void tempRead() {
    /*  0x1E - STATUS_REG  [2:0] = TDA,GDA,XLDA = new data avalable temp,gyro,accel
        0x20 - OUT_TEMP_L  [7:0] temp
        0x21 - OUT_TEMP_H  [15:8] two's comp sign extended on MSB
    */
    u8 dataH,dataL;
    s16 temp;
    //dataL = SpiCmd(STATUS_REG,CMD_READ,0);
    //xil_printf("STATUS_REG = %x\n\r",dataL);

    dataL = SpiCmd(OUT_TEMP_L,CMD_READ,0);
    //xil_printf("OUT_TEMP_L = %x\n\r",dataL);
    dataH = SpiCmd(OUT_TEMP_H,CMD_READ,0);
    //xil_printf("OUT_TEMP_H = %x\n\r",dataH);

    temp = (dataH << 8) | dataL;
    //xil_printf("Temp = 0x%04x, %d\n\r",temp,temp);
    
    int tempC,tempF;
    tempC = temp/256 + 25;
    tempF = (tempC * (1.8)) + 32;
    xil_printf("temp = %dC (%dF)\n\r",tempC,tempF);

    sleep(1);
}

/* loop until user types 'b'    UART INPUT DOESN'T WORK...
void loopTemp() {
    u32 data;
    u8 dataH,dataL;
    s16 temp;
    u8 inChar;

    while (1) {
        if (!XUartPs_IsReceiveData(XPAR_XUARTPS_1_BASEADDR)) {
            xil_printf("debug\n\r");
            //inChar = XUartPs_ReadReg(XPAR_XUARTPS_1_BASEADDR, XUL_RX_FIFO_OFFSET);
            data = XUartPs_ReadReg(XPAR_XUARTPS_1_BASEADDR, XUARTPS_FIFO_OFFSET);
            xil_printf("inChar = %x\n\r",data);
            //if (inChar == '\r') {XUartLite_SendByte(XPAR_XUARTPS_1_BASEADDR,'\n');}
            //XUartLite_SendByte(XPAR_XUARTPS_1_BASEADDR,inChar);
            //if (inChar == 'b') {return;}
        }
        dataL = SpiCmd(OUT_TEMP_L,CMD_READ,0);
        dataH = SpiCmd(OUT_TEMP_H,CMD_READ,0);

        temp = (dataH << 8) | dataL;
        xil_printf("Temp = 0x%04x, %d\n\r",temp,temp);
        //usleep();
        //msleep();
        sleep(2);
    }
}
*/

// should return 0x6A
void whoAmI() {
    u8 data;
    data = SpiCmd(0x0F,CMD_READ,0);
    
    if (data != 0x6A) {
        xil_printf("ERROR reading WHO_AM_I ID. data = %x\n\r",data);
    } else {
        xil_printf("SUCCESS WHO_AM_I ID = %x\n\r",data);
    }

}

u8 SpiCmd(u8 deviceRegAddr, int RW, u8 data0)
{
    int val;
    u32 rdata, readData;

    writeSpi(SPI_EN, 0x0, 0);
    readSpi(SPI_ISR, 0);
    readSpi(SPI_RXD, 0);
    //writeSpi(SPI_ISR, 0x0);// clear mode fault bit1
    //writeSpi(SPI_CFG, 0x0); //enable mode fail bit17    0x20000

    writeSpi(SPI_CFG, 0x2FC29, 0); //  manual start, manual CS, CS inactive, BAUD64, CLK_PH=0, CLK_POL=0, MASTER mode
    writeSpi(SPI_TXTHR, 0x1, 0);//set TX threshold 
    writeSpi(SPI_EN, 0x1, 0);// enable

    checkSpiRX(0);
        
    rdata = readSpiRXFIFO(0);
    if (rdata != 0x00) {
        xil_printf("ERROR PRE verifying empty RX : 0x%2x\n\r",rdata);
        return 0xFFFFFFFF;
    }

    SpiTXEmpty(0);

    // RW, Write = 0, Read = 1
    Xil_Out32(SPI_ADDR + SPI_TXD, (deviceRegAddr | (RW << 7))); // command = {RW & addr[6:0]} 
    Xil_Out32(SPI_ADDR + SPI_TXD, data0);           // TX

    SpiTXEmpty(0);
    //xil_printf("SPI transfer...\n\r");
    CS_Assert(0);
    SPI_Start();
    while (1) {
        val = SpiTXEmpty(0);
        if (val == 1) {
            CS_Deassert();
            break;
        }
//        usleep(20000);//20ms
    }

    checkSpiRX(0);
    readSpiRXFIFO(0); // TX command word

    // RW, Write = 0, Read = 1
    if (RW == 1) {
        //xil_printf("\n\rREAD RX addr 0x%02x\n\r",deviceRegAddr);
        for (int x = 0;x < 1;x++){readData = readSpiRXFIFO(0);} // read words
    } else if (RW == 0) {
        //xil_printf("\n\r WRITE addr 0x%02x, data 0x%02x\n\r",deviceRegAddr,data0);
        for (int x = 0;x < 1;x++){readSpiRXFIFO(0);} // write words
    } else {
        xil_printf("\n\r Error command = 0x%02x\n\r",RW);
    }

    rdata = readSpiRXFIFO(0);
    if (rdata != 0x00) {
        xil_printf("ERROR POST verifying empty RX : 0x%2x\n\r",rdata);
        return 0xFFFFFFFF;
    }

    checkSpiRX(0);
    SpiTXEmpty(0);

    /*********************************************************************************************/
    //xil_printf("----------------------------------------\n\r\n\r");
    return readData; // only 8bits out of fifo
}


/*********************************************************************************************/
//
/*********************************************************************************************/

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

