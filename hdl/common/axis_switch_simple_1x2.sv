
module axis_switch_simple_1x2 #
(
  parameter integer DATAW	= 48
)
(
  input                   aclk            ,
  input                   m0_en           ,
  input                   m1_en           ,

  input [DATAW-1:0]       s_axis_tdata    ,
  input                   s_axis_tvalid   ,
  output                  s_axis_tready   ,
  input                   s_axis_tuser    ,
  input                   s_axis_tlast    ,
  input [(DATAW/8)-1:0]   s_axis_tstrb    ,
  input [(DATAW/8)-1:0]   s_axis_tkeep    ,
  input                   s_axis_tid      ,
  input                   s_axis_tdest    ,

  output [DATAW-1:0]      m0_axis_tdata   ,
  output                  m0_axis_tvalid  ,
  input                   m0_axis_tready  ,
  output                  m0_axis_tuser   ,
  output                  m0_axis_tlast   ,
  output [(DATAW/8)-1:0]  m0_axis_tstrb   ,
  output [(DATAW/8)-1:0]  m0_axis_tkeep   ,
  output                  m0_axis_tid     ,
  output                  m0_axis_tdest   ,

  output [DATAW-1:0]      m1_axis_tdata   ,
  output                  m1_axis_tvalid  ,
  input                   m1_axis_tready  ,
  output                  m1_axis_tuser   ,
  output                  m1_axis_tlast   ,
  output [(DATAW/8)-1:0]  m1_axis_tstrb   ,
  output [(DATAW/8)-1:0]  m1_axis_tkeep   ,
  output                  m1_axis_tid     ,
  output                  m1_axis_tdest

);
///////////////////////////////////////////////////////////////////////////////////////////////////

  assign m0_axis_tdata  = (!m1_en) ? s_axis_tdata  : '0; 
  assign m0_axis_tvalid = (!m1_en) ? s_axis_tvalid : '0; 
  assign m0_axis_tuser  = (!m1_en) ? s_axis_tuser  : '0; 
  assign m0_axis_tlast  = (!m1_en) ? s_axis_tlast  : '0; 
  assign m0_axis_tstrb  = (!m1_en) ? s_axis_tstrb  : '0; 
  assign m0_axis_tkeep  = (!m1_en) ? s_axis_tkeep  : '0; 
  assign m0_axis_tid    = (!m1_en) ? s_axis_tid    : '0; 
  assign m0_axis_tdest  = (!m1_en) ? s_axis_tdest  : '0; 

  //assign m0_axis_tdata  = (m0_en) ? s_axis_tdata  : '0; 
  //assign m0_axis_tvalid = (m0_en) ? s_axis_tvalid : '0; 
  //assign m0_axis_tuser  = (m0_en) ? s_axis_tuser  : '0; 
  //assign m0_axis_tlast  = (m0_en) ? s_axis_tlast  : '0; 
  //assign m0_axis_tstrb  = (m0_en) ? s_axis_tstrb  : '0; 
  //assign m0_axis_tkeep  = (m0_en) ? s_axis_tkeep  : '0; 
  //assign m0_axis_tid    = (m0_en) ? s_axis_tid    : '0; 
  //assign m0_axis_tdest  = (m0_en) ? s_axis_tdest  : '0; 

  assign m1_axis_tdata  = (m1_en) ? s_axis_tdata  : '0; 
  assign m1_axis_tvalid = (m1_en) ? s_axis_tvalid : '0; 
  assign m1_axis_tuser  = (m1_en) ? s_axis_tuser  : '0; 
  assign m1_axis_tlast  = (m1_en) ? s_axis_tlast  : '0; 
  assign m1_axis_tstrb  = (m1_en) ? s_axis_tstrb  : '0; 
  assign m1_axis_tkeep  = (m1_en) ? s_axis_tkeep  : '0; 
  assign m1_axis_tid    = (m1_en) ? s_axis_tid    : '0; 
  assign m1_axis_tdest  = (m1_en) ? s_axis_tdest  : '0; 

  assign s_axis_tready  = (m1_en) ? m1_axis_tready  : m0_axis_tready;

///////////////////////////////////////////////////////////////////////////////////////////////////
  logic tready,tvalid ;
  logic [3:0] data;

  assign tready = (m1_en) ? m1_axis_tready  : m0_axis_tready;
  assign tvalid = (!m1_en) ? s_axis_tvalid : '0; 
  assign data = (!m1_en) ? s_axis_tdata[3:0]  : '0; 

ila1 your_instance_name (
	.clk(aclk), // input wire clk
	.probe0(data), // input wire [3:0]  probe0  
	.probe1(tvalid), // input wire [0:0]  probe1 
	.probe2(tready) // input wire [0:0]  probe2
);


endmodule