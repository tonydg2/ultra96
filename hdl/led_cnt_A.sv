// Verilog wrapper

module led_cnt_pr (
  input         rst,
  input         clk100,
  output        led_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////

// led_cnt led_cnt_inst (
//   .rst    (rst      ),
//   .clk100 (clk100   ),
//   .div_i  (5'h2     ),
//   .wren_i (1'b0     ),
//   .led_o  (led_o    )
// );

///////////////////////////////////////////////////////////////////////////////////////////////////

  localparam [4:0] div_i = 5'h2;

  localparam  [27:0]  CNT_1S = 28'h5F5E100;
  
  logic       [27:0]  cnt, cnt_max;
  logic               led;
  logic wren_i;
  assign wren_i=0;

///////////////////////////////////////////////////////////////////////////////////////////////////

  assign cnt_max =  (div_i == 0)     ? CNT_1S :
                    (div_i > 5'h14)  ? CNT_1S :
                    (CNT_1S / div_i);


  always_ff @(posedge clk100) begin
    if (rst) begin
      cnt  <= '0;
      led  <= '0;
    end else if ((cnt == cnt_max) || (wren_i == 1'b1)) begin
      cnt  <= '0;
      led  <= ~led;
    end else begin 
      cnt  <= cnt + 1;
    end 
  end

  assign led_o = led;

endmodule