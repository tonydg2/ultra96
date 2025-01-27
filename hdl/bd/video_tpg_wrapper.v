
module video_tpg_wrapper #(
  parameter integer DATA_WIDTH    = 24,
  parameter integer SCREEN_WIDTH  = 1920,
  parameter integer SCREEN_HEIGHT = 1080
) (
  input                       rst           ,
  input                       clk           ,
  input                       en            ,
  input  [12:0]               subh          ,
  input  [12:0]               addh          ,
  input  [12:0]               subw          ,
  input  [12:0]               addw          ,
  output [DATA_WIDTH-1:0]     m_axis_tdata  ,
  output                      m_axis_tvalid ,
  input                       m_axis_tready ,
  output                      m_axis_tuser  ,
  output                      m_axis_tlast  ,
  output [(DATA_WIDTH/8)-1:0] m_axis_tstrb  ,
  output [(DATA_WIDTH/8)-1:0] m_axis_tkeep  ,
  output                      m_axis_tid    ,
  output                      m_axis_tdest  
);
///////////////////////////////////////////////////////////////////////////////////////////////////
  
  video_tpg # (
    .DATAW      (DATA_WIDTH     ),
    .SCRW       (SCREEN_WIDTH   ),
    .SCRH       (SCREEN_HEIGHT  )
  ) video_tpg (
    .rst            (rst           ),
    .clk            (clk           ),
    .subh           (subh          ),
    .addh           (addh          ),
    .subw           (subw          ),
    .addw           (addw          ),
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