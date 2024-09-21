
`timescale 1ns / 1ps  // <time_unit>/<time_precision>

module axis_stim_syn #
	(
		parameter integer                         DATA_WIDTH	  = 32 // change to TDATA_NUM_BYTES
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

logic [DATA_WIDTH-1 : 0]     tdata      , tdata2=0 ;
logic [3:0]                  tdest      , tdest2=0 ;
logic [(DATA_WIDTH/8)-1 : 0] tkeep='1   , tkeep2='1 ;
logic                        tlast      , tlast2=0;
logic                        tready     , tready2;
logic                        tvalid=0   , tvalid2=0;

assign M_AXIS_tdata   = tdata2 ;
assign M_AXIS_tdest   = tdest2 ;
assign M_AXIS_tkeep   = tkeep2 ;
assign M_AXIS_tlast   = tlast2 ;
assign M_AXIS_tvalid  = tvalid2;
assign tready = M_AXIS_tready;


//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

  logic [7:0] cntr = 0, hiCnt = 0;
  logic tdest_i = 1;

  always @(posedge clk) begin 
    if (rst) begin
      cntr <= 0;
      tvalid <= 0;
    end else if (tready) begin
      cntr <= cntr + 1;
    end
    if (cntr == '1) tvalid <= ~tvalid;
    if ((cntr == '1) & (tvalid == 0)) tdest_i <= ~tdest_i;
  end

  always @(posedge clk) begin 
    if (rst)        hiCnt <= 0;
    else if (tlast) hiCnt <= hiCnt + 1;
  end 


  //assign tdata = (!rst)? {24'hAA6600,cntr}:'0;
  assign tdata = (!rst)? {8'hAA,hiCnt,8'h00,cntr}:'0;
  assign tlast = ((tvalid == 1) & (cntr == '1))? '1:0;
  assign tdest = {3'h0,tdest_i};

// Register signals before sending to IP!!!!!
// without this, there were issues with last word of frame
  always @(posedge clk) begin 
    tdata2   <= tdata ;
    tdest2   <= tdest ;
    tkeep2   <= tkeep ;
    tlast2   <= tlast ;
    tvalid2  <= tvalid;
  end

endmodule