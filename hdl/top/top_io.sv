module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  localparam integer ADDRW = 7;
  localparam integer DATAW = 32;

  logic [4:0] led_div1,div0,div1;

///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .led_div0_o_0_0   (div0         ),
    .led_div1_o_0_0   (div1         ),
    .peripheral_rstn  (periph_rstn  ),
    .clk100           (clk100       ),
    .rstn             (rstn         ),
    .led_div1_o       (led_div1     ),
    .led_o            (RADIO_LED[0] )//Yellow
  );


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
  	.probe1(div1) // input wire [4:0]  probe1
  );

endmodule
