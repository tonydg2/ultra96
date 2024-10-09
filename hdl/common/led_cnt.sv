
module led_cnt (
  input         rst,
  input         clk100,
  input   [4:0] div_i,
  input         wren_i,
  output        led_o,
  output        led_int_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////

`ifdef SYNTHESIS
  localparam  [27:0]  CNT_1S = 28'h5F5E100;
`else
  localparam  [27:0]  CNT_1S = 28'h5F5E100/100000; // sim
`endif

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

///////////////////////////////////////////////////////////////////////////////////////////////////
// Interrupt
// Interrupts must be minimum 40ns wide for GIC to detect. This is probably for 'level' triggered
//    experiment later, make wide now 

  logic [10:0] led_sr;
  //logic led_sr;

  always_ff @(posedge clk100) begin 
    if (rst)  led_sr  <= '0;
    else      led_sr  <= {led_sr[$bits(led_sr)-2:0],led};
    //else      led_sr  <= led;
  end 

  assign led_int_o = ((led_sr[$bits(led_sr)-1] == 1'b0) && (|led_sr[$bits(led_sr)-2:0] || led == 1'b1)) ? '1 : '0;
  //assign led_int_o = ((led_sr[7] == 1'b0) && (|led_sr[6:0] || led == 1'b1)) ? '1 : '0;
  //assign led_int_o = (led_sr == 1'b0 && led == 1'b1) ? '1 : '0;


endmodule