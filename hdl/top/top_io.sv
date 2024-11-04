module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  localparam integer ADDRW = 7;
  localparam integer DATAW = 32;

  logic   [ADDRW-1:0]     AXIL_araddr    ;
  logic   [2:0]           AXIL_arprot    ;
  logic                   AXIL_arready   ;
  logic                   AXIL_arvalid   ;
  logic   [ADDRW-1:0]     AXIL_awaddr    ;
  logic   [2:0]           AXIL_awprot    ;
  logic                   AXIL_awready   ;
  logic                   AXIL_awvalid   ;
  logic                   AXIL_bready    ;
  logic   [1:0]           AXIL_bresp     ;
  logic                   AXIL_bvalid    ;
  logic   [DATAW-1:0]     AXIL_rdata     ;
  logic                   AXIL_rready    ;
  logic   [1:0]           AXIL_rresp     ;
  logic                   AXIL_rvalid    ;
  logic   [DATAW-1:0]     AXIL_wdata     ;
  logic                   AXIL_wready    ;
  logic   [(DATAW/8)-1:0] AXIL_wstrb     ;
  logic                   AXIL_wvalid    ;

  logic [4:0] led_div1,div0,div1;

///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .AXIL_M0_araddr   (AXIL_araddr  ),
    .AXIL_M0_arprot   (AXIL_arprot  ),
    .AXIL_M0_arready  (AXIL_arready ),
    .AXIL_M0_arvalid  (AXIL_arvalid ),
    .AXIL_M0_awaddr   (AXIL_awaddr  ),
    .AXIL_M0_awprot   (AXIL_awprot  ),
    .AXIL_M0_awready  (AXIL_awready ),
    .AXIL_M0_awvalid  (AXIL_awvalid ),
    .AXIL_M0_bready   (AXIL_bready  ),
    .AXIL_M0_bresp    (AXIL_bresp   ),
    .AXIL_M0_bvalid   (AXIL_bvalid  ),
    .AXIL_M0_rdata    (AXIL_rdata   ),
    .AXIL_M0_rready   (AXIL_rready  ),
    .AXIL_M0_rresp    (AXIL_rresp   ),
    .AXIL_M0_rvalid   (AXIL_rvalid  ),
    .AXIL_M0_wdata    (AXIL_wdata   ),
    .AXIL_M0_wready   (AXIL_wready  ),
    .AXIL_M0_wstrb    (AXIL_wstrb   ),
    .AXIL_M0_wvalid   (AXIL_wvalid  ),
    .peripheral_rstn  (periph_rstn  ),
    .clk100           (clk100       ),
    .rstn             (rstn         ),
    .led_div1_o       (led_div1     ),
    .led_o            (RADIO_LED[0] )//Yellow
  );

	axil_reg32_2 #(
		.C_S_AXI_DATA_WIDTH(DATAW),
		.C_S_AXI_ADDR_WIDTH(ADDRW)
  ) axil_reg32_2_inst (
    .git_hash      ('h5789),
    .timestamp     ('h1222),
    .led_div0_o    (div0),
    .led_div1_o    (div1),

		.S_AXI_ACLK    (clk100),
		.S_AXI_ARESETN (rstn),
		.S_AXI_AWADDR  (AXIL_awaddr ),
		.S_AXI_AWPROT  (AXIL_awprot ),
		.S_AXI_AWVALID (AXIL_awvalid),
		.S_AXI_AWREADY (AXIL_awready),
		.S_AXI_WDATA   (AXIL_wdata  ),
		.S_AXI_WSTRB   (AXIL_wstrb  ),
		.S_AXI_WVALID  (AXIL_wvalid ),
		.S_AXI_WREADY  (AXIL_wready ),
		.S_AXI_BRESP   (AXIL_bresp  ),
		.S_AXI_BVALID  (AXIL_bvalid ),
		.S_AXI_BREADY  (AXIL_bready ),
		.S_AXI_ARADDR  (AXIL_araddr ),
		.S_AXI_ARPROT  (AXIL_arprot ),
		.S_AXI_ARVALID (AXIL_arvalid),
		.S_AXI_ARREADY (AXIL_arready),
		.S_AXI_RDATA   (AXIL_rdata  ),
		.S_AXI_RRESP   (AXIL_rresp  ),
		.S_AXI_RVALID  (AXIL_rvalid ),
		.S_AXI_RREADY  (AXIL_rready )
	);

  led_cnt led_cnt_inst (
    .rst      (~rstn        ),
    .clk100   (clk100       ),
    .div_i    (led_div1     ),
    .wren_i   ('0           ),
    .led_o    (RADIO_LED[1] ) //BLUE
  );


//  ila1 ila1_inst (
//  	.clk(clk100), // input wire clk
//  	.probe0(div0), // input wire [4:0]  probe0  
//  	.probe1(div1) // input wire [4:0]  probe1
//  );

endmodule
