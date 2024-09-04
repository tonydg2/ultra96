module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .clk100       (clk100       ),
    .rstn         (rstn         ),
    .led_div_i    ('0           ),
    .led_o        (RADIO_LED[0] ),//Yellow
    .led_wren_i   ('0           )
  );

  led_cnt led_cnt_inst (
    .rst    (~rstn        ),
    .clk100 (clk100       ),
    .div_i  (5'h2         ),
    .wren_i ('0           ),
    .led_o  (RADIO_LED[1] ) //BLUE
  );


endmodule