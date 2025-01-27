
module video_img2 #(
  parameter integer DATAW = 24,
  parameter integer SCRW  = 1920,
  parameter integer SCRH  = 1080
) (
  input                   rst           ,
  input                   clk           ,
  input                   en            ,
  input  [12:0]           subh          ,
  input  [12:0]           addh          ,
  input  [12:0]           subw          ,
  input  [12:0]           addw          ,
  output [DATAW-1:0]      m_axis_tdata  ,
  output                  m_axis_tvalid ,
  input                   m_axis_tready ,
  output                  m_axis_tuser  ,
  output                  m_axis_tlast  ,
  output [(DATAW/8)-1:0]  m_axis_tstrb  ,
  output [(DATAW/8)-1:0]  m_axis_tkeep  ,
  output                  m_axis_tid    ,
  output                  m_axis_tdest  ,
  output                  bram_en_o     ,
  output [16 : 0]         bram_addr_o   ,
  input  [23 : 0]         bram_data_i
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  logic [12:0]   SCRN_WIDTH ;// = SCRW + addw - subw; //1280; //1920
  logic [12:0]   SCRN_HEIGHT;// = SCRH + addh - subh; //720;  //1080

  assign SCRN_WIDTH  = SCRW + addw - subw;
  assign SCRN_HEIGHT = SCRH + addh - subh;

  localparam [23:0]   GRN = 24'h0000FF;
  localparam [23:0]   RED = 24'h00FF00;
  localparam [23:0]   BLU = 24'hFF0000;
  localparam [23:0]   BLK = 24'h010101;

  localparam [12:0]   HorzMIN = 810;
  localparam [12:0]   HorzMAX = 1110;
  localparam [12:0]   VertMIN = 356;
  localparam [12:0]   VertMAX = 726;

  localparam [23:0]   SCRN_TOP = GRN;
  localparam [23:0]   SCRN_BOT = RED;

  logic [DATAW-1:0]   tdata;
  logic               tvalid,tuser,tlast;
  logic [12:0]        cntX_Horz;
  logic [12:0]        cntY_Vert;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Starting at 810 horiz, 356 vert -> size 300x370 use BRAM
// else data is 0x010101
// 111000 pixels

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


  assign tdata = (vdata_rom_active) ? rom_data:BLK;
  assign tuser = ((cntX_Horz == '0) && (cntY_Vert == '0)) ? '1:'0;  // SOF
  assign tlast = (cntX_Horz == (SCRN_WIDTH - 1)) ? '1:'0;           // EOL horiz width

  assign m_axis_tdata   = tdata;
  assign m_axis_tvalid  = tvalid;
  assign m_axis_tuser   = tuser;
  assign m_axis_tlast   = tlast;
  assign m_axis_tstrb   = '0;
  assign m_axis_tkeep   = '1;
  assign m_axis_tid     = '0;
  assign m_axis_tdest   = '0;


///////////////////////////////////////////////////////////////////////////////////////////////////
  //bram_en_o
  //bram_addr_o [16 : 0]  
  //bram_data_i [23 : 0]

  logic          rom_rd_en  ;  
  logic [16 : 0] rom_addr   ;
  logic [23 : 0] rom_data   ;

  logic vdata_rom_active;
  assign vdata_rom_active = ((((cntY_Vert >= VertMIN) && (cntY_Vert < VertMAX)) && 
                              ((cntX_Horz >= HorzMIN) && (cntX_Horz < HorzMAX)))) ? 1:0;

  always_ff @(posedge clk) begin 
    if ((tuser == 1) || (rst == 1)) begin 
      rom_addr <= 0;
    end else if (rom_addr ==(111000-1)) begin 
      rom_addr <= 0;
    end else if ((rom_rd_en == 1)) begin
      rom_addr <= rom_addr + 1;
    end 
  end

  assign rom_rd_en = ((rom_addr == 0) || (vdata_rom_active && m_axis_tready)) ? 1:0;
  assign rom_data = bram_data_i;
  assign bram_addr_o = rom_addr;
  assign bram_en_o = rom_rd_en;

///////////////////////////////////////////////////////////////////////////////////////////////////

/*
`ifndef QUESTA
`ifndef MODELSIM

(* dont_touch = "true" *) wire [12:0] screen_height;
(* dont_touch = "true" *) wire [12:0] screen_width;
assign screen_height = SCRN_HEIGHT;
assign screen_width = SCRN_WIDTH;

  ila1 ila1 (
  	.clk(clk),
  	.probe0(screen_height),
  	.probe1(en),
  	.probe2(screen_width)
  );

`endif
`endif
*/
endmodule