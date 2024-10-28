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
void FIQInterruptHandler(u32 CallbackRef);

void readSomeGicRegs(u32 CpuBaseAddress, u32 DistBaseAddress);

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
    //Xil_Out32(BD_REG32_ADDR + 0x30, 0x1); // int_en (IRQ legacy)
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
/******** DIST *******///GicDistInit(DistBaseAddress);
	
//    XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DIST_EN_OFFSET, 0UL); //GICD_CTLR
	
    /*/ starts at Int_Id = 32, so skips GICD_ICFGR0,GICD_ICFGR1 which are Read-Only
    for (Int_Id = 32; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 16) {
		// don't write, leave default for PL legacy IRQ/FIQ...?

        //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0UL);//GICD_ICFGRn level sensitive, N-N model(all CPUs)
		//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0x55555555UL);//GICD_ICFGRn level sensitive, 1-N model(one CPU)
		//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0xFFFFFFFFUL);//0UL);//GICD_ICFGRn //ADG edge sensitive, 1-N model(one CPU)
        //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_INT_CFG_OFFSET + (Int_Id * 4) / 16,       0xAAAAAAAAUL);//0UL);//GICD_ICFGRn //ADG edge sensitive, N-N model(all CPUs) For PL interrupts
	}
    //ID 122,121 */
    

	for (Int_Id = 0; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 4) {
		XScuGic_WriteReg(DistBaseAddress, XSCUGIC_PRIORITY_OFFSET + ((Int_Id * 4) / 4),     DEFAULT_PRIORITY);//GICD_IPRIORITYRn, lower value = greater priority (0=highest priority)
	}
	
    for (Int_Id = 32; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 4) {
		XScuGic_WriteReg(DistBaseAddress, XSCUGIC_SPI_TARGET_OFFSET + ((Int_Id * 4) / 4),   DEFAULT_TARGET);//GICD_ITARGETSRn    //The CPU interface in the spi_target register
	}

    /*for (Int_Id = 0; Int_Id < XSCUGIC_MAX_NUM_INTR_INPUTS; Int_Id += 32) {
		XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DISABLE_OFFSET + ((Int_Id * 4) / 32), 0x0UL);//0xFFFFFFFFUL);//GICD_ICENABLERn writing 1's will DISABLE, //Enable the SPI using the enable_set register. Leave all disabled for now.
	}*/
	
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DIST_EN_OFFSET, 0x1UL); //GICD_CTLR enable grp0
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DIST_EN_OFFSET, 0x2UL); //GICD_CTLR enable grp1
	//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DIST_EN_OFFSET, 0x0UL);  //GICD_CTLR disabled
	//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_DIST_EN_OFFSET, 0x3UL);  //GICD_CTLR enable grp0 and grp1


/******** CPU *******///GicCPUInit(CpuBaseAddress);
	// GICC_CTLR = 0 for bypass (legacy IRQ)...?
    // priority mask GICC_PMR, seems 'backwards' based on ARM GIC400 spec: "if the priority of an interrupt is higher than the value indicated by this field, the interface signals the interrupt to the processor"
    // I would infer setting to 0 means all priorities allowed. Inverse, see ARM datasheet
    XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CPU_PRIOR_OFFSET, 0xFF); //GICC_PMR // xilinx 0xF0, 0xFF worked, 0x00 did not work
	
    //XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CONTROL_OFFSET, 0x01UL); //GICC_CTLR enable grp0
    //XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CONTROL_OFFSET, 0x0UL); //GICC_CTLR bypass for IRQ
    XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CONTROL_OFFSET, 0x0UL); //GICC_CTLR legacy IRQ test
    //XScuGic_WriteReg(CpuBaseAddress, XSCUGIC_CONTROL_OFFSET, 0x3UL); //GICC_CTLR enable grp0 and grp1

/******** Setup *******///SetupInterruptSystem();    //connect the handler for the interrupt controller to the interrupt source for the processor
	
    /* this used to be AFTER Xil_ExceptionEnable() below */
    // IRQ/FIQ one per CPU(core). IRQ=31, FIQ=28 (0x80000000, 0x10000000, 0x90000000)
    XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET, 0x10000000);//GICD_ISENABLER0 //legacy IRQ 



    //  Connect the interrupt controller interrupt handler to the hardware interrupt handling logic in the ARM processor.
	//Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler) LowInterruptHandler, (void *)CPU_BASEADDR);
	//Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_FIQ_INT, (Xil_ExceptionHandler) LowInterruptHandler, (void *)CPU_BASEADDR); // Legacy FIQ test
        // XREG_CPSR_IRQ_ENABLE, XIL_EXCEPTION_ALL, XIL_EXCEPTION_ID_INT, XIL_EXCEPTION_ID_UNDEFINED_INT
//	Xil_ExceptionEnable(); // Enable interrupts in the ARM

    
    /*
    u32 reg = XScuGic_ReadReg(DIST_BASEADDR, 0);
	XScuGic_WriteReg(DIST_BASEADDR, 0, reg & ~8);
    reg = XScuGic_ReadReg(DIST_BASEADDR, 0);
    xil_printf("reg = %0x\r\n",reg);
    */

    // #define XIL_EXCEPTION_ALL	(XREG_CPSR_FIQ_ENABLE | XREG_CPSR_IRQ_ENABLE)
    XScuGic_WriteReg(DIST_BASEADDR, 0, 0x0);
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_FIQ_INT, (Xil_ExceptionHandler) FIQInterruptHandler, (void *)CPU_BASEADDR); // Legacy FIQ test
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler) LowInterruptHandler, (void *)CPU_BASEADDR); // Legacy FIQ test
    //Xil_ExceptionEnableMask(XREG_CPSR_FIQ_ENABLE); // this works for FIQ
    Xil_ExceptionEnableMask(XIL_EXCEPTION_ALL); 
    /* NOTE. this works with both FIQ and IRQ legacy pins. NOTE: my test has the exact same interrupt going to both IRQ and FIQ. FIQ took priority and NO IRQ handler ran until disabling the FIQ interrupt in the PL
    */

/********  *******/ 
     //Enable the software interrupts only.
	//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET, 0x0000FFFF);//GICD_ISENABLER0 //PPIs 31:16,  SGIs 15:0, 
	
    // IRQ/FIQ one per CPU(core). IRQ=31, FIQ=28 (0x80000000, 0x10000000, 0x90000000)
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET, 0x80000000);//GICD_ISENABLER0 //legacy IRQ 

    // PL_PS_Group0 121:128
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0xFE000000);//GICD_ISENABLER3 // IDs 127:121 = PL to PS ints 6:0
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0x02000000);//GICD_ISENABLER3 // ID 121 = PL to PS int 0
    //XScuGic_WriteReg(DistBaseAddress, XSCUGIC_ENABLE_SET_OFFSET + 0xC, 0x06000000);//GICD_ISENABLER3 // ID 122,121 = PL to PS int 1:0



     // (simulate) an interrupt, software driven,
	//XScuGic_WriteReg(DistBaseAddress, XSCUGIC_SFI_TRIG_OFFSET, GIC_DEVICE_INT_MASK);



    /*************************************/
//    readSomeGicRegs(CpuBaseAddress,DistBaseAddress);

     // Wait for the interrupt to be processed
	//Status = Xil_WaitForEventSet(XSCUGIC_SW_TIMEOUT_VAL, 1, &InterruptProcessed);
	//if (Status != XST_SUCCESS) {return XST_FAILURE;}

	return XST_SUCCESS;
}

/*****************************************************************************/
void LowInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;

	BaseAddress = CallbackRef;

    //XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_ENABLE_SET_OFFSET, 0x0);//GICD_ISENABLER0 //IRQ  -disable? ADG
    
	IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) & XSCUGIC_ACK_INTID_MASK;//GICC_IAR    //Read the int_ack register to identify the interrupt and make sure it is valid
     
	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
        xil_printf("INTERRUPT HANDLER FAIL. IntID = 0x%x (%u)\r\n",IntID,IntID);
        //Xil_ExceptionDisable();
        //XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_ENABLE_SET_OFFSET, 0x0);//GICD_ISENABLER0 //IRQ  -disable? ADG
        return;
    }
    
	InterruptProcessed = 1; //Execute the ISR. For this example set the global to 1. The software trigger is cleared by the ACK.

	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);//GICC_EOIR    //Write to the EOI register, we are all done here.Let this function return, the boot code will restore the stack.

    xil_printf("INTERRUPT HANDLER done. IntID = 0x%x (%u)\r\n",IntID,IntID); // generally don't put prints in interrupt handler?

    //XScuGic_WriteReg(0xf9030000, 0x0, 0x1F);//GICC_DIR deactivate interrupt 31 legacy IRQ

}

void FIQInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;

	BaseAddress = CallbackRef;

    //XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_ENABLE_SET_OFFSET, 0x0);//GICD_ISENABLER0 //IRQ  -disable? ADG
    
	IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) & XSCUGIC_ACK_INTID_MASK;//GICC_IAR    //Read the int_ack register to identify the interrupt and make sure it is valid
     
	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
        xil_printf("INTERRUPT HANDLER FIQ. IntID = 0x%x (%u)\r\n",IntID,IntID);
        //Xil_ExceptionDisable();
        //XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_ENABLE_SET_OFFSET, 0x0);//GICD_ISENABLER0 //IRQ  -disable? ADG
        return;
    }
    
	InterruptProcessed = 1; //Execute the ISR. For this example set the global to 1. The software trigger is cleared by the ACK.

	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);//GICC_EOIR    //Write to the EOI register, we are all done here.Let this function return, the boot code will restore the stack.

    xil_printf("INTERRUPT HANDLER done. IntID = 0x%x (%u)\r\n",IntID,IntID); // generally don't put prints in interrupt handler?

    //XScuGic_WriteReg(0xf9030000, 0x0, 0x1F);//GICC_DIR deactivate interrupt 31 legacy IRQ

}


void readSomeGicRegs(u32 CpuBaseAddress, u32 DistBaseAddress)
{
    // read some reg's 
    u32 val;
    
    val = XScuGic_ReadReg(DistBaseAddress, 0x00);
    xil_printf("GICD_CTLR = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x04);
    xil_printf("GICD_TYPER = %x\r\n",val);
    
    val = XScuGic_ReadReg(DistBaseAddress, 0x80);
    xil_printf("GICD_IGROUPR0 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x100);
    xil_printf("GICD_ISENABLER0 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x180);
    xil_printf("GICD_ICENABLER0 = %x\r\n",val);
    
    val = XScuGic_ReadReg(DistBaseAddress, 0x200);
    xil_printf("GICD_ISPENDR0 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x280);
    xil_printf("GICD_ICPENDR0 = %x\r\n",val);
    
    val = XScuGic_ReadReg(DistBaseAddress, 0x300);
    xil_printf("GICD_ISACTIVER0 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x380);
    xil_printf("GICD_ICACTIVER0 = %x\r\n",val);
    
    val = XScuGic_ReadReg(DistBaseAddress, 0x400);
    xil_printf("GICD_IPRIORITYR0 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x404);
    xil_printf("GICD_IPRIORITYR1 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x408);
    xil_printf("GICD_IPRIORITYR2 = %x\r\n",val);
    
    val = XScuGic_ReadReg(DistBaseAddress, 0x800);
    xil_printf("GICD_ITARGETSR0 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x804);
    xil_printf("GICD_ITARGETSR1 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0x808);
    xil_printf("GICD_ITARGETSR2 = %x\r\n",val);
    
    val = XScuGic_ReadReg(DistBaseAddress, 0xC00);
    xil_printf("GICD_ICFGR0 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0xC04);
    xil_printf("GICD_ICFGR1 = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0xC08);
    xil_printf("GICD_ICFGR2 = %x\r\n",val);
    
    val = XScuGic_ReadReg(DistBaseAddress, 0xD00);
    xil_printf("GICD_PPISR = %x\r\n",val);
    val = XScuGic_ReadReg(DistBaseAddress, 0xD04);
    xil_printf("GICD_SPISR0 = %x\r\n",val);

    // CPU
    val = XScuGic_ReadReg(CpuBaseAddress, 0x0);
    xil_printf("GICC_CTLR = %x\r\n",val);

    val = XScuGic_ReadReg(CpuBaseAddress, 0x04);
    xil_printf("GICC_PMR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0x08);
    xil_printf("GICC_BPR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0x0C);
    xil_printf("GICC_IAR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0x14);
    xil_printf("GICC_RPR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0x18);
    xil_printf("GICC_HPPIR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0x1C);
    xil_printf("GICC_ABPR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0x20);
    xil_printf("GICC_AIAR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0x28);
    xil_printf("GICC_AHPPIR = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0xD0);
    xil_printf("GICC_APR0 = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0xE0);
    xil_printf("GICC_NSAPR0 = %x\r\n",val);
    val = XScuGic_ReadReg(CpuBaseAddress, 0xFC);
    xil_printf("GICC_IIDR = %x\r\n",val);

    

}