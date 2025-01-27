
module axis_switch_simple #
(
  parameter integer DATAW	= 24
)
(
  input                   s0_en           ,
  input                   s1_en           ,
  input                   s2_en           ,

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

  input [DATAW-1:0]       s2_axis_tdata   ,
  input                   s2_axis_tvalid  ,
  output                  s2_axis_tready  ,
  input                   s2_axis_tuser   ,
  input                   s2_axis_tlast   ,
  input [(DATAW/8)-1:0]   s2_axis_tstrb   ,
  input [(DATAW/8)-1:0]   s2_axis_tkeep   ,
  input                   s2_axis_tid     ,
  input                   s2_axis_tdest   ,

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

  assign m_axis_tdata   = (s0_en) ? s0_axis_tdata  : (s1_en) ? s1_axis_tdata  : (s2_en) ? s2_axis_tdata  : '0; 
  assign m_axis_tvalid  = (s0_en) ? s0_axis_tvalid : (s1_en) ? s1_axis_tvalid : (s2_en) ? s2_axis_tvalid : '0; 
  assign m_axis_tuser   = (s0_en) ? s0_axis_tuser  : (s1_en) ? s1_axis_tuser  : (s2_en) ? s2_axis_tuser  : '0; 
  assign m_axis_tlast   = (s0_en) ? s0_axis_tlast  : (s1_en) ? s1_axis_tlast  : (s2_en) ? s2_axis_tlast  : '0; 
  assign m_axis_tstrb   = (s0_en) ? s0_axis_tstrb  : (s1_en) ? s1_axis_tstrb  : (s2_en) ? s2_axis_tstrb  : '0; 
  assign m_axis_tkeep   = (s0_en) ? s0_axis_tkeep  : (s1_en) ? s1_axis_tkeep  : (s2_en) ? s2_axis_tkeep  : '0; 
  assign m_axis_tid     = (s0_en) ? s0_axis_tid    : (s1_en) ? s1_axis_tid    : (s2_en) ? s2_axis_tid    : '0; 
  assign m_axis_tdest   = (s0_en) ? s0_axis_tdest  : (s1_en) ? s1_axis_tdest  : (s2_en) ? s2_axis_tdest  : '0; 

  assign s0_axis_tready = m_axis_tready ;
  assign s1_axis_tready = m_axis_tready ;
  assign s2_axis_tready = m_axis_tready ;


endmodule