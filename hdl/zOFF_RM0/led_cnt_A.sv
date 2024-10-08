// Verilog wrapper

module led_cnt_pr (
  input         rst,
  input         clk100,
  output        led_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////

 led_cnt led_cnt_inst (
   .rst    (rst      ),
   .clk100 (clk100   ),
   .div_i  (5'h1     ),
   .wren_i (1'b0     ),
   .led_o  (led_o    )
 );

endmodule