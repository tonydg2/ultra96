/**********************************/
/* MCDMA   PG288 */
/**********************************/

`timescale 1ns / 1ps  // <time_unit>/<time_precision>

module axil_stim_dma 
	(
		input         start,
    output logic  done,
    axil_if.src   m_axil_if
	);

//-------------------------------------------------------------------------------------------------
// STIMULUS: Read/Write task control
//-------------------------------------------------------------------------------------------------
//localparam ADDR_SG  = 32'hA001_0000;  // offset of SG bram
//localparam ADDR_DMA = 32'hA000_0000;  // offset of MCDMA AXIL 
//localparam ADDR_MEM = 32'hC000_0000;  // offset of memory bram
//localparam ADDR_REG = 32'hA001_2000;

localparam [m_axil_if.ADDR_WIDTH-1:0] ADDR_SG  = 32'hA001_0000;
localparam [m_axil_if.ADDR_WIDTH-1:0] ADDR_DMA = 32'hA000_0000;
localparam [m_axil_if.ADDR_WIDTH-1:0] ADDR_MEM = 32'hC000_0000;
localparam [m_axil_if.ADDR_WIDTH-1:0] ADDR_REG = 32'hA001_2000;

// descriptor field offsets
// CH0 S2MM descriptor
localparam NXDS_S0 = 8'h00; // Next Descriptor - pointer/address to next desc
localparam BADD_S0 = 8'h08; // Buffer address - address to memory data being written to / read from
localparam CTRL_S0 = 8'h14; // control
// CH1 S2MM descriptor
localparam NXDS_S1 = 8'h40;
localparam BADD_S1 = 8'h48;
localparam CTRL_S1 = 8'h54;

// CH0 MM2S descriptor
localparam NXDS_M0 = 8'h80; 
localparam BADD_M0 = 8'h88; 
localparam CTRL_M0 = 8'h94; 
// CH1 MM2S descriptor
localparam NXDS_M1 = 8'hC0;
localparam BADD_M1 = 8'hC8;
localparam CTRL_M1 = 8'hD4;

// MCDMA
localparam MM2S_CR  = 12'h000;
localparam MM2S_CH  = 12'h008;
localparam M_CH0CR  = 12'h040;    
localparam M_CH0CD  = 12'h048;  
localparam M_CH0TD  = 12'h050;
localparam M_CH1CR  = 12'h080;    
localparam M_CH1CD  = 12'h088;  
localparam M_CH1TD  = 12'h090;

localparam S2MM_CR  = 12'h500;
localparam S2MM_CH  = 12'h508;
localparam S_CH0CR  = 12'h540;    
localparam S_CH0CD  = 12'h548;  
localparam S_CH0TD  = 12'h550;
localparam S_CH1CR  = 12'h580;    
localparam S_CH1CD  = 12'h588;  
localparam S_CH1TD  = 12'h590;


  initial begin 
    done<=0;
    //wait(start==1);
    #200;   
    //---------------------------------------------------------------------------------------------
    // Test rd/wr reg's
    //---------------------------------------------------------------------------------------------
    
    WR(ADDR_REG + 8'h18, 32'hAAAA0777); // ADDR_REG = 32'hA001_2000
    WR(ADDR_REG + 8'h1C, 32'hAAAA1777);
    WR(ADDR_REG + 8'h20, 32'hAAAA2777);
    WR(ADDR_REG + 8'h24, 32'hAAAA3777);
    WR(ADDR_REG + 8'h28, 32'hAAAA4777);
    WR(ADDR_REG + 8'h2C, 32'hAAAA5777);
    WR(ADDR_REG + 8'h30, 32'hAAAA6777);
    WR(ADDR_REG + 8'h34, 32'hAAAA7777);
    WR(ADDR_REG + 8'h38, 32'hAAAA8777);
    WR(ADDR_REG + 8'h3C, 32'hAAAA9777);

    RD(ADDR_REG + 8'h18);
    RD(ADDR_REG + 8'h1C);
    RD(ADDR_REG + 8'h20);
    RD(ADDR_REG + 8'h24);
    RD(ADDR_REG + 8'h28);
    RD(ADDR_REG + 8'h2C);
    RD(ADDR_REG + 8'h30);
    RD(ADDR_REG + 8'h34);
    RD(ADDR_REG + 8'h38);
    RD(ADDR_REG + 8'h3C);
    #1us;//$stop;

    //---------------------------------------------------------------------------------------------
    // load/write descriptors into SG bram
    //---------------------------------------------------------------------------------------------
    //S2MM descriptors
    /* CH0 1st descriptor, store 8bytes - two 32bit words */
    WR({ADDR_SG + NXDS_S0}, {ADDR_SG + NXDS_S0}); // point to next descriptor
    WR({ADDR_SG + BADD_S0}, 32'hC0000000); // location to store data
    WR({ADDR_SG + CTRL_S0}, {32'h0, 1'b1, 1'b1, 4'h0, 26'h40}); // RXSOF, REOF, Reserved, Len
    /* CH1 1st descriptor, store 8bytes - two 32bit words */
    WR({ADDR_SG + NXDS_S1}, {ADDR_SG + NXDS_S1}); // point to next descriptor
    WR({ADDR_SG + BADD_S1}, 32'hC0001000); // location to store data
    WR({ADDR_SG + CTRL_S1}, {32'h0, 1'b1, 1'b1, 4'h0, 26'h40}); // RXSOF, REOF, Reserved, Len

    //MM2S descriptors different location
    //CH0
    WR({ADDR_SG + NXDS_M0}, {ADDR_SG + NXDS_M0}); // point to next descriptor
    WR({ADDR_SG + BADD_M0}, 32'hC0001000); // location to get data
    WR({ADDR_SG + CTRL_M0}, {32'h0, 1'b1, 1'b1, 4'h0, 26'h40}); // RXSOF, REOF, Reserved, Len
    //CH1
    WR({ADDR_SG + NXDS_M1}, {ADDR_SG + NXDS_M1}); // point to next descriptor
    WR({ADDR_SG + BADD_M1}, 32'hC0000000); // location to get data
    WR({ADDR_SG + CTRL_M1}, {32'h0, 1'b1, 1'b1, 4'h0, 26'h40}); // RXSOF, REOF, Reserved, Len

    //---------------------------------------------------------------------------------------------
    //S2MM DMA config
    //---------------------------------------------------------------------------------------------
    // config. DMA for descriptor location and initiate/start transfers
    WR({ADDR_DMA + S2MM_CH}, 32'h3);              // enable channels
    WR({ADDR_DMA + S_CH0CD}, {ADDR_SG + NXDS_S0});  // CD for ch0
    WR({ADDR_DMA + S_CH1CD}, {ADDR_SG + NXDS_S1});  // CD for ch1
    WR({ADDR_DMA + S_CH0CR}, 32'h1);        // ch0 fetch bit
    WR({ADDR_DMA + S_CH1CR}, 32'h1);        // ch1 fetch bit
    WR({ADDR_DMA + S2MM_CR}, 32'h1);        // start DMA
    WR({ADDR_DMA + S_CH0TD}, {ADDR_SG + NXDS_S0});  // TD for ch0
    WR({ADDR_DMA + S_CH1TD}, {ADDR_SG + NXDS_S1});  // TD for ch1

    #200;
    done<=1;
    #4us;
    //---------------------------------------------------------------------------------------------
    //MM2S DMA config
    //---------------------------------------------------------------------------------------------
    WR({ADDR_DMA + MM2S_CH}, 32'h3);        // enable channels
    WR({ADDR_DMA + M_CH0CD}, {ADDR_SG + NXDS_M0});  // CD for ch0
    WR({ADDR_DMA + M_CH1CD}, {ADDR_SG + NXDS_M1});  // CD for ch1
    WR({ADDR_DMA + M_CH0CR}, 32'h1);        // ch0 fetch bit
    WR({ADDR_DMA + M_CH1CR}, 32'h1);        // ch1 fetch bit
    WR({ADDR_DMA + MM2S_CR}, 32'h1);        // start DMA
    WR({ADDR_DMA + M_CH0TD}, {ADDR_SG + NXDS_M0});  // TD for ch0
    WR({ADDR_DMA + M_CH1TD}, {ADDR_SG + NXDS_M1});  // TD for ch1


//    //MM2S DMA config
//    // use identical descriptors from S2MM, in different location, should read the data that was written by S2MM and populate the M_AXIS_MM2S interface
//    WR({ADDR_DMA + MM2S_CD}, {ADDR_SG,8'h80});  //
//    WR({ADDR_DMA + MM2S_CR}, 32'h00001001);     //
//    WR({ADDR_DMA + MM2S_TD}, {ADDR_SG,8'hC0});  //

    
//    wait(dma_top_tb.top_bd_wrapper_i.s2mm_introut_0 == 1'b1);
  #5us;$stop;
  end 

//-------------------------------------------------------------------------------------------------
// signals
//-------------------------------------------------------------------------------------------------

  logic [m_axil_if.ADDR_WIDTH-1:0]        araddr=0  ;
  logic                                   arvalid=0 ;
  logic [m_axil_if.ADDR_WIDTH-1:0]        awaddr=0  ;
  logic                                   awvalid=0 ;
  logic                                   bready=0  ;
  logic                                   rready=0  ;
  logic [m_axil_if.DATA_WIDTH-1:0]        wdata=0, rdata   ;
  logic                                   wvalid=0  ;
  logic                                   bvalid    ;
  logic [2:0]                             awprot, arprot;
  logic [(m_axil_if.DATA_WIDTH/8)-1 : 0]  wstrb;

  logic  clk;
  assign clk = m_axil_if.aclk;

  assign m_axil_if.awaddr   = awaddr  ;
  assign m_axil_if.awprot   = awprot  ;
  assign m_axil_if.awvalid  = awvalid ;
  assign m_axil_if.wdata	  = wdata	  ;
  assign m_axil_if.wstrb	  = wstrb	  ;
  assign m_axil_if.wvalid   = wvalid  ;
  assign m_axil_if.bready   = bready  ;
  assign m_axil_if.araddr   = araddr  ;
  assign m_axil_if.arprot   = arprot  ;
  assign m_axil_if.arvalid  = arvalid ;
  assign m_axil_if.rready   = rready  ;
  assign bvalid             = m_axil_if.bvalid;
  assign rdata	            = m_axil_if.rdata ;

  logic awready, wready, arready, rvalid;
  assign awready  = m_axil_if.awready ;
  assign wready   = m_axil_if.wready  ;
  assign arready  = m_axil_if.arready ;     
  assign rvalid   = m_axil_if.rvalid  ; 


//-------------------------------------------------------------------------------------------------
/* NOTE: 
  "=" is blocking,      in an always block, line of code executes after previous, squentially
  "<=" is non-blocking, in an always block, every line executed in parallel.
*/
//-------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// Read
//-------------------------------------------------------------------------------------------------

// ADDRESS    // DATA
//  araddr	  //  rdata		    
//  arprot	  //  rresp		    
//  arvalid	  //  rvalid	    
//  arready	  //  rready    

  task RD;
    input  [m_axil_if.ADDR_WIDTH-1:0] addr;
    reg    [m_axil_if.DATA_WIDTH-1:0] data;
    begin

      @(posedge clk);
      araddr <= addr; arprot <= '0; arvalid <= 1;
      rready <= 1;

      fork
        begin 
          wait(arready == 1);
          @(posedge clk);
          araddr <= '0; arprot <= '0; arvalid <= 0;
        end 

        begin 
          wait(rvalid == 1); //rready <= 1;
          @(posedge clk);
          data = rdata; rready <= 0;
        end
      join
    
    //rready <= 0;
    $display("%m - Addr %h: %h", addr, data);
    end
  endtask

//-------------------------------------------------------------------------------------------------
// Write 
//-------------------------------------------------------------------------------------------------

// ADDRESS      // DATA       // RESPONSE       
//  awaddr	    //  wdata	    //  bresp		     
//  awprot	    //  wstrb	    //  bvalid	     
//  awvalid	    //  wvalid    //  bready	     
//  awready	    //  wready  

  task WR;
    input [m_axil_if.ADDR_WIDTH-1:0] addr;
    input [m_axil_if.DATA_WIDTH-1:0] data;
    begin

      @(posedge clk);
      awaddr <= addr; awprot <= '0; awvalid <= 1;
      wdata  <= data; wstrb  <= '1; wvalid  <= 1;

      fork // start all processes (begin/end statements) parallel, and wait for all to complete
        begin
          wait(awready == 1);
          @(posedge clk);
          awaddr <= '0; awprot <= '0; awvalid <= 0;
        end

        begin
          wait(wready == 1);
          @(posedge clk);
          wdata  <= '0; wstrb  <= '0; wvalid  <= 0;
        end
      join
      
      bready <= '1;
      wait(bvalid == 1);
      @(posedge clk);
      bready <= '0;
    
    $display("%m - Addr %h: %h", addr, data);
    end
  endtask

endmodule