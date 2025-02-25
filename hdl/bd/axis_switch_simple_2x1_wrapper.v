
module axis_switch_simple_2x1_wrapper #
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

  axis_switch_simple_2x1 # (
    .DATAW      (DATAW  )
  ) axis_switch_simple_2x1_inst (
    .aclk           (aclk           ),
    .s0_en          (s0_en          ),
    .s1_en          (s1_en          ),
    .s0_axis_tdata  (s0_axis_tdata  ),
    .s0_axis_tvalid (s0_axis_tvalid ),
    .s0_axis_tready (s0_axis_tready ),
    .s0_axis_tuser  (s0_axis_tuser  ),
    .s0_axis_tlast  (s0_axis_tlast  ),
    .s0_axis_tstrb  (s0_axis_tstrb  ),
    .s0_axis_tkeep  (s0_axis_tkeep  ),
    .s0_axis_tid    (s0_axis_tid    ),
    .s0_axis_tdest  (s0_axis_tdest  ),
    .s1_axis_tdata  (s1_axis_tdata  ),
    .s1_axis_tvalid (s1_axis_tvalid ),
    .s1_axis_tready (s1_axis_tready ),
    .s1_axis_tuser  (s1_axis_tuser  ),
    .s1_axis_tlast  (s1_axis_tlast  ),
    .s1_axis_tstrb  (s1_axis_tstrb  ),
    .s1_axis_tkeep  (s1_axis_tkeep  ),
    .s1_axis_tid    (s1_axis_tid    ),
    .s1_axis_tdest  (s1_axis_tdest  ),
    .m_axis_tdata   (m_axis_tdata   ),
    .m_axis_tvalid  (m_axis_tvalid  ),
    .m_axis_tready  (m_axis_tready  ),
    .m_axis_tuser   (m_axis_tuser   ),
    .m_axis_tlast   (m_axis_tlast   ),
    .m_axis_tstrb   (m_axis_tstrb   ),
    .m_axis_tkeep   (m_axis_tkeep   ),
    .m_axis_tid     (m_axis_tid     ),
    .m_axis_tdest   (m_axis_tdest   ) 
);


endmodule