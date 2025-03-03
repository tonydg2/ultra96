module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  logic [4:0] led_div1;
  logic clk200;
///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .clk100       (clk100           ),
    .rstn         (rstn             ),
    .led_div1_o   (led_div1         ),
    .led_o        (RADIO_LED[0]     )//Yellow
  );

  led_cnt led_cnt_inst (
    .rst      (~rstn        ),
    .clk100   (clk100       ),
    .div_i    (led_div1     ),
    .wren_i   ('0           ),
    .led_o    (RADIO_LED[1] ) //BLUE
  );

///////////////////////////////////////////////////////////////////////////////////////////////////

  mmcm_clk_wiz mmcm_clk_wiz_inst
   (
    .clk_in1(clk100),
    .clk_200(clk200),
    .locked()
   )


endmodule
