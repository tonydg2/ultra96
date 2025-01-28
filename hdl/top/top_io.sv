module top_io (
    output [1:0]    RADIO_LED ,   // 1=BLUE, 0=Yellow
    input           H_CLOCK   ,
    input  [3:0]    HD_N      ,
    input  [3:0]    HD_P      ,
    input           H_CLK_N   , 
    input           H_CLK_P    
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  logic [4:0] led_div1;
  logic clk100,clk200,clk400,clk600,mmcm_lock,hclk,hclock,hclock_bufg;
  logic [3:0] hdata;

///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .clk100       (clk100           ),
    .clk_200      (clk200           ),
    .clk_400      (clk400           ),
    .clk_600      (clk600           ),
    .locked       (mmcm_lock        ),
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

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : ibufds_loop
      IBUFDS ibufds_inst (
        .I  (HD_P[i]  ),  // Positive input for instance i
        .IB (HD_N[i]  ),  // Negative input for instance i
        .O  (hdata[i] )   // Output for instance i
      );
    end
  endgenerate

  IBUFDS ibufds_H_CLK (
    .I  (H_CLK_P  ),  // Positive input for instance i
    .IB (H_CLK_N  ),  // Negative input for instance i
    .O  (hclk     )   // Output for instance i
  );

  IBUF IBUF_H_CLOCK (
    .I(H_CLOCK      ), // 1-bit input: Buffer input
    .O(hclock_bufg  )  // 1-bit output: Buffer output
  );

  BUFG BUFG_inst (
    .I(hclock_bufg),  // 1-bit input: Clock input.
    .O(hclock)   // 1-bit output: Clock output.
  );

///////////////////////////////////////////////////////////////////////////////////////////////////
  ila1 ila1 (
  	.clk    (clk200),
  	.probe0 (hdata),
  	.probe1 (hclock),
  	.probe2 (hclk)
  );


endmodule
