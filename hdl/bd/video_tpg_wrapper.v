
module video_tpg_wrapper #(
  parameter integer DATAW = 32
) (
  input                   rst           ,
  input                   clk           ,
  input                   en            ,
  output [DATAW-1:0]      m_axis_tdata  ,
  output                  m_axis_tvalid ,
  input                   m_axis_tready ,
  output                  m_axis_tuser  ,
  output                  m_axis_tlast  ,
  output [(DATAW/8)-1:0]  m_axis_tstrb  ,
  output [(DATAW/8)-1:0]  m_axis_tkeep  ,
  output                  m_axis_tid    ,
  output                  m_axis_tdest  
);
///////////////////////////////////////////////////////////////////////////////////////////////////
  
  video_tpg # (
    .DATAW      (DATAW)
  ) video_tpg (
    .rst            (rst           ),
    .clk            (clk           ),
    .en             (en            ),
    .m_axis_tdata   (m_axis_tdata  ),
    .m_axis_tvalid  (m_axis_tvalid ),
    .m_axis_tready  (m_axis_tready ),
    .m_axis_tuser   (m_axis_tuser  ),
    .m_axis_tlast   (m_axis_tlast  ),
    .m_axis_tstrb   (m_axis_tstrb  ),
    .m_axis_tkeep   (m_axis_tkeep  ),
    .m_axis_tid     (m_axis_tid    ),
    .m_axis_tdest   (m_axis_tdest  )
);




endmodule