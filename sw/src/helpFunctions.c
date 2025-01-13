
#include "helpFunctions.h"
#include <stdio.h>
#include "xil_printf.h"
#include <xil_io.h>
#include "xparameters.h"

#define PL_REG32_ADDR  XPAR_AXIL_REG32_0_BASEADDR


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
    xil_printf("  Git Hash: %x%x\n\r",gitM,gitL);
    xil_printf("  TIMESTAMP:%x = %d/%d/%d - %d:%d:%d\n\r",timeStamp,mon,day,yr,hr,min,sec);
    xil_printf("****************************************\n\r\n\r");

}
