
module led_cnt (
  input         rst,
  input         clk100,
  input   [4:0] div_i,
  input         wren_i,
  output        led_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  localparam  [27:0]  CNT_1S = 28'h5F5E100;
  
  logic       [27:0]  cnt, cnt_max;
  logic               led;

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