
`timescale 1ns / 1ps  // <time_unit>/<time_precision>
  // time_unit: measurement of delays / simulation time (#10 = 10<time_unit>)
  // time_precision: how delay values are rounded before being used in simulation (degree of accuracy of the time unit)

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

module mcdma_tb ;

  logic clk=0, rstn=0, rst;

  always #2 clk = ~clk; // 250mhz period = 4ns, invert every 2ns

  initial begin
    rstn <= 0;
    #20;
    rstn <= 1;
  end
  assign rst = !rstn;

  localparam AXIL_DW  = 32; // axi-lite data width
  localparam CONV_DW  = 64; // converter data width
  localparam BD_AW    = 40; // top BD addr width
  localparam BD_DW    = 128;// top BD data width

  // axi-lite if's
  axil_if #(AXIL_DW,BD_AW)  axil_if_stim_dma    (clk,rstn); // position based port instantiation
  axil_if #(CONV_DW,BD_AW)  axil_if_dwidth_conv (clk,rstn); // position based port instantiation

  // axi-full if's
  axi_if #(CONV_DW,BD_AW)   axi_if_prot_conv    (clk,rstn); // position based port instantiation
  axi_if #(BD_DW,BD_AW)     axi_if_dwidth_conv  (clk,rstn); // position based port instantiation


  logic [31:0] S2MM_tdata='0 ;
  logic [ 3:0] S2MM_tkeep='0 ,S2MM_tdest='0;
  logic S2MM_tlast='0, S2MM_tready='0, S2MM_tvalid='0;
  logic [ 7:0] S2MM_tid='0;
  logic [15:0] S2MM_tuser='0;

  mcdma_bd_wrapper  mcdma_bd_wrapper_i (
    .M_AXIS_MM2S_tdata        (                 ),
    .M_AXIS_MM2S_tdest        (                 ),
    .M_AXIS_MM2S_tid          (                 ),
    .M_AXIS_MM2S_tkeep        (                 ),
    .M_AXIS_MM2S_tlast        (                 ),
//    .M_AXIS_MM2S_tready       ('1               ),
    .M_AXIS_MM2S_tuser        (                 ),
    .M_AXIS_MM2S_tvalid       (                 ),
    
    .S00_AXI_araddr     (axi_if_dwidth_conv.araddr),
    .S00_AXI_arburst    (axi_if_dwidth_conv.arburst),
    .S00_AXI_arcache    (axi_if_dwidth_conv.arcache),
    .S00_AXI_arlen      (axi_if_dwidth_conv.arlen),
    .S00_AXI_arlock     (axi_if_dwidth_conv.arlock),
    .S00_AXI_arprot     (axi_if_dwidth_conv.arprot),
    .S00_AXI_arqos      (axi_if_dwidth_conv.arqos),
    .S00_AXI_arready    (axi_if_dwidth_conv.arready),
    .S00_AXI_arsize     (axi_if_dwidth_conv.arsize),
    .S00_AXI_arvalid    (axi_if_dwidth_conv.arvalid),
    .S00_AXI_awaddr     (axi_if_dwidth_conv.awaddr),
    .S00_AXI_awburst    (axi_if_dwidth_conv.awburst),
    .S00_AXI_awcache    (axi_if_dwidth_conv.awcache),
    .S00_AXI_awlen      (axi_if_dwidth_conv.awlen),
    .S00_AXI_awlock     (axi_if_dwidth_conv.awlock),
    .S00_AXI_awprot     (axi_if_dwidth_conv.awprot),
    .S00_AXI_awqos      (axi_if_dwidth_conv.awqos),
    .S00_AXI_awready    (axi_if_dwidth_conv.awready),
    .S00_AXI_awsize     (axi_if_dwidth_conv.awsize), 
    .S00_AXI_awvalid    (axi_if_dwidth_conv.awvalid),
    .S00_AXI_bready     (axi_if_dwidth_conv.bready),
    .S00_AXI_bresp      (axi_if_dwidth_conv.bresp),
    .S00_AXI_bvalid     (axi_if_dwidth_conv.bvalid),
    .S00_AXI_rdata      (axi_if_dwidth_conv.rdata),
    .S00_AXI_rlast      (axi_if_dwidth_conv.rlast),
    .S00_AXI_rready     (axi_if_dwidth_conv.rready),
    .S00_AXI_rresp      (axi_if_dwidth_conv.rresp),
    .S00_AXI_rvalid     (axi_if_dwidth_conv.rvalid),
    .S00_AXI_wdata      (axi_if_dwidth_conv.wdata),
    .S00_AXI_wlast      (axi_if_dwidth_conv.wlast),
    .S00_AXI_wready     (axi_if_dwidth_conv.wready),
    .S00_AXI_wstrb      (axi_if_dwidth_conv.wstrb),
    .S00_AXI_wvalid     (axi_if_dwidth_conv.wvalid),
    .S00_AXI_arid       ('0),
    .S00_AXI_aruser     ('0),
    .S00_AXI_awid       ('0),
    .S00_AXI_awuser     ('0),
    .S00_AXI_bid        (),
    .S00_AXI_rid        (),

    .S_AXI_araddr   (),
    .S_AXI_arburst  (),
    .S_AXI_arcache  (),
    .S_AXI_arlen    (),
    .S_AXI_arlock   (),
    .S_AXI_arprot   (),
    .S_AXI_arready  (),
    .S_AXI_arsize   (),
    .S_AXI_arvalid  (),
    .S_AXI_awaddr   (),
    .S_AXI_awburst  (),
    .S_AXI_awcache  (),
    .S_AXI_awlen    (),
    .S_AXI_awlock   (),
    .S_AXI_awprot   (),
    .S_AXI_awready  (),
    .S_AXI_awsize   (),
    .S_AXI_awvalid  (),
    .S_AXI_bready   (),
    .S_AXI_bresp    (),
    .S_AXI_bvalid   (),
    .S_AXI_rdata    (),
    .S_AXI_rlast    (),
    .S_AXI_rready   (),
    .S_AXI_rresp    (),
    .S_AXI_rvalid   (),
    .S_AXI_wdata    (),
    .S_AXI_wlast    (),
    .S_AXI_wready   (),
    .S_AXI_wstrb    (),
    .S_AXI_wvalid   (),
    .ext_reset_in   (rstn             ),
    .s_axi_aclk     (clk              )
  );


axi_dwidth_converter_axi4_64to128 axi_dwidth_converter_axi4_64to128_i (
  .s_axi_aclk      (clk),                   //input wire s_axi_aclk
  .s_axi_aresetn   (rstn),                  //input wire s_axi_aresetn
  
  .s_axi_awaddr    (axi_if_prot_conv.awaddr),         //input wire [39 : 0] s_axi_awaddr
  .s_axi_awlen     (axi_if_prot_conv.awlen),          //input wire [7 : 0] s_axi_awlen
  .s_axi_awsize    (axi_if_prot_conv.awsize),         //input wire [2 : 0] s_axi_awsize
  .s_axi_awburst   (axi_if_prot_conv.awburst),        //input wire [1 : 0] s_axi_awburst
  .s_axi_awlock    (axi_if_prot_conv.awlock),         //input wire [0 : 0] s_axi_awlock
  .s_axi_awcache   (axi_if_prot_conv.awcache),        //input wire [3 : 0] s_axi_awcache
  .s_axi_awprot    (axi_if_prot_conv.awprot),         //input wire [2 : 0] s_axi_awprot
  .s_axi_awregion  (axi_if_prot_conv.awregion),       //inputwire [3 : 0] s_axi_awregion
  .s_axi_awqos     (axi_if_prot_conv.awqos),          //input wire [3 : 0] s_axi_awqos
  .s_axi_awvalid   (axi_if_prot_conv.awvalid),        //input wire s_axi_awvalid
  .s_axi_awready   (axi_if_prot_conv.awready),        //output wire s_axi_awready
  .s_axi_wdata     (axi_if_prot_conv.wdata),          //input wire [63 : 0] s_axi_wdata
  .s_axi_wstrb     (axi_if_prot_conv.wstrb),          //input wire [7 : 0] s_axi_wstrb
  .s_axi_wlast     (axi_if_prot_conv.wlast),          //input wire s_axi_wlast
  .s_axi_wvalid    (axi_if_prot_conv.wvalid),         //input wire s_axi_wvalid
  .s_axi_wready    (axi_if_prot_conv.wready),         //output wire s_axi_wready
  .s_axi_bresp     (axi_if_prot_conv.bresp),          //output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid    (axi_if_prot_conv.bvalid),         //output wire s_axi_bvalid
  .s_axi_bready    (axi_if_prot_conv.bready),         //input wire s_axi_bready
  .s_axi_araddr    (axi_if_prot_conv.araddr),         //input wire [39 : 0] s_axi_araddr
  .s_axi_arlen     (axi_if_prot_conv.arlen),          //input wire [7 : 0] s_axi_arlen
  .s_axi_arsize    (axi_if_prot_conv.arsize),         //input wire [2 : 0] s_axi_arsize
  .s_axi_arburst   (axi_if_prot_conv.arburst),        //input wire [1 : 0] s_axi_arburst
  .s_axi_arlock    (axi_if_prot_conv.arlock),         //input wire [0 : 0] s_axi_arlock
  .s_axi_arcache   (axi_if_prot_conv.arcache),        //input wire [3 : 0] s_axi_arcache
  .s_axi_arprot    (axi_if_prot_conv.arprot),         //input wire [2 : 0] s_axi_arprot
  .s_axi_arregion  (axi_if_prot_conv.arregion),       //inputwire [3 : 0] s_axi_arregion
  .s_axi_arqos     (axi_if_prot_conv.arqos),          //input wire [3 : 0] s_axi_arqos
  .s_axi_arvalid   (axi_if_prot_conv.arvalid),        //input wire s_axi_arvalid
  .s_axi_arready   (axi_if_prot_conv.arready),        //output wire s_axi_arready
  .s_axi_rdata     (axi_if_prot_conv.rdata),          //output wire [63 : 0] s_axi_rdata
  .s_axi_rresp     (axi_if_prot_conv.rresp),          //output wire [1 : 0] s_axi_rresp
  .s_axi_rlast     (axi_if_prot_conv.rlast),          //output wire s_axi_rlast
  .s_axi_rvalid    (axi_if_prot_conv.rvalid),         //output wire s_axi_rvalid
  .s_axi_rready    (axi_if_prot_conv.rready),         //input wire s_axi_rready
  
  .m_axi_awaddr    (axi_if_dwidth_conv.awaddr),         //output wire [39 : 0]   m_axi_awaddr
  .m_axi_awlen     (axi_if_dwidth_conv.awlen),          //output wire [7 : 0]    m_axi_awlen
  .m_axi_awsize    (axi_if_dwidth_conv.awsize),         //output wire [2 : 0]    m_axi_awsize
  .m_axi_awburst   (axi_if_dwidth_conv.awburst),        //output wire [1 : 0]    m_axi_awburst
  .m_axi_awlock    (axi_if_dwidth_conv.awlock),         //output wire [0 : 0]    m_axi_awlock
  .m_axi_awcache   (axi_if_dwidth_conv.awcache),        //output wire [3 : 0]    m_axi_awcache
  .m_axi_awprot    (axi_if_dwidth_conv.awprot),         //output wire [2 : 0]    m_axi_awprot
  .m_axi_awregion  (axi_if_dwidth_conv.awregion),       //output wire [3 : 0]    m_axi_awregion
  .m_axi_awqos     (axi_if_dwidth_conv.awqos),          //output wire [3 : 0]    m_axi_awqos
  .m_axi_awvalid   (axi_if_dwidth_conv.awvalid),        //output wire            m_axi_awvalid
  .m_axi_awready   (axi_if_dwidth_conv.awready),        //input wire             m_axi_awready
  .m_axi_wdata     (axi_if_dwidth_conv.wdata),          //output wire [127 : 0]  m_axi_wdata
  .m_axi_wstrb     (axi_if_dwidth_conv.wstrb),          //output wire [15 : 0]   m_axi_wstrb
  .m_axi_wlast     (axi_if_dwidth_conv.wlast),          //output wire            m_axi_wlast
  .m_axi_wvalid    (axi_if_dwidth_conv.wvalid),         //output wire            m_axi_wvalid
  .m_axi_wready    (axi_if_dwidth_conv.wready),         //input wire             m_axi_wready
  .m_axi_bresp     (axi_if_dwidth_conv.bresp),          //input wire [1 : 0]     m_axi_bresp
  .m_axi_bvalid    (axi_if_dwidth_conv.bvalid),         //input wire             m_axi_bvalid
  .m_axi_bready    (axi_if_dwidth_conv.bready),         //output wire            m_axi_bready
  .m_axi_araddr    (axi_if_dwidth_conv.araddr),         //output wire [39 : 0]   m_axi_araddr
  .m_axi_arlen     (axi_if_dwidth_conv.arlen),          //output wire [7 : 0]    m_axi_arlen
  .m_axi_arsize    (axi_if_dwidth_conv.arsize),         //output wire [2 : 0]    m_axi_arsize
  .m_axi_arburst   (axi_if_dwidth_conv.arburst),        //output wire [1 : 0]    m_axi_arburst
  .m_axi_arlock    (axi_if_dwidth_conv.arlock),         //output wire [0 : 0]    m_axi_arlock
  .m_axi_arcache   (axi_if_dwidth_conv.arcache),        //output wire [3 : 0]    m_axi_arcache
  .m_axi_arprot    (axi_if_dwidth_conv.arprot),         //output wire [2 : 0]    m_axi_arprot
  .m_axi_arregion  (axi_if_dwidth_conv.arregion),       //output wire [3 : 0]    m_axi_arregion
  .m_axi_arqos     (axi_if_dwidth_conv.arqos),          //output wire [3 : 0]    m_axi_arqos
  .m_axi_arvalid   (axi_if_dwidth_conv.arvalid),        //output wire            m_axi_arvalid
  .m_axi_arready   (axi_if_dwidth_conv.arready),        //input wire             m_axi_arready
  .m_axi_rdata     (axi_if_dwidth_conv.rdata),          //input wire [127 : 0]   m_axi_rdata
  .m_axi_rresp     (axi_if_dwidth_conv.rresp),          //input wire [1 : 0]     m_axi_rresp
  .m_axi_rlast     (axi_if_dwidth_conv.rlast),          //input wire             m_axi_rlast
  .m_axi_rvalid    (axi_if_dwidth_conv.rvalid),         //input wire             m_axi_rvalid
  .m_axi_rready    (axi_if_dwidth_conv.rready)          //output wire            m_axi_rready
);

axi_protocol_converter_0 axi_protocol_converter_i (
  .aclk            (clk),                    
  .aresetn         (rstn),              
  .s_axi_awaddr    (axil_if_dwidth_conv.awaddr),
  .s_axi_awprot    (axil_if_dwidth_conv.awprot),
  .s_axi_awvalid   (axil_if_dwidth_conv.awvalid),
  .s_axi_awready   (axil_if_dwidth_conv.awready),
  .s_axi_wdata     (axil_if_dwidth_conv.wdata),
  .s_axi_wstrb     (axil_if_dwidth_conv.wstrb),
  .s_axi_wvalid    (axil_if_dwidth_conv.wvalid),
  .s_axi_wready    (axil_if_dwidth_conv.wready),
  .s_axi_bresp     (axil_if_dwidth_conv.bresp),
  .s_axi_bvalid    (axil_if_dwidth_conv.bvalid),
  .s_axi_bready    (axil_if_dwidth_conv.bready),
  .s_axi_araddr    (axil_if_dwidth_conv.araddr),
  .s_axi_arprot    (axil_if_dwidth_conv.arprot),
  .s_axi_arvalid   (axil_if_dwidth_conv.arvalid),
  .s_axi_arready   (axil_if_dwidth_conv.arready),
  .s_axi_rdata     (axil_if_dwidth_conv.rdata),
  .s_axi_rresp     (axil_if_dwidth_conv.rresp),
  .s_axi_rvalid    (axil_if_dwidth_conv.rvalid),
  .s_axi_rready    (axil_if_dwidth_conv.rready),
  .m_axi_awaddr    (axi_if_prot_conv.awaddr      ),
  .m_axi_awlen     (axi_if_prot_conv.awlen       ),
  .m_axi_awsize    (axi_if_prot_conv.awsize      ),
  .m_axi_awburst   (axi_if_prot_conv.awburst     ),
  .m_axi_awlock    (axi_if_prot_conv.awlock      ),
  .m_axi_awcache   (axi_if_prot_conv.awcache     ),
  .m_axi_awprot    (axi_if_prot_conv.awprot      ),
  .m_axi_awregion  (axi_if_prot_conv.awregion    ),
  .m_axi_awqos     (axi_if_prot_conv.awqos       ),
  .m_axi_awvalid   (axi_if_prot_conv.awvalid     ),
  .m_axi_awready   (axi_if_prot_conv.awready     ),
  .m_axi_wdata     (axi_if_prot_conv.wdata       ),
  .m_axi_wstrb     (axi_if_prot_conv.wstrb       ),
  .m_axi_wlast     (axi_if_prot_conv.wlast       ),
  .m_axi_wvalid    (axi_if_prot_conv.wvalid      ),
  .m_axi_wready    (axi_if_prot_conv.wready      ),
  .m_axi_bresp     (axi_if_prot_conv.bresp       ),
  .m_axi_bvalid    (axi_if_prot_conv.bvalid      ),
  .m_axi_bready    (axi_if_prot_conv.bready      ),
  .m_axi_araddr    (axi_if_prot_conv.araddr      ),
  .m_axi_arlen     (axi_if_prot_conv.arlen       ),
  .m_axi_arsize    (axi_if_prot_conv.arsize      ),
  .m_axi_arburst   (axi_if_prot_conv.arburst     ),
  .m_axi_arlock    (axi_if_prot_conv.arlock      ),
  .m_axi_arcache   (axi_if_prot_conv.arcache     ),
  .m_axi_arprot    (axi_if_prot_conv.arprot      ),
  .m_axi_arregion  (axi_if_prot_conv.arregion    ),
  .m_axi_arqos     (axi_if_prot_conv.arqos       ),
  .m_axi_arvalid   (axi_if_prot_conv.arvalid     ),
  .m_axi_arready   (axi_if_prot_conv.arready     ),
  .m_axi_rdata     (axi_if_prot_conv.rdata       ),
  .m_axi_rresp     (axi_if_prot_conv.rresp       ),
  .m_axi_rlast     (axi_if_prot_conv.rlast       ),
  .m_axi_rvalid    (axi_if_prot_conv.rvalid      ),
  .m_axi_rready    (axi_if_prot_conv.rready      )
);

  

axi_dwidth_converter_0 axi_dwidth_converter_i (
  .s_axi_aclk     (clk), 
  .s_axi_aresetn  (rstn), 
  .s_axi_awaddr   (axil_if_stim_dma.awaddr      ),// input wire [39 : 0] s_axi_awaddr
  .s_axi_awprot   (axil_if_stim_dma.awprot      ),// input wire [2 : 0] s_axi_awprot
  .s_axi_awvalid  (axil_if_stim_dma.awvalid     ),// input wire s_axi_awvalid
  .s_axi_awready  (axil_if_stim_dma.awready     ),// output wire s_axi_awready
  .s_axi_wdata    (axil_if_stim_dma.wdata       ),// input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb    (axil_if_stim_dma.wstrb       ),// input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid   (axil_if_stim_dma.wvalid      ),// input wire s_axi_wvalid
  .s_axi_wready   (axil_if_stim_dma.wready      ),// output wire s_axi_wready
  .s_axi_bresp    (axil_if_stim_dma.bresp       ),// output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid   (axil_if_stim_dma.bvalid      ),// output wire s_axi_bvalid
  .s_axi_bready   (axil_if_stim_dma.bready      ),// input wire s_axi_bready
  .s_axi_araddr   (axil_if_stim_dma.araddr      ),// input wire [39 : 0] s_axi_araddr
  .s_axi_arprot   (axil_if_stim_dma.arprot      ),// input wire [2 : 0] s_axi_arprot
  .s_axi_arvalid  (axil_if_stim_dma.arvalid     ),// input wire s_axi_arvalid
  .s_axi_arready  (axil_if_stim_dma.arready     ),// output wire s_axi_arready
  .s_axi_rdata    (axil_if_stim_dma.rdata       ),// output wire [31 : 0] s_axi_rdata
  .s_axi_rresp    (axil_if_stim_dma.rresp       ),// output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid   (axil_if_stim_dma.rvalid      ),// output wire s_axi_rvalid
  .s_axi_rready   (axil_if_stim_dma.rready      ),// input wire s_axi_rready
  
  .m_axi_awaddr   (axil_if_dwidth_conv.awaddr   ),// output wire [39 : 0] m_axi_awaddr
  .m_axi_awprot   (axil_if_dwidth_conv.awprot   ),// output wire [2 : 0] m_axi_awprot
  .m_axi_awvalid  (axil_if_dwidth_conv.awvalid  ),// output wire m_axi_awvalid
  .m_axi_awready  (axil_if_dwidth_conv.awready  ),// input wire m_axi_awready
  .m_axi_wdata    (axil_if_dwidth_conv.wdata    ),// output wire [63 : 0] m_axi_wdata
  .m_axi_wstrb    (axil_if_dwidth_conv.wstrb    ),// output wire [7 : 0] m_axi_wstrb
  .m_axi_wvalid   (axil_if_dwidth_conv.wvalid   ),// output wire m_axi_wvalid
  .m_axi_wready   (axil_if_dwidth_conv.wready   ),// input wire m_axi_wready
  .m_axi_bresp    (axil_if_dwidth_conv.bresp    ),// input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid   (axil_if_dwidth_conv.bvalid   ),// input wire m_axi_bvalid
  .m_axi_bready   (axil_if_dwidth_conv.bready   ),// output wire m_axi_bready
  .m_axi_araddr   (axil_if_dwidth_conv.araddr   ),// output wire [39 : 0] m_axi_araddr
  .m_axi_arprot   (axil_if_dwidth_conv.arprot   ),// output wire [2 : 0] m_axi_arprot
  .m_axi_arvalid  (axil_if_dwidth_conv.arvalid  ),// output wire m_axi_arvalid
  .m_axi_arready  (axil_if_dwidth_conv.arready  ),// input wire m_axi_arready
  .m_axi_rdata    (axil_if_dwidth_conv.rdata    ),// input wire [63 : 0] m_axi_rdata
  .m_axi_rresp    (axil_if_dwidth_conv.rresp    ),// input wire [1 : 0] m_axi_rresp
  .m_axi_rvalid   (axil_if_dwidth_conv.rvalid   ),// input wire m_axi_rvalid
  .m_axi_rready   (axil_if_dwidth_conv.rready   )// output wire m_axi_rready
);


  axil_stim_dma  # (
    .DATA_WIDTH (AXIL_DW),
    .ADDR_WIDTH (BD_AW)
  ) axil_stim_dma_i (
    .start      (1'b1),
    .done       (axil_done),
    .m_axil_if  (axil_if_stim_dma)
  );

  logic start=0;

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------


initial begin 
  wait(rst==0);
//  #200ns;tready=1;
  wait(axil_done == 1);
  #20ns;start_en;
end


task start_en;
  begin 
    @(posedge clk); start <= 1;
    @(posedge clk); start <= 0;
  end 
endtask
  

endmodule