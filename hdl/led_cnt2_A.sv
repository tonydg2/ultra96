

module led_cnt2_pr (
  input           rst,
  input           clk100,
  input   [11:0]  div_i,
  input           int_clr_i,
  output  [31:0]  int_cnt_o,
  input           wren_i,
  output          led_int_o,
  output          led_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////

led_cnt led_cnt_inst (
  .rst        (rst      ),
  .clk100     (clk100   ),
  .div_i      (div_i    ),
  .wren_i     (wren_i   ),
  .int_clr_i  (int_clr_i),
  .int_cnt_o  (int_cnt_o),
  .led_int_o  (led_int_o),
  .led_o      (led_o    )
);

endmodule
