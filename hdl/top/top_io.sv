module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  logic [4:0]   led_div1;
  logic [63:0]  git_hash_scripts,git_hash_top;
  logic [31:0]  timestamp_scripts,time_stamp_top;

///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .clk100               (clk100           ),
    .rstn                 (rstn             ),
    .git_hash_scripts_0   (git_hash_scripts ),
    .git_hash_top_0       (git_hash_top     ),
    .timestamp_scripts_0  (timestamp_scripts),
    .timestamp_top_0      (time_stamp_top   ),
    .led_div1_o           (led_div1         ),
    .led_o                (RADIO_LED[0]     )//Yellow
  );

  led_cnt led_cnt_inst (
    .rst      (~rstn        ),
    .clk100   (clk100       ),
    .div_i    (led_div1     ),
    .wren_i   ('0           ),
    .led_o    (RADIO_LED[1] ) //BLUE
  );

  user_init_64b git_hash_scripts_inst (
    .clk      (1'b0),
    .value_o  (git_hash_scripts)
  );

  user_init_32b timestamp_scripts_inst (
    .clk      (1'b0),
    .value_o  (timestamp_scripts)
  );

  user_init_64b git_hash_top_inst (
    .clk      (1'b0),
    .value_o  (git_hash_top)
  );

  user_init_32b time_stamp_top_inst (
    .clk      (1'b0),
    .value_o  (time_stamp_top)
  );


endmodule
