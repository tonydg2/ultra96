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
void IRQInterruptHandler(u32 CallbackRef);
void FIQInterruptHandler(u32 CallbackRef);

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
    Xil_Out32(BD_REG32_ADDR + 0x30, 0x1); // int_en (IRQ legacy)
    Xil_Out32(BD_REG32_ADDR + 0x34, 0x1); // int_en (FIQ legacy)

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
	
	/* GICD_ICFGRn = level/edge sensitity. GICD_ICFGR0,GICD_ICFGR1 which are Read-Only for SGIs & PPIs (legacy IRQ/FIQ)
    *   PPIs (legacy IRQ/FIQ) IRQ ID=31, FIQ=28
    * No need to write GICD_ICFGRn for legacy IRQ/FIQ, they are level-sensitive and can't be changed. Active-low INTERNALLY, at the PL level
    * going into the PS they are ACTIVE-HIGH (inverted internally). Make them active-HIGH in the PL. Has Width requirements, in UG somewhere can't remember which UG...
    */

    /* GICD_IPRIORITYRn = int priority. worked as-is with defaults without writing. See ARM docs, I believe legacy IRQ/FIQ "bypasses" the DIST...?
    *  GICD_ITARGETSRn = CPU target.  worked as-is with defaults without writing
    */

    /*GICD_ICENABLERn writing 1's will DISABLE. left default
    */

    /* GICD_CTLR = enable grp0/grp1. left default all disabled - doesn't matter for legacy IRQ/FIQ bypass 
    */   

    /* GICC_PMR = priorities allowed to pass. not needed for legacy FIQ/IRQ
    * //XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CPU_PRIOR_OFFSET, 0xFF); //GICC_PMR = priorities allowed to pass // xilinx 0xF0, 0xFF worked, 0x00 did not work
    */
    
    /* GICC_CTLR enable grp0/grp1, etc. 0 for bypass, leave 0 default
    * //XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CONTROL_OFFSET, 0x0UL); //GICC_CTLR legacy IRQ test
    */

    /* GICD_ISENABLER0 = interrupt enables contains legacy FIQ/IRQ 
    * Was not necessary to write or enable FIQ/IRQ - worked automatically by default (exptected out of reset, see ARM datasheet)
    * IRQ/FIQ one per CPU(core). IRQ=31, FIQ=28 (0x80000000, 0x10000000, 0x90000000)
    * //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET, 0x10000000);//GICD_ISENABLER0 //legacy IRQ
    */
    
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_FIQ_INT, (Xil_ExceptionHandler) FIQInterruptHandler, (void *)CPU_BASEADDR); // Legacy FIQ test
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler) IRQInterruptHandler, (void *)CPU_BASEADDR); // Legacy IRQ test
    //Xil_ExceptionEnableMask(XREG_CPSR_FIQ_ENABLE); // this works for FIQ
    //Xil_ExceptionEnableMask(XREG_CPSR_IRQ_ENABLE); // this works for IRQ
    Xil_ExceptionEnableMask(XIL_EXCEPTION_ALL); 
    /* NOTE. this works with both FIQ and IRQ legacy pins. NOTE: my test has the exact same interrupt going to both IRQ and FIQ. FIQ took priority and NO IRQ handler ran until disabling the FIQ interrupt in the PL
    */

	return XST_SUCCESS;
}

/*****************************************************************************/
// IRQ
void IRQInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;
    u32 val;

	BaseAddress = CallbackRef;

    val = Xil_In32(BD_REG32_ADDR + 0x38); // clear the IRQ and get count
    xil_printf("IRQ Count = %x\r\n",val);
        
	/* for IRQ/FIQ will always return spurious interrupt ID 0x3FF (1023) */
    IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) & XSCUGIC_ACK_INTID_MASK;//GICC_IAR    //Read the int_ack register to identify the interrupt and make sure it is valid
     
	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
        xil_printf("INTERRUPT HANDLER IRQ. IntID = 0x%x (%u)\r\n",IntID,IntID);
        return;
    }
    
	InterruptProcessed = 1; //Execute the ISR. For this example set the global to 1. The software trigger is cleared by the ACK.

	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);//GICC_EOIR    //Write to the EOI register, we are all done here.Let this function return, the boot code will restore the stack.

    xil_printf("INTERRUPT HANDLER done. IntID = 0x%x (%u)\r\n",IntID,IntID); // generally don't put prints in interrupt handler?

}

void FIQInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;
    u32 val;

	BaseAddress = CallbackRef;

    val = Xil_In32(BD_REG32_ADDR + 0x3C); // clear the FIQ and get count
    xil_printf("FIQ Count = %x\r\n",val);

    /* for IRQ/FIQ will always return spurious interrupt ID 0x3FF (1023) */
	IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) & XSCUGIC_ACK_INTID_MASK;//GICC_IAR    //Read the int_ack register to identify the interrupt and make sure it is valid
     
	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
        xil_printf("INTERRUPT HANDLER FIQ. IntID = 0x%x (%u)\r\n",IntID,IntID);
        return;
    }
    
	InterruptProcessed = 1; //Execute the ISR. For this example set the global to 1. The software trigger is cleared by the ACK.

	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);//GICC_EOIR    //Write to the EOI register, we are all done here.Let this function return, the boot code will restore the stack.

    xil_printf("INTERRUPT HANDLER done. IntID = 0x%x (%u)\r\n",IntID,IntID); // generally don't put prints in interrupt handler?

}
