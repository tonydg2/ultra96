module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  localparam integer ADDRW = 7;
  localparam integer DATAW = 32;

  logic   [ADDRW-1:0]     AXIL_0_araddr   ,AXIL_1_araddr    ;
  logic   [2:0]           AXIL_0_arprot   ,AXIL_1_arprot    ;
  logic                   AXIL_0_arready  ,AXIL_1_arready   ;
  logic                   AXIL_0_arvalid  ,AXIL_1_arvalid   ;
  logic   [ADDRW-1:0]     AXIL_0_awaddr   ,AXIL_1_awaddr    ;
  logic   [2:0]           AXIL_0_awprot   ,AXIL_1_awprot    ;
  logic                   AXIL_0_awready  ,AXIL_1_awready   ;
  logic                   AXIL_0_awvalid  ,AXIL_1_awvalid   ;
  logic                   AXIL_0_bready   ,AXIL_1_bready    ;
  logic   [1:0]           AXIL_0_bresp    ,AXIL_1_bresp     ;
  logic                   AXIL_0_bvalid   ,AXIL_1_bvalid    ;
  logic   [DATAW-1:0]     AXIL_0_rdata    ,AXIL_1_rdata     ;
  logic                   AXIL_0_rready   ,AXIL_1_rready    ;
  logic   [1:0]           AXIL_0_rresp    ,AXIL_1_rresp     ;
  logic                   AXIL_0_rvalid   ,AXIL_1_rvalid    ;
  logic   [DATAW-1:0]     AXIL_0_wdata    ,AXIL_1_wdata     ;
  logic                   AXIL_0_wready   ,AXIL_1_wready    ;
  logic   [(DATAW/8)-1:0] AXIL_0_wstrb    ,AXIL_1_wstrb     ;
  logic                   AXIL_0_wvalid   ,AXIL_1_wvalid    ;

  logic [4:0] led_div1,div0,div1,div0_2,div1_2;

///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .AXIL_M0_araddr   (AXIL_0_araddr    ),
    .AXIL_M0_arprot   (AXIL_0_arprot    ),
    .AXIL_M0_arready  (AXIL_0_arready   ),
    .AXIL_M0_arvalid  (AXIL_0_arvalid   ),
    .AXIL_M0_awaddr   (AXIL_0_awaddr    ),
    .AXIL_M0_awprot   (AXIL_0_awprot    ),
    .AXIL_M0_awready  (AXIL_0_awready   ),
    .AXIL_M0_awvalid  (AXIL_0_awvalid   ),
    .AXIL_M0_bready   (AXIL_0_bready    ),
    .AXIL_M0_bresp    (AXIL_0_bresp     ),
    .AXIL_M0_bvalid   (AXIL_0_bvalid    ),
    .AXIL_M0_rdata    (AXIL_0_rdata     ),
    .AXIL_M0_rready   (AXIL_0_rready    ),
    .AXIL_M0_rresp    (AXIL_0_rresp     ),
    .AXIL_M0_rvalid   (AXIL_0_rvalid    ),
    .AXIL_M0_wdata    (AXIL_0_wdata     ),
    .AXIL_M0_wready   (AXIL_0_wready    ),
    .AXIL_M0_wstrb    (AXIL_0_wstrb     ),
    .AXIL_M0_wvalid   (AXIL_0_wvalid    ),
    
    //.AXIL_M1_araddr   (AXIL_1_araddr    ),
    //.AXIL_M1_arprot   (AXIL_1_arprot    ),
    //.AXIL_M1_arready  (AXIL_1_arready   ),
    //.AXIL_M1_arvalid  (AXIL_1_arvalid   ),
    //.AXIL_M1_awaddr   (AXIL_1_awaddr    ),
    //.AXIL_M1_awprot   (AXIL_1_awprot    ),
    //.AXIL_M1_awready  (AXIL_1_awready   ),
    //.AXIL_M1_awvalid  (AXIL_1_awvalid   ),
    //.AXIL_M1_bready   (AXIL_1_bready    ),
    //.AXIL_M1_bresp    (AXIL_1_bresp     ),
    //.AXIL_M1_bvalid   (AXIL_1_bvalid    ),
    //.AXIL_M1_rdata    (AXIL_1_rdata     ),
    //.AXIL_M1_rready   (AXIL_1_rready    ),
    //.AXIL_M1_rresp    (AXIL_1_rresp     ),
    //.AXIL_M1_rvalid   (AXIL_1_rvalid    ),
    //.AXIL_M1_wdata    (AXIL_1_wdata     ),
    //.AXIL_M1_wready   (AXIL_1_wready    ),
    //.AXIL_M1_wstrb    (AXIL_1_wstrb     ),
    //.AXIL_M1_wvalid   (AXIL_1_wvalid    ),

    .div02 (div0_2),
    .div12 (div1_2),

    .peripheral_rstn  (periph_rstn      ),
    .clk100           (clk100           ),
    .rstn             (rstn             ),
    .led_div1_o       (led_div1         ),
    .led_o            (RADIO_LED[0]     )//Yellow
  );

  reg_bd_wrapper reg_bd_wrapper_inst (
    .AXIL_S0_araddr  (AXIL_0_araddr   ),
    .AXIL_S0_arprot  (AXIL_0_arprot   ),
    .AXIL_S0_arready (AXIL_0_arready  ),
    .AXIL_S0_arvalid (AXIL_0_arvalid  ),
    .AXIL_S0_awaddr  (AXIL_0_awaddr   ),
    .AXIL_S0_awprot  (AXIL_0_awprot   ),
    .AXIL_S0_awready (AXIL_0_awready  ),
    .AXIL_S0_awvalid (AXIL_0_awvalid  ),
    .AXIL_S0_bready  (AXIL_0_bready   ),
    .AXIL_S0_bresp   (AXIL_0_bresp    ),
    .AXIL_S0_bvalid  (AXIL_0_bvalid   ),
    .AXIL_S0_rdata   (AXIL_0_rdata    ),
    .AXIL_S0_rready  (AXIL_0_rready   ),
    .AXIL_S0_rresp   (AXIL_0_rresp    ),
    .AXIL_S0_rvalid  (AXIL_0_rvalid   ),
    .AXIL_S0_wdata   (AXIL_0_wdata    ),
    .AXIL_S0_wready  (AXIL_0_wready   ),
    .AXIL_S0_wstrb   (AXIL_0_wstrb    ),
    .AXIL_S0_wvalid  (AXIL_0_wvalid   ),
    .S_AXI_ACLK_0    (clk100          ),
    .S_AXI_ARESETN_0 (periph_rstn     ),
    .led_div0_o_0    (div0            ),
    .led_div1_o_0    (div1            )
  );

//  another_reg_bd_wrapper another_reg_bd_wrapper_inst (
//    .AXIL_S0_araddr  (AXIL_1_araddr   ),
//    .AXIL_S0_arprot  (AXIL_1_arprot   ),
//    .AXIL_S0_arready (AXIL_1_arready  ),
//    .AXIL_S0_arvalid (AXIL_1_arvalid  ),
//    .AXIL_S0_awaddr  (AXIL_1_awaddr   ),
//    .AXIL_S0_awprot  (AXIL_1_awprot   ),
//    .AXIL_S0_awready (AXIL_1_awready  ),
//    .AXIL_S0_awvalid (AXIL_1_awvalid  ),
//    .AXIL_S0_bready  (AXIL_1_bready   ),
//    .AXIL_S0_bresp   (AXIL_1_bresp    ),
//    .AXIL_S0_bvalid  (AXIL_1_bvalid   ),
//    .AXIL_S0_rdata   (AXIL_1_rdata    ),
//    .AXIL_S0_rready  (AXIL_1_rready   ),
//    .AXIL_S0_rresp   (AXIL_1_rresp    ),
//    .AXIL_S0_rvalid  (AXIL_1_rvalid   ),
//    .AXIL_S0_wdata   (AXIL_1_wdata    ),
//    .AXIL_S0_wready  (AXIL_1_wready   ),
//    .AXIL_S0_wstrb   (AXIL_1_wstrb    ),
//    .AXIL_S0_wvalid  (AXIL_1_wvalid   ),
//    .S_AXI_ACLK_0    (clk100          ),
//    .S_AXI_ARESETN_0 (periph_rstn     ),
//    .led_div0_o_0    (div0_2          ),
//    .led_div1_o_0    (div1_2          )
//  );


  led_cnt led_cnt_inst (
    .rst      (~rstn        ),
    .clk100   (clk100       ),
    .div_i    (led_div1     ),
    .wren_i   ('0           ),
    .led_o    (RADIO_LED[1] ) //BLUE
  );


  ila1 ila1_inst (
  	.clk(clk100), // input wire clk
  	.probe0(div0), // input wire [4:0]  probe0  
  	.probe1(div1), // input wire [4:0]  probe1
  	.probe2(div0_2), // input wire [4:0]  probe0  
  	.probe3(div1_2) // input wire [4:0]  probe1
  );

endmodule
