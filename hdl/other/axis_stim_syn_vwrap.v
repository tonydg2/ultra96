
`timescale 1ns / 1ps  // <time_unit>/<time_precision>

module axis_stim_syn_vwrap #
	(
		parameter integer             DATA_WIDTH	  = 32 // change to TDATA_NUM_BYTES
	)
	(
		input                         clk		        ,
    input                         rst           ,
    input                         start         ,
    output [DATA_WIDTH-1 : 0]     M_AXIS_tdata  ,
    output [3:0]                  M_AXIS_tdest  ,
    output [(DATA_WIDTH/8)-1 : 0] M_AXIS_tkeep  ,
    output                        M_AXIS_tlast  ,
    input                         M_AXIS_tready ,
    output                        M_AXIS_tvalid
  );

  generate if (DATA_WIDTH % 8 != 0)
    initial $fatal("ERROR: %m DATA_WIDTH (%0d) must be a multiple of 8", DATA_WIDTH);
  endgenerate


//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

  axis_stim_syn #(
    .DATA_WIDTH     (DATA_WIDTH)
  ) axis_stim_syn (
    .clk		         (clk		        ),                  
    .rst		         (rst		        ),                  
    .start           (start         ),         
    .M_AXIS_tdata    (M_AXIS_tdata  ),         
    .M_AXIS_tdest    (M_AXIS_tdest  ),         
    .M_AXIS_tkeep    (M_AXIS_tkeep  ),         
    .M_AXIS_tlast    (M_AXIS_tlast  ),         
    .M_AXIS_tready   (M_AXIS_tready ),         
    .M_AXIS_tvalid   (M_AXIS_tvalid )
  );

endmodule