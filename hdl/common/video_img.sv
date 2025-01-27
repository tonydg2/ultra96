
module video_img #(
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
  localparam [12:0]   VertMAX = 725;

  localparam [23:0]   SCRN_TOP = GRN;
  localparam [23:0]   SCRN_BOT = RED;

  logic [DATAW-1:0]   tdata;
  logic               tvalid,tuser,tlast;
  logic [12:0]        cntX_Horz;
  logic [12:0]        cntY_Vert;

  typedef enum {
    TOP,BOT
  } vid_sm_type;

  vid_sm_type VID_SM;

///////////////////////////////////////////////////////////////////////////////////////////////////
  localparam [16:0] BramAddrMAX = 111000;
  logic [16:0] addr = 0;
  logic [23:0] img_buff [7:0];
  logic [2:0] buff_cntr = 0;
  logic bram_en;
/*
  always_ff @(posedge clk) begin 
    if (rst || tuser) begin 
      addr      <= 0;
      buff_cntr <= 0;
      bram_en   <= 0;
    end else if (buff_cntr < 7) begin 
      bram_en   <= 1;
      addr      <= addr + 1;
      img_buff  <= {img_buff[6:0], bram_data_i};
      buff_cntr <= buff_cntr + 1;
    end else if (((cntY_Vert > VertMIN) && (cntY_Vert < VertMAX)) || ((cntX_Horz > HorzMIN) && (cntX_Horz < HorzMAX)) && m_axis_tready) begin
      bram_en   <= 1;
      addr      <= addr + 1;
      img_buff  <= {img_buff[6:0], bram_data_i};
      buff_cntr <= 6;
    end else bram_en <= 0;
  end

  assign bram_en_o = bram_en;
  assign bram_addr_o = addr;
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
// Starting at 810 horiz, 356 vert -> size 300x370 use BRAM
// else data is 0x010101

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
  
  /*assign tdata = (cntY_Vert < (SCRN_HEIGHT/2)) ? SCRN_TOP:
                 (cntX_Horz < (SCRN_WIDTH/2)) ? SCRN_BOT:BLU;// left:rigth
                 */
/*  assign tdata =  (cntY_Vert < VertMIN) ? BLK:
                  (cntY_Vert > VertMAX) ? BLK:
                  (cntX_Horz < HorzMIN) ? BLK:
                  (cntX_Horz > HorzMAX) ? BLK: fifoDOUT;
*/
  assign tdata = (vdata_rom_active) ? fifoDOUT:BLK;

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
  typedef enum {
    ADDR0,READ_ROM,WAIT_FIFO_EMPTY
  } FIFO_WR_SM_type;

  FIFO_WR_SM_type FIFO_WR_SM;

  logic [16:0] bram_counter=0;
  logic [23:0] fifoDIN, fifoDOUT;
  logic fifo_full, fifoWR,fifoWR_dly, fifoRD,fifo_empty_done, fifo_empty;

  fifo_gen_dram_sync fifo_gen_dram_sync_inst (
    .clk          (clk          ),                // input wire clk
    .srst         (rst          ),                  // input wire srst
    .din          (bram_data_i  ),                       // input wire [23 : 0] din
    .wr_en        (fifoWR_dly   ),             // input wire wr_en
    .rd_en        (fifoRD       ),              // input wire rd_en
    .dout         (fifoDOUT     ),                  // output wire [23 : 0] dout
    .full         (             ),          // output wire full
    .almost_full  (fifo_full    ),               // output wire almost_full
    .empty        (fifo_empty   ),                  // output wire empty
    .wr_rst_busy  (             ),      // output wire wr_rst_busy
    .rd_rst_busy  (             )   // output wire rd_rst_busy
  );

  always_ff @(posedge clk) begin : FIFO_WR_block
    if (rst) begin 
      fifoWR  <= 0;
      FIFO_WR_SM <= ADDR0;
    end else begin 
      fifoWR_dly <= fifoWR;
      case (FIFO_WR_SM) 
        // initially bram data not used, fill up FIFO
        ADDR0: begin
          fifoWR      <= 1;
          //fifoDIN     <= bram_data_i;
          FIFO_WR_SM     <= READ_ROM;
        end 
        // fifo will fill here, then wait and be read incrementally for video data
        READ_ROM: begin 
          // end of frame
          if ((bram_counter == (111000-1)) ||(tuser == 1)) begin 
            fifoWR      <= 0;
            FIFO_WR_SM     <= WAIT_FIFO_EMPTY;
          end else if (fifo_full) begin 
            fifoWR      <= 0;
          end else begin 
            fifoWR      <= 1;
            //fifoDIN     <= bram_data_i;
          end 
        end
        WAIT_FIFO_EMPTY: begin 
          if (fifo_empty_done) FIFO_WR_SM <= ADDR0;
        end
      endcase 
    end 
  end 


  typedef enum {
    READ_FIFO,DUMP_FIFO
  } FIFO_RD_SM_type;

  FIFO_RD_SM_type FIFO_RD_SM;

  logic [3:0] fifoCnt;
  logic vdata_rom_active;
  assign vdata_rom_active = ((((cntY_Vert > VertMIN) && (cntY_Vert < VertMAX)) && 
                              ((cntX_Horz > HorzMIN) && (cntX_Horz < HorzMAX))) && m_axis_tready) ? 1:0;


  always_ff @(posedge clk) begin  : FIFO_RD_block
    if (rst) begin 
      fifoRD  <= 0;
      fifoCnt     <= 0;
      fifo_empty_done <= 0;
      FIFO_RD_SM <= READ_FIFO;
    end else begin 
      case (FIFO_RD_SM) 
        READ_FIFO: begin
          fifo_empty_done <= 0;
          if ((bram_counter == (111000-1)) ||(tuser == 1)) begin
            FIFO_RD_SM  <= DUMP_FIFO;
            fifoCnt     <= 0;
            fifoRD      <= 1;
          end else if (tvalid && vdata_rom_active) begin 
            fifoRD  <= 1;
          end else 
            fifoRD  <= 0;
          end 
        DUMP_FIFO: begin 
          if (fifo_empty) begin 
            fifo_empty_done <= 1;
            fifoRD  <= 0;
            FIFO_RD_SM  <= READ_FIFO;
          end else begin 
            fifoRD  <= 1;
            //fifoCnt <= fifoCnt + 1;
          end 
        end 
      endcase 
    end 
  end 

  logic rom_en;
  assign rom_en = fifoWR;

  always_ff @(posedge clk) begin  : BRAM_CTRL_block
    if ((bram_counter == (111000-1)) ||(tuser == 1)) bram_counter <= 0;
    else if (rom_en) bram_counter <= bram_counter + 1;
  end

assign bram_addr_o = bram_counter;
assign bram_en_o = rom_en;

//    else if (!fifo_full) begin 
//      bram_en_o   <= '1;
//      bram_addr_o




//bram_en_o
//bram_addr_o
//bram_data_i
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