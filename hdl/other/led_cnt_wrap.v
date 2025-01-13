// Verilog wrapper

module led_cnt_wrap (
  input         rst,
  input         clk100,
  input   [4:0] div_i,
  input         wren_i,
  output        led_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  led_cnt_pr led_cnt_pr_inst (
    .rst    (rst      ),
    .clk100 (clk100   ),
    .led_o  (led_o    )
  );

endmodule

// blackbox definition
module led_cnt_pr (
  input   rst,
  input   clk100,
  output  led_o);
endmodule
