// started with xscugic_low_level_example.c from xilinx 
// /xilinx/Vitis/2023.2/data/embeddedsw/XilinxProcessorIPLib/drivers/scugic_v5_2/examples/
// !! ADG - ripped out all non-SDT stuff


/***************************** Include Files *********************************/

#include <stdio.h>
#include "xparameters.h"
#include "xil_exception.h"
#include "xscugic_hw.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_util.h"
#include "helpFunctions.h"
#include <unistd.h>

#define BD_REG32_ADDR       XPAR_AXIL_REG32_0_BASEADDR
#define CPU_BASEADDR		XPAR_GIC_A53_BASEADDR_1 //0xf9020000 // CPU see UG1087 GIC400 ADG
#define DIST_BASEADDR		XPAR_GIC_A53_BASEADDR   //0xf9010000 // Distributor see UG1087 GIC400 ADG

#define GIC_DEVICE_INT_MASK     0x02010003  /* Bit [25:24] Target list filter, Bit [23:16] 16 = Target CPU iface 0, Bit [3:0] identifies the SFI */
#define XSCUGIC_SW_TIMEOUT_VAL  10000000U   /* Wait for 10 sec */
#define DEFAULT_PRIORITY        0xa0a0a0a0UL
#define DEFAULT_TARGET          0x01010101UL // all CPU0(core0)


static int ScuGicLowLevelExample(u32 CpuBaseAddress, u32 DistBaseAddress);
void LowInterruptHandler(u32 CallbackRef);

volatile static u32 InterruptProcessed = FALSE; //shared variable to be used by the main thread of processing and the interrupt processing

/******************************************************************************/
int main(void)
{
	int Status;
    
    #if defined (__aarch64__)
        xil_printf("__aarch64__\r\n");
    #else 
        xil_printf("NOT aarch64 \r\n");
    #endif
    
    xil_printf("adg Test 0\r\n");
    versionCtrl0();
    //powerOff();

	xil_printf("Low Level GIC Example Test\r\n");
	Status = ScuGicLowLevelExample(CPU_BASEADDR, DIST_BASEADDR);
	/*if (Status != XST_SUCCESS) {
		xil_printf("TIMEOUT\r\n");
		xil_printf("Low Level GIC Example Test Failed\r\n");
		return XST_FAILURE;
	}*/
    
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
        //fflush(stdout);
        usleep(10000);
        powerOff();
        //break;
      } else if (Ch == 'b') {break;
      } else if (Ch == 'a') {
        Xil_Out32(BD_REG32_ADDR + 0x1C, 0x001); // div1 43sec
        Xil_Out32(BD_REG32_ADDR + 0x20, 0x700);// div2 
        Xil_Out32(BD_REG32_ADDR + 0x24, 0x89B);// div3 0x89B ~51Hz?
        Xil_Out32(BD_REG32_ADDR + 0x28, 0x0AC);// div4 yellow ~0.25sec
      } else if (Ch == '0') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x0);
      } else if (Ch == '1') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x1);
      } else if (Ch == '2') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x2);
      } else if (Ch == '3') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x3);
      } else if (Ch == '4') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x4);
      } else if (Ch == '5') {Xil_Out32(BD_REG32_ADDR + 0x2C, 0x5);
      } else if (Ch == 'j') {Xil_Out32(BD_REG32_ADDR + 0x30, 0x1); // int_en; IRQ legacy
      } else if (Ch == 'k') {Xil_Out32(BD_REG32_ADDR + 0x30, 0x0); // int_en; IRQ legacy
      } else if (Ch == 'f') {Xil_Out32(BD_REG32_ADDR + 0x34, 0x1); // int_en (FIQ legacy)
      } else if (Ch == 'g') {Xil_Out32(BD_REG32_ADDR + 0x34, 0x0); // int_en (FIQ legacy)
      }
    }

	//xil_printf("Successfully ran Low Level GIC Example Test\r\n");
    //powerOff();

	return XST_SUCCESS;
}

/******************************************************************************/
static int ScuGicLowLevelExample(u32 CpuBaseAddress, u32 DistBaseAddress)
{
	int Status;
    u32 Int_Id;
/******** DIST *******///GicDistInit(DistBaseAddress);
	
    XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DIST_EN_OFFSET, 0UL); //GICD_CTLR
	
    // starts at Int_Id = 32, so skips GICD_ICFGR0,GICD_ICFGR1 which are Read-Only
    for (Int_Id = 32; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 16) {
        //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0UL);//GICD_ICFGRn level sensitive, N-N model(all CPUs)
		//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0x55555555UL);//GICD_ICFGRn level sensitive, 1-N model(one CPU)
		//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0xFFFFFFFFUL);//0UL);//GICD_ICFGRn //ADG edge sensitive, 1-N model(one CPU)
        XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0xAAAAAAAAUL);//0UL);//GICD_ICFGRn //ADG edge sensitive, N-N model(all CPUs) For PL interrupts
	}
    //ID 122,121 
    

	for (Int_Id = 0; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 4) {
		XScuGic_WriteReg(DistBaseAddress, XSCUGIC_PRIORITY_OFFSET + ((Int_Id * 4) / 4),     DEFAULT_PRIORITY);//GICD_IPRIORITYRn, lower value = greater priority (0=highest priority)
	}
	
    for (Int_Id = 32; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 4) {
		XScuGic_WriteReg(DistBaseAddress, XSCUGIC_SPI_TARGET_OFFSET + ((Int_Id * 4) / 4),   DEFAULT_TARGET);//GICD_ITARGETSRn    //The CPU interface in the spi_target register
	}

    XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DIST_EN_OFFSET, 0x1UL); //GICD_CTLR enable grp0

    XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CPU_PRIOR_OFFSET, 0xFF); //GICC_PMR // xilinx 0xF0, 0xFF worked, 0x00 did not work
	
    XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CONTROL_OFFSET, 0x01UL); //GICC_CTLR enable grp0
	
    //  Connect the interrupt controller interrupt handler to the hardware interrupt handling logic in the ARM processor.
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler) LowInterruptHandler, (void *)CPU_BASEADDR);

	Xil_ExceptionEnable(); // Enable interrupts in the ARM

    /* PL_PS_Group0 ID 121:128
    * 128       - pl_ps_irq0[7]     - GICD_ISENABLER4[0]        (need to verify)
    * 127:121   - pl_ps_irq0[6:0]   - GICD_ISENABLER3[31:25]
    */
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0xFE000000);//GICD_ISENABLER3 // IDs 127:121 = pl_ps_irq0 6:0
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0x02000000);//GICD_ISENABLER3 // ID 121 = pl_ps_irq0 0
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0x06000000);//GICD_ISENABLER3 // ID 122,121 = pl_ps_irq0 1:0
    XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0x0E000000);//GICD_ISENABLER3 // ID 123,122,121 = pl_ps_irq0 2:0

    /* PL_PS_Group1 136:143
    * 143:136   - pl_ps_irq1[7:0]   -GICD_ISENABLER4[15:8]
    */
    XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0x10, 0x00000700);//GICD_ISENABLER4 // ID 138,137,136 = pl_ps_irq1 2:0

	return XST_SUCCESS;
}

/*****************************************************************************/
// IRQ
void LowInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;

	BaseAddress = CallbackRef;
        
	IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) & XSCUGIC_ACK_INTID_MASK;//GICC_IAR    //Read the int_ack register to identify the interrupt and make sure it is valid
     
	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
        xil_printf("INTERRUPT HANDLER FAIL. IntID = 0x%x (%u)\r\n",IntID,IntID);
        return;
    }
    
	InterruptProcessed = 1; //Execute the ISR. For this example set the global to 1. The software trigger is cleared by the ACK.

	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);//GICC_EOIR    //Write to the EOI register, we are all done here.Let this function return, the boot code will restore the stack.

    xil_printf("INTERRUPT HANDLER done. IntID = 0x%x (%u)\r\n",IntID,IntID); // generally don't put prints in interrupt handler?

}

