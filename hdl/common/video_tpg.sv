
module video_tpg #(
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

  localparam [10:0]   SCRN_WIDTH = 1920;//1280; //1920
  localparam [9:0]    SCRN_HEIGHT = 1080;//720;  //1080

  localparam [23:0]   GRN = 24'h0000FF;
  localparam [23:0]   RED = 24'h00FF00;
  localparam [23:0]   BLU = 24'hFF0000;

  localparam [23:0]   SCRN_TOP = GRN;
  localparam [23:0]   SCRN_BOT = RED;


  

  logic [DATAW-1:0]   tdata;
  logic               tvalid,tuser,tlast;
  logic [10:0]        cntX_Horz;
  logic [9:0]         cntY_Vert;

  typedef enum {
    TOP,BOT
  } vid_sm_type;

  vid_sm_type VID_SM;

///////////////////////////////////////////////////////////////////////////////////////////////////
//1280x720
  // tdata 

  always_ff @(posedge clk) begin 
    if (rst) begin 
      cntX_Horz <= '0;
      tvalid    <= '0;
    end else if (en == '0) begin 
      tvalid    <= '0;
      cntX_Horz <= '0;
    end else if (m_axis_tready) begin 
      tvalid    <= '1;
      if (cntX_Horz == (SCRN_WIDTH - 1))  cntX_Horz <= '0;
      else                                cntX_Horz <= cntX_Horz + 1;
    end 
  end 

  always_ff @(posedge clk) begin 
    if (rst) begin 
      cntY_Vert <= '0;
    end else if (en == '0) begin
      cntY_Vert <= '0;
    end else if (m_axis_tready && (cntX_Horz == (SCRN_WIDTH - 1))) begin 
      if (cntY_Vert == (SCRN_HEIGHT - 1)) cntY_Vert <= '0;
      else                                cntY_Vert <= cntY_Vert + 1;
    end 
  end 

  //assign tdata = (cntY_Vert > (SCRN_HEIGHT/2)) ? SCRN_BOT:SCRN_TOP; // works for top/bot
  assign tdata = (cntY_Vert < (SCRN_HEIGHT/2)) ? SCRN_TOP:
                 (cntX_Horz < (SCRN_WIDTH/2)) ? SCRN_BOT:BLU;// left:rigth
  
  assign tuser = ((cntX_Horz == '0) && (cntY_Vert == '0)) ? '1:'0;
  assign tlast = (cntX_Horz == (SCRN_WIDTH - 1)) ? '1:'0;



  assign m_axis_tdata   = tdata;
  assign m_axis_tvalid  = tvalid;
  assign m_axis_tuser   = tuser;
  assign m_axis_tlast   = tlast;
  assign m_axis_tstrb   = '0;
  assign m_axis_tkeep   = '1;
  assign m_axis_tid     = '0;
  assign m_axis_tdest   = '0;



/*
  always_ff @(posedge clk) begin 
    case (VID_SM) 
      TOP: 

      BOT: 

    endcase 
  end 
*/



endmodule