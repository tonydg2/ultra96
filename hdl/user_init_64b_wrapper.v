//
module user_init_64b_wrapper (
  output [63:0]   value_o
);

  // parameter(generic) example
  //user_init_64b #(
  //  .gen1 (),
  //  .gen2 ()
  //) user_init_64b_inst (
  //  .clk      (1'b0),
  //  .value_o  (value_o)
  //);



  user_init_64b user_init_64b_inst (
    .clk      (1'b0),
    .value_o  (value_o)
  );

endmodule

