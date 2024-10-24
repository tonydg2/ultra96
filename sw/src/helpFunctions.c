
#include "helpFunctions.h"
#include <stdio.h>
#include "xil_printf.h"
#include <xil_io.h>
#include "xparameters.h"

#define PL_REG32_ADDR   XPAR_AXIL_REG32_0_BASEADDR
#define GPIO_MIO_ADDR   XPAR_GPIO_BASEADDR

#define MIO_WR_26_51_OFFSET     0x44
#define MIO_RD_26_51_OFFSET     0x64
#define MIO_DIRM_1              0x244
#define MIO_OEN_1               0x248


void versionCtrl0(void) {

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

    xil_printf("\n\r************ PL VERSION ****************\n\r");
    xil_printf("  TIMESTAMP:%0x = %0d/%0d/%0d - %0d:%0d:%0d\n\r",timeStamp,mon,day,yr,hr,min,sec); // 0's mean zero padded on left (UG643)
    xil_printf("  Git Hash: %0x%0x\n\r",gitM,gitL);
    xil_printf("  %0x_%0x\n\r",timeStamp,gitM);
    xil_printf("****************************************\n\r\n\r");

}

void powerOff(void) {
    int shift, mask, val, pwrRD, pwrWR, pwrOFF;
    
    shift = 8;
    mask = 0x1 << shift; // 1bits
    val = 0x1 << shift; // set output and enable
    pwrOFF = 0x0 << shift;
    pwrRD = Xil_In32(GPIO_MIO_ADDR + MIO_DIRM_1);
    //xil_printf("pwrRD = %x\n\r",pwrRD);
    pwrWR = (pwrRD & ~mask) | (val & mask);
    //xil_printf("pwrWR = %x\n\r",pwrWR);
    Xil_Out32(GPIO_MIO_ADDR + MIO_DIRM_1,pwrWR);

    pwrRD = Xil_In32(GPIO_MIO_ADDR + MIO_OEN_1);
    //xil_printf("pwrRD = %x\n\r",pwrRD);
    pwrWR = (pwrRD & ~mask) | (val & mask);
    //xil_printf("pwrWR = %x\n\r",pwrWR);
    Xil_Out32(GPIO_MIO_ADDR + MIO_OEN_1,pwrWR);

    pwrRD = Xil_In32(GPIO_MIO_ADDR + MIO_RD_26_51_OFFSET);
    //xil_printf("pwrRD = %d\n\r",val);
    pwrWR = (pwrRD & ~mask) | (pwrOFF & mask);
    Xil_Out32(GPIO_MIO_ADDR + MIO_WR_26_51_OFFSET,pwrWR);

}