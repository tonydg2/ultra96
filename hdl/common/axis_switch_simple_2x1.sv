
module axis_switch_simple_2x1 #
(
  parameter integer DATAW	= 24
)
(
  input                   aclk            ,
  input                   s0_en           ,
  input                   s1_en           ,

  input [DATAW-1:0]       s0_axis_tdata   ,
  input                   s0_axis_tvalid  ,
  output                  s0_axis_tready  ,
  input                   s0_axis_tuser   ,
  input                   s0_axis_tlast   ,
  input [(DATAW/8)-1:0]   s0_axis_tstrb   ,
  input [(DATAW/8)-1:0]   s0_axis_tkeep   ,
  input                   s0_axis_tid     ,
  input                   s0_axis_tdest   ,

  input [DATAW-1:0]       s1_axis_tdata   ,
  input                   s1_axis_tvalid  ,
  output                  s1_axis_tready  ,
  input                   s1_axis_tuser   ,
  input                   s1_axis_tlast   ,
  input [(DATAW/8)-1:0]   s1_axis_tstrb   ,
  input [(DATAW/8)-1:0]   s1_axis_tkeep   ,
  input                   s1_axis_tid     ,
  input                   s1_axis_tdest   ,

  output [DATAW-1:0]      m_axis_tdata    ,
  output                  m_axis_tvalid   ,
  input                   m_axis_tready   ,
  output                  m_axis_tuser    ,
  output                  m_axis_tlast    ,
  output [(DATAW/8)-1:0]  m_axis_tstrb    ,
  output [(DATAW/8)-1:0]  m_axis_tkeep    ,
  output                  m_axis_tid      ,
  output                  m_axis_tdest
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  //assign m_axis_tdata   = (s0_en) ? s0_axis_tdata  : (s1_en) ? s1_axis_tdata  : '0; 
  //assign m_axis_tvalid  = (s0_en) ? s0_axis_tvalid : (s1_en) ? s1_axis_tvalid : '0; 
  //assign m_axis_tuser   = (s0_en) ? s0_axis_tuser  : (s1_en) ? s1_axis_tuser  : '0; 
  //assign m_axis_tlast   = (s0_en) ? s0_axis_tlast  : (s1_en) ? s1_axis_tlast  : '0; 
  //assign m_axis_tstrb   = (s0_en) ? s0_axis_tstrb  : (s1_en) ? s1_axis_tstrb  : '0; 
  //assign m_axis_tkeep   = (s0_en) ? s0_axis_tkeep  : (s1_en) ? s1_axis_tkeep  : '0; 
  //assign m_axis_tid     = (s0_en) ? s0_axis_tid    : (s1_en) ? s1_axis_tid    : '0; 
  //assign m_axis_tdest   = (s0_en) ? s0_axis_tdest  : (s1_en) ? s1_axis_tdest  : '0; 

  assign m_axis_tdata   = (s1_en) ? s1_axis_tdata  : s0_axis_tdata  ; 
  assign m_axis_tvalid  = (s1_en) ? s1_axis_tvalid : s0_axis_tvalid ; 
  assign m_axis_tuser   = (s1_en) ? s1_axis_tuser  : s0_axis_tuser  ; 
  assign m_axis_tlast   = (s1_en) ? s1_axis_tlast  : s0_axis_tlast  ; 
  assign m_axis_tstrb   = (s1_en) ? s1_axis_tstrb  : s0_axis_tstrb  ; 
  assign m_axis_tkeep   = (s1_en) ? s1_axis_tkeep  : s0_axis_tkeep  ; 
  assign m_axis_tid     = (s1_en) ? s1_axis_tid    : s0_axis_tid    ; 
  assign m_axis_tdest   = (s1_en) ? s1_axis_tdest  : s0_axis_tdest  ; 


  assign s0_axis_tready = (!s1_en) ? m_axis_tready : '0;
  assign s1_axis_tready = (s1_en)  ? m_axis_tready : '0;

///////////////////////////////////////////////////////////////////////////////////////////////////
  logic tready,tvalid ;
  logic [3:0] data;

  assign tready = (!s1_en) ? m_axis_tready : '0;
  assign tvalid = (s1_en) ? s1_axis_tvalid : s0_axis_tvalid ; 
  assign data   = (s1_en) ? s1_axis_tdata  : s0_axis_tdata  ; 

ila1 your_instance_name (
	.clk(aclk), // input wire clk
	.probe0(data), // input wire [3:0]  probe0  
	.probe1(tvalid), // input wire [0:0]  probe1 
	.probe2(tready) // input wire [0:0]  probe2
);


endmodule