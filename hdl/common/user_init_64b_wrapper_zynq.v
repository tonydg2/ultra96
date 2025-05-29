//
// includes usr_access for zynq ultrascale+

module user_init_64b_wrapper_zynq (
  output [63:0]   value_o,
  output          usr_access_cfgclk_o,
  output          usr_access_datavalid_o,
  output [31:0]   usr_access_data_o
);


  user_init_64b user_init_64b_inst (
    .clk      (1'b0),
    .value_o  (value_o)
  );

  USR_ACCESSE2 USR_ACCESSE2_inst (
     .CFGCLK    (usr_access_cfgclk_o),   // 1-bit output: Configuration Clock
     .DATA      (usr_access_data_o),     // 32-bit output: Configuration Data reflecting the contents of the AXSS register
     .DATAVALID (usr_access_datavalid_o) // 1-bit output: Active-High Data Valid
  );

endmodule

