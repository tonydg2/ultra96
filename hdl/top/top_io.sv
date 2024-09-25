module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0]  M00_AXIL_araddr  ,s_axi_mgr_araddr  ,m_axi_mgr_araddr  ;
logic [2:0]   M00_AXIL_arprot  ,s_axi_mgr_arprot  ,m_axi_mgr_arprot  ;
logic         M00_AXIL_arready ,s_axi_mgr_arready ,m_axi_mgr_arready ;
logic         M00_AXIL_arvalid ,s_axi_mgr_arvalid ,m_axi_mgr_arvalid ;
logic [31:0]  M00_AXIL_awaddr  ,s_axi_mgr_awaddr  ,m_axi_mgr_awaddr  ;
logic [2:0]   M00_AXIL_awprot  ,s_axi_mgr_awprot  ,m_axi_mgr_awprot  ;
logic         M00_AXIL_awready ,s_axi_mgr_awready ,m_axi_mgr_awready ;
logic         M00_AXIL_awvalid ,s_axi_mgr_awvalid ,m_axi_mgr_awvalid ;
logic         M00_AXIL_bready  ,s_axi_mgr_bready  ,m_axi_mgr_bready  ;
logic [1:0]   M00_AXIL_bresp   ,s_axi_mgr_bresp   ,m_axi_mgr_bresp   ;
logic         M00_AXIL_bvalid  ,s_axi_mgr_bvalid  ,m_axi_mgr_bvalid  ;
logic [31:0]  M00_AXIL_rdata   ,s_axi_mgr_rdata   ,m_axi_mgr_rdata   ;
logic         M00_AXIL_rready  ,s_axi_mgr_rready  ,m_axi_mgr_rready  ;
logic [1:0]   M00_AXIL_rresp   ,s_axi_mgr_rresp   ,m_axi_mgr_rresp   ;
logic         M00_AXIL_rvalid  ,s_axi_mgr_rvalid  ,m_axi_mgr_rvalid  ;
logic [31:0]  M00_AXIL_wdata   ,s_axi_mgr_wdata   ,m_axi_mgr_wdata   ;
logic         M00_AXIL_wready  ,s_axi_mgr_wready  ,m_axi_mgr_wready  ;
logic [3:0]   M00_AXIL_wstrb   ,s_axi_mgr_wstrb   ,m_axi_mgr_wstrb   ;
logic         M00_AXIL_wvalid  ,s_axi_mgr_wvalid  ,m_axi_mgr_wvalid  ;

logic [63:0]  git_hash;
logic [4:0]   led_div_i;
logic [31:0]  timestamp;
logic [1:0]   led_sel;
logic [15:0]  probe0;

///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .M00_AXIL_araddr    (M00_AXIL_araddr  ),
    .M00_AXIL_arprot    (M00_AXIL_arprot  ),
    .M00_AXIL_arready   (M00_AXIL_arready ),
    .M00_AXIL_arvalid   (M00_AXIL_arvalid ),
    .M00_AXIL_awaddr    (M00_AXIL_awaddr  ),
    .M00_AXIL_awprot    (M00_AXIL_awprot  ),
    .M00_AXIL_awready   (M00_AXIL_awready ),
    .M00_AXIL_awvalid   (M00_AXIL_awvalid ),
    .M00_AXIL_bready    (M00_AXIL_bready  ),
    .M00_AXIL_bresp     (M00_AXIL_bresp   ),
    .M00_AXIL_bvalid    (M00_AXIL_bvalid  ),
    .M00_AXIL_rdata     (M00_AXIL_rdata   ),
    .M00_AXIL_rready    (M00_AXIL_rready  ),
    .M00_AXIL_rresp     (M00_AXIL_rresp   ),
    .M00_AXIL_rvalid    (M00_AXIL_rvalid  ),
    .M00_AXIL_wdata     (M00_AXIL_wdata   ),
    .M00_AXIL_wready    (M00_AXIL_wready  ),
    .M00_AXIL_wstrb     (M00_AXIL_wstrb   ),
    .M00_AXIL_wvalid    (M00_AXIL_wvalid  ),
    .git_hash           (git_hash         ),
    .timestamp          (timestamp        ),
    .dfx_active         (dfx_active       ),
    .clk100             (clk100           ),
    .rstn               (rstn             ),
    .led_div_i          ('0               ),
    .led_o              (bd_led),//RADIO_LED[0]     ),//Yellow
    .led_wren_i         ('0               )
  );

//  led_cnt led_cnt_inst (
//    .rst    (~rstn        ),
//    .clk100 (clk100       ),
//    .div_i  (5'h2         ),
//    .wren_i ('0           ),
//    .led_o  (RADIO_LED[1] ) //BLUE
//  );

dfx_axi_mgr dfx_axi_mgr_inst (
  .clk                    (clk100             ),    
  .resetn                 (rstn               ),  
  .shutdown_requested     (shutdown_requested ),
  .in_shutdown            (in_shutdown        ),
  .irq                    (irq                ),
  .wr_irq                 (wr_irq             ),
  .rd_irq                 (rd_irq             ),
  .wr_in_shutdown         (wr_in_shutdown     ),
  .rd_in_shutdown         (rd_in_shutdown     ),
  .request_shutdown       (dfx_active         ),
  .s_axi_awaddr           (M00_AXIL_awaddr[6:0]),
  .s_axi_awprot           (M00_AXIL_awprot   ),
  .s_axi_awvalid          (M00_AXIL_awvalid  ),
  .s_axi_awready          (M00_AXIL_awready  ),
  .s_axi_wdata            (M00_AXIL_wdata    ),
  .s_axi_wstrb            (M00_AXIL_wstrb    ),
  .s_axi_wvalid           (M00_AXIL_wvalid   ),
  .s_axi_wready           (M00_AXIL_wready   ),
  .s_axi_bresp            (M00_AXIL_bresp    ),
  .s_axi_bvalid           (M00_AXIL_bvalid   ),
  .s_axi_bready           (M00_AXIL_bready   ),
  .s_axi_araddr           (M00_AXIL_araddr[6:0]),
  .s_axi_arprot           (M00_AXIL_arprot   ),
  .s_axi_arvalid          (M00_AXIL_arvalid  ),
  .s_axi_arready          (M00_AXIL_arready  ),
  .s_axi_rdata            (M00_AXIL_rdata    ),
  .s_axi_rresp            (M00_AXIL_rresp    ),
  .s_axi_rvalid           (M00_AXIL_rvalid   ),
  .s_axi_rready           (M00_AXIL_rready   ),

  .m_axi_rdata            (m_axi_mgr_rdata    ),    // input wire [31 : 0] m_axi_rdata
  .m_axi_rresp            (m_axi_mgr_rresp    ),    // input wire [1 : 0] m_axi_rresp
  .m_axi_rvalid           (m_axi_mgr_rvalid   ),    // input wire m_axi_rvalid
  .m_axi_rready           (m_axi_mgr_rready   ),    // output wire m_axi_rready
  .m_axi_awaddr           (m_axi_mgr_awaddr[6:0]),  // output wire [6 : 0] m_axi_awaddr
  .m_axi_awprot           (m_axi_mgr_awprot   ),    // output wire [2 : 0] m_axi_awprot
  .m_axi_awvalid          (m_axi_mgr_awvalid  ),    // output wire m_axi_awvalid
  .m_axi_awready          (m_axi_mgr_awready  ),    // input wire m_axi_awready
  .m_axi_wdata            (m_axi_mgr_wdata    ),    // output wire [31 : 0] m_axi_wdata
  .m_axi_wstrb            (m_axi_mgr_wstrb    ),    // output wire [3 : 0] m_axi_wstrb
  .m_axi_wvalid           (m_axi_mgr_wvalid   ),    // output wire m_axi_wvalid
  .m_axi_wready           (m_axi_mgr_wready   ),    // input wire m_axi_wready
  .m_axi_bresp            (m_axi_mgr_bresp    ),    // input wire [1 : 0] m_axi_bresp
  .m_axi_bvalid           (m_axi_mgr_bvalid   ),    // input wire m_axi_bvalid
  .m_axi_bready           (m_axi_mgr_bready   ),    // output wire m_axi_bready
  .m_axi_araddr           (m_axi_mgr_araddr[6:0]),  // output wire [6 : 0] m_axi_araddr
  .m_axi_arprot           (m_axi_mgr_arprot   ),    // output wire [2 : 0] m_axi_arprot
  .m_axi_arvalid          (m_axi_mgr_arvalid  ),    // output wire m_axi_arvalid
  .m_axi_arready          (m_axi_mgr_arready  )     // input wire m_axi_arready
);

	axil_reg32_2  #(
		.C_S_AXI_DATA_WIDTH(32),
		.C_S_AXI_ADDR_WIDTH(7)
  ) axil_reg32_2_inst	(
    .git_hash       (git_hash         ),
    .timestamp      (timestamp        ),
		.led            (bd_led           ),
    .led3           (led3             ),
    .led_sel        (led_sel          ),
    .S_AXI_ACLK     (clk100           ),
		.S_AXI_ARESETN  (rstn             ),
		.S_AXI_AWADDR   (m_axi_mgr_awaddr  ),
		.S_AXI_AWPROT   (m_axi_mgr_awprot  ),
		.S_AXI_AWVALID  (m_axi_mgr_awvalid ),
		.S_AXI_AWREADY  (m_axi_mgr_awready ),
		.S_AXI_WDATA    (m_axi_mgr_wdata   ),
		.S_AXI_WSTRB    (m_axi_mgr_wstrb   ),
		.S_AXI_WVALID   (m_axi_mgr_wvalid  ),
		.S_AXI_WREADY   (m_axi_mgr_wready  ),
		.S_AXI_BRESP    (m_axi_mgr_bresp   ),
		.S_AXI_BVALID   (m_axi_mgr_bvalid  ),
		.S_AXI_BREADY   (m_axi_mgr_bready  ),
		.S_AXI_ARADDR   (m_axi_mgr_araddr  ),
		.S_AXI_ARPROT   (m_axi_mgr_arprot  ),
		.S_AXI_ARVALID  (m_axi_mgr_arvalid ),
		.S_AXI_ARREADY  (m_axi_mgr_arready ),
		.S_AXI_RDATA    (m_axi_mgr_rdata   ),
		.S_AXI_RRESP    (m_axi_mgr_rresp   ),
		.S_AXI_RVALID   (m_axi_mgr_rvalid  ),
		.S_AXI_RREADY   (m_axi_mgr_rready  )
	);

  led_cnt_pr led_cnt_pr_inst (
    .rst    (~rstn        ),
    .clk100 (clk100       ),
    .led_o  (RADIO_LED[1] ) //BLUE
  );

  led_cnt2_pr led_cnt2_pr_inst (
    .rst    (~rstn        ),
    .clk100 (clk100       ),
    .led_o  (led2         )//Yellow
  );

  led_cnt3_pr led_cnt3_pr_inst (
    .rst    (~rstn        ),
    .clk100 (clk100       ),
    .led_o  (led3         )
  );

  assign RADIO_LED[0] = (led_sel == 2'h0)? led3:
                        (led_sel == 2'h1)? led2:
                        bd_led;

//-------------------------------------------------------------------------------------------------
  //m_axi_mgr_rdata    ),    // input wire [31 : 0] m_axi_rdata
  //m_axi_mgr_rresp    ),    // input wire [1 : 0] m_axi_rresp
  //m_axi_mgr_rvalid   ),    // input wire m_axi_rvalid
  //m_axi_mgr_rready   ),    // output wire m_axi_rready
  //m_axi_mgr_awaddr[6:0]),  // output wire [6 : 0] m_axi_awaddr
  //m_axi_mgr_awprot   ),    // output wire [2 : 0] m_axi_awprot
  //m_axi_mgr_awvalid  ),    // output wire m_axi_awvalid
  //m_axi_mgr_awready  ),    // input wire m_axi_awready
  //m_axi_mgr_wdata    ),    // output wire [31 : 0] m_axi_wdata
  //m_axi_mgr_wstrb    ),    // output wire [3 : 0] m_axi_wstrb
  //m_axi_mgr_wvalid   ),    // output wire m_axi_wvalid
  //m_axi_mgr_wready   ),    // input wire m_axi_wready
  //m_axi_mgr_bresp    ),    // input wire [1 : 0] m_axi_bresp
  //m_axi_mgr_bvalid   ),    // input wire m_axi_bvalid
  //m_axi_mgr_bready   ),    // output wire m_axi_bready
  //m_axi_mgr_araddr[6:0]),  // output wire [6 : 0] m_axi_araddr
  //m_axi_mgr_arprot   ),    // output wire [2 : 0] m_axi_arprot
  //m_axi_mgr_arvalid  ),    // output wire m_axi_arvalid
  //m_axi_mgr_arready  )     // input wire m_axi_arready

/*
// without these assign statements, build still runs, put the connections at the AXI ILA get optimized out.
  assign s_axi_mgr_wready     = m_axi_mgr_wready ;
  assign s_axi_mgr_awaddr     = m_axi_mgr_awaddr ;
  assign s_axi_mgr_bresp      = m_axi_mgr_bresp  ;
  assign s_axi_mgr_bvalid     = m_axi_mgr_bvalid ;
  assign s_axi_mgr_bready     = m_axi_mgr_bready ;
  assign s_axi_mgr_araddr     = m_axi_mgr_araddr ;
  assign s_axi_mgr_rready     = m_axi_mgr_rready ;
  assign s_axi_mgr_wvalid     = m_axi_mgr_wvalid ;
  assign s_axi_mgr_arvalid    = m_axi_mgr_arvalid;
  assign s_axi_mgr_arready    = m_axi_mgr_arready;
  assign s_axi_mgr_rdata      = m_axi_mgr_rdata  ;
  assign s_axi_mgr_awvalid    = m_axi_mgr_awvalid;
  assign s_axi_mgr_awready    = m_axi_mgr_awready;
  assign s_axi_mgr_rresp      = m_axi_mgr_rresp  ;
  assign s_axi_mgr_wdata      = m_axi_mgr_wdata  ;
  assign s_axi_mgr_wstrb      = m_axi_mgr_wstrb  ;
  assign s_axi_mgr_rvalid     = m_axi_mgr_rvalid ;
  assign s_axi_mgr_arprot     = m_axi_mgr_arprot ;
  assign s_axi_mgr_awprot     = m_axi_mgr_awprot ;


ila_axi0 ila_axi0_m (
	.clk(clk100), // input wire clk
	.probe0(    s_axi_mgr_wready    ), // input wire [0:0] probe0  
	.probe1(    s_axi_mgr_awaddr    ), // input wire [31:0]  probe1 
	.probe2(    s_axi_mgr_bresp     ), // input wire [1:0]  probe2 
	.probe3(    s_axi_mgr_bvalid    ), // input wire [0:0]  probe3 
	.probe4(    s_axi_mgr_bready    ), // input wire [0:0]  probe4 
	.probe5(    s_axi_mgr_araddr    ), // input wire [31:0]  probe5 
	.probe6(    s_axi_mgr_rready    ), // input wire [0:0]  probe6 
	.probe7(    s_axi_mgr_wvalid    ), // input wire [0:0]  probe7 
	.probe8(    s_axi_mgr_arvalid   ), // input wire [0:0]  probe8 
	.probe9(    s_axi_mgr_arready   ), // input wire [0:0]  probe9 
	.probe10(   s_axi_mgr_rdata     ), // input wire [31:0]  probe10 
	.probe11(   s_axi_mgr_awvalid   ), // input wire [0:0]  probe11 
	.probe12(   s_axi_mgr_awready   ), // input wire [0:0]  probe12 
	.probe13(   s_axi_mgr_rresp     ), // input wire [1:0]  probe13 
	.probe14(   s_axi_mgr_wdata     ), // input wire [31:0]  probe14 
	.probe15(   s_axi_mgr_wstrb     ), // input wire [3:0]  probe15 
	.probe16(   s_axi_mgr_rvalid    ), // input wire [0:0]  probe16 
	.probe17(   s_axi_mgr_arprot    ), // input wire [2:0]  probe17  
	.probe18(   s_axi_mgr_awprot    )   // input wire [2:0]  probe18
);


ila_axi0 ila_axi0_s (
	.clk(clk100), // input wire clk
	.probe0(    M00_AXIL_WREADY    ), // input wire [0:0] probe0  
	.probe1(    M00_AXIL_AWADDR    ), // input wire [31:0]  probe1 
	.probe2(    M00_AXIL_BRESP     ), // input wire [1:0]  probe2 
	.probe3(    M00_AXIL_BVALID    ), // input wire [0:0]  probe3 
	.probe4(    M00_AXIL_BREADY    ), // input wire [0:0]  probe4 
	.probe5(    M00_AXIL_ARADDR    ), // input wire [31:0]  probe5 
	.probe6(    M00_AXIL_RREADY    ), // input wire [0:0]  probe6 
	.probe7(    M00_AXIL_WVALID    ), // input wire [0:0]  probe7 
	.probe8(    M00_AXIL_ARVALID   ), // input wire [0:0]  probe8 
	.probe9(    M00_AXIL_ARREADY   ), // input wire [0:0]  probe9 
	.probe10(   M00_AXIL_RDATA     ), // input wire [31:0]  probe10 
	.probe11(   M00_AXIL_AWVALID   ), // input wire [0:0]  probe11 
	.probe12(   M00_AXIL_AWREADY   ), // input wire [0:0]  probe12 
	.probe13(   M00_AXIL_RRESP     ), // input wire [1:0]  probe13 
	.probe14(   M00_AXIL_WDATA     ), // input wire [31:0]  probe14 
	.probe15(   M00_AXIL_WSTRB     ), // input wire [3:0]  probe15 
	.probe16(   M00_AXIL_RVALID    ), // input wire [0:0]  probe16 
	.probe17(   M00_AXIL_ARPROT    ), // input wire [2:0]  probe17  
	.probe18(   M00_AXIL_AWPROT    ) // input wire [2:0]  probe18
);


//assign probe0[15:13] = '0;
//assign probe0[12]   = shutdown_requested;
//assign probe0[11]   = in_shutdown       ;
//assign probe0[10]   = irq               ;
//assign probe0[9]    = wr_irq            ;
//assign probe0[8]    = rd_irq            ;
//assign probe0[7]    = wr_in_shutdown    ;
//assign probe0[6]    = rd_in_shutdown    ;
//assign probe0[5]    = dfx_active;
//assign probe0[4]    = led3;
//assign probe0[3]    = led2;
//assign probe0[2]    = bd_led;
//assign probe0[1:0]  = led_sel;


ila1 ila1_inst (
	.clk      (clk100), // input wire clk
  .probe15  ('0),
  .probe14  ('0),
  .probe13  ('0),
  .probe12  ('0),
  .probe11  (shutdown_requested),
  .probe10  (in_shutdown       ),
  .probe9   (irq               ),
  .probe8   (wr_irq            ),
  .probe7   (rd_irq            ),
  .probe6   (wr_in_shutdown    ),
  .probe5   (rd_in_shutdown    ),
  .probe4   (dfx_active        ),
  .probe3   (led3              ),
  .probe2   (led2              ),
  .probe1   (bd_led            ),
	.probe0   (led_sel)
);
*/


endmodule
//-------------------------------------------------------------------------------------------------

// blackbox definition (only for DFX, otherwise remove)
// do I actually need these...? test and verify...
module led_cnt_pr (
  input   rst,
  input   clk100,
  output  led_o);
endmodule

// blackbox definition
module led_cnt2_pr (
  input   rst,
  input   clk100,
  output  led_o);
endmodule

// blackbox definition
module led_cnt3_pr (
  input   rst,
  input   clk100,
  output  led_o);
endmodule

module axil_reg32_2 #
	(
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 7
	)(
  input [63:0] git_hash,
  input [31:0] timestamp,
	input         led,
	input         led3,
  output [1:0]  led_sel,
  input      S_AXI_ACLK,
	input      S_AXI_ARESETN,
	input     [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
	input     [2 : 0] S_AXI_AWPROT,
	input      S_AXI_AWVALID,
	output      S_AXI_AWREADY,
	input     [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
	input     [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
	input      S_AXI_WVALID,
	output      S_AXI_WREADY,
	output     [1 : 0] S_AXI_BRESP,
	output      S_AXI_BVALID,
	input      S_AXI_BREADY,
	input     [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
	input     [2 : 0] S_AXI_ARPROT,
	input      S_AXI_ARVALID,
	output      S_AXI_ARREADY,
	output     [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
	output     [1 : 0] S_AXI_RRESP,
	output      S_AXI_RVALID,
	input      S_AXI_RREADY);
endmodule