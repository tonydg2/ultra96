//  0 = 1SEC
//  8'h2B  ~1sec
//  8'hFF ~0.17sec

module led_cnt (
  input           rst,
  input           clk100,
  input   [11:0]  div_i,
  input           wren_i,
  input           int_clr_i,
  output  [31:0]  int_cnt_o,
  output          led_o,
  output          led_int_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////
  // @100MHz
  localparam  [31:0]  SEC1  = 28'h5F5_E100;
  localparam  [31:0]  SEC10 = 28'h3B9A_CA00;
  localparam  [31:0]  SEC43 = 32'hFFFF_FFFF; // ~42.95 sec HALF PERIOD

`ifdef SYNTHESIS
  localparam  [31:0]  MAX_CNT = SEC43;
`else
  localparam  [31:0]  MAX_CNT = SEC43/100000; // sim
`endif

  logic       [31:0]  cnt, cnt_max, int_cnt;
  logic               led, int_latch;
///////////////////////////////////////////////////////////////////////////////////////////////////

//  assign cnt_max =  (div_i == 0)     ? MAX_CNT :
//                    (div_i > 5'h14)  ? MAX_CNT :
//                    (MAX_CNT / div_i);
    
    assign cnt_max =  (div_i == 0) ? SEC1 :     // 1sec exact if 0
                      (MAX_CNT / div_i);        // max div ~43/255 =~ 0.17s


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

///////////////////////////////////////////////////////////////////////////////////////////////////
// Interrupt
// Interrupts must be minimum 40ns wide for GIC to detect. This is probably for 'level' triggered
//    experiment later, make wide now 

  logic [20:0] led_sr;
  //logic led_sr;

  always_ff @(posedge clk100) begin 
    if (rst)  led_sr  <= '0;
    else      led_sr  <= {led_sr[$bits(led_sr)-2:0],led};
    //else      led_sr  <= led;
  end 

  assign led_int = ((led_sr[$bits(led_sr)-1] == 1'b0) && (|led_sr[$bits(led_sr)-2:0] || led == 1'b1)) ? '1 : '0;
  //assign led_int_o = ((led_sr[7] == 1'b0) && (|led_sr[6:0] || led == 1'b1)) ? '1 : '0;
  //assign led_int_o = (led_sr == 1'b0 && led == 1'b1) ? '1 : '0;


  always_latch begin
    if      (rst || int_clr_i)  int_latch <= '0;
    else if (led_int)           int_latch <= 1'b1;
  end

  assign led_int_o = int_latch;

  always_ff @(posedge clk100) begin 
    if (rst || int_clr_i)                       int_cnt <= '0;
    else if (led_sr[0] == 1'b0 && led == 1'b1)  int_cnt <= int_cnt + 1;
  end

  assign int_cnt_o = int_cnt;

endmodule