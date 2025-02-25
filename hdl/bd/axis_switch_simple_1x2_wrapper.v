
module axis_switch_simple_1x2_wrapper #
(
  parameter integer DATAW	= 24
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

  axis_switch_simple_1x2 # (
    .DATAW      (DATAW  )
  ) axis_switch_simple_1x2_inst (
    .aclk             (aclk            ),
    .m0_en            (m0_en           ), 
    .m1_en            (m1_en           ), 
    .s_axis_tdata     (s_axis_tdata    ), 
    .s_axis_tvalid    (s_axis_tvalid   ), 
    .s_axis_tready    (s_axis_tready   ), 
    .s_axis_tuser     (s_axis_tuser    ), 
    .s_axis_tlast     (s_axis_tlast    ), 
    .s_axis_tstrb     (s_axis_tstrb    ), 
    .s_axis_tkeep     (s_axis_tkeep    ), 
    .s_axis_tid       (s_axis_tid      ), 
    .s_axis_tdest     (s_axis_tdest    ), 
    .m0_axis_tdata    (m0_axis_tdata   ), 
    .m0_axis_tvalid   (m0_axis_tvalid  ), 
    .m0_axis_tready   (m0_axis_tready  ), 
    .m0_axis_tuser    (m0_axis_tuser   ), 
    .m0_axis_tlast    (m0_axis_tlast   ), 
    .m0_axis_tstrb    (m0_axis_tstrb   ), 
    .m0_axis_tkeep    (m0_axis_tkeep   ), 
    .m0_axis_tid      (m0_axis_tid     ), 
    .m0_axis_tdest    (m0_axis_tdest   ), 
    .m1_axis_tdata    (m1_axis_tdata   ), 
    .m1_axis_tvalid   (m1_axis_tvalid  ), 
    .m1_axis_tready   (m1_axis_tready  ), 
    .m1_axis_tuser    (m1_axis_tuser   ), 
    .m1_axis_tlast    (m1_axis_tlast   ), 
    .m1_axis_tstrb    (m1_axis_tstrb   ), 
    .m1_axis_tkeep    (m1_axis_tkeep   ), 
    .m1_axis_tid      (m1_axis_tid     ), 
    .m1_axis_tdest    (m1_axis_tdest   )
);


endmodule

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
