module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0]   M00_AXIL_araddr;
logic [2:0]    M00_AXIL_arprot;
logic          M00_AXIL_arready;
logic          M00_AXIL_arvalid;
logic [31:0]   M00_AXIL_awaddr;
logic [2:0]    M00_AXIL_awprot;
logic          M00_AXIL_awready;
logic          M00_AXIL_awvalid;
logic          M00_AXIL_bready;
logic [1:0]    M00_AXIL_bresp;
logic          M00_AXIL_bvalid;
logic [31:0]   M00_AXIL_rdata;
logic          M00_AXIL_rready;
logic [1:0]    M00_AXIL_rresp;
logic          M00_AXIL_rvalid;
logic [31:0]   M00_AXIL_wdata;
logic          M00_AXIL_wready;
logic [3:0]    M00_AXIL_wstrb;
logic          M00_AXIL_wvalid;
logic [63:0]   git_hash;
logic [4:0]    led_div_i;
logic [31:0]   timestamp;


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

	axil_reg32_A  #(
		.C_S_AXI_DATA_WIDTH(32),
		.C_S_AXI_ADDR_WIDTH(7)
  ) axil_reg32_A_inst	(
    .git_hash       (git_hash         ),
    .timestamp      (timestamp        ),
		.led            (bd_led           ),
    .led3           (led3             ),
    .led_sel        (led_sel          ),
    .S_AXI_ACLK     (clk100           ),
		.S_AXI_ARESETN  (rstn             ),
		.S_AXI_AWADDR   (M00_AXIL_awaddr  ),
		.S_AXI_AWPROT   (M00_AXIL_awprot  ),
		.S_AXI_AWVALID  (M00_AXIL_awvalid ),
		.S_AXI_AWREADY  (M00_AXIL_awready ),
		.S_AXI_WDATA    (M00_AXIL_wdata   ),
		.S_AXI_WSTRB    (M00_AXIL_wstrb   ),
		.S_AXI_WVALID   (M00_AXIL_wvalid  ),
		.S_AXI_WREADY   (M00_AXIL_wready  ),
		.S_AXI_BRESP    (M00_AXIL_bresp   ),
		.S_AXI_BVALID   (M00_AXIL_bvalid  ),
		.S_AXI_BREADY   (M00_AXIL_bready  ),
		.S_AXI_ARADDR   (M00_AXIL_araddr  ),
		.S_AXI_ARPROT   (M00_AXIL_arprot  ),
		.S_AXI_ARVALID  (M00_AXIL_arvalid ),
		.S_AXI_ARREADY  (M00_AXIL_arready ),
		.S_AXI_RDATA    (M00_AXIL_rdata   ),
		.S_AXI_RRESP    (M00_AXIL_rresp   ),
		.S_AXI_RVALID   (M00_AXIL_rvalid  ),
		.S_AXI_RREADY   (M00_AXIL_rready  )
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

  assign RADIO_LED[0] = (led_sel)? led3:led2;

endmodule

// blackbox definition (only for DFX, otherwise remove)
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
