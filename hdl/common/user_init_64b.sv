//
module user_init_64b (
  input         clk,
  output [63:0] value_o
);

  generate
    for(genvar i=0;i<64;i++) begin 
      (* DONT_TOUCH = "true" *) FDRE #(
        .INIT           (1'b0),
        .IS_C_INVERTED  (1'b0),
        .IS_D_INVERTED  (1'b0),
        .IS_R_INVERTED  (1'b0)
      ) FDRE_inst (
        .Q    (value_o[i]),
        .C    (clk),  
        .CE   (1'b0),    
        .D    (1'b0),  
        .R    (1'b0)
      );
    end 
  endgenerate

endmodule


