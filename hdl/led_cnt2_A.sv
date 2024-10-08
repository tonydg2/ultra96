// Verilog wrapper

module led_cnt2_pr (
  input         rst,
  input         clk100,
  output        led_int_o,
  output        led_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////

 led_cnt led_cnt_inst (
   .rst       (rst      ),
   .clk100    (clk100   ),
   .div_i     (5'hB     ),
   .wren_i    (1'b0     ),
   .led_int_o (led_int_o),
   .led_o     (led_o    )
 );

endmodule
