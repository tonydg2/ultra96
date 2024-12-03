// SPI SINK, responder to SPI SOURCE
// emulate SPI responses for MCP23S17 device, one byte data send/rcv only in addition to opcode/addr
// 
// byte0 = OPCODE + R/W  (Write = 0, Read = 1)
// byte1 = reg addr
// byte1+= data (only 1byte read or write)
//
// this version is coded 'easy', no "D" and "Q" style coding, single clocked process SM
//  to compare synthesis results to other version

`timescale 1ns / 1ps  // <time_unit>/<time_precision>

module spi2 (
    input   rst,
    input   [7:0] td0,
    input   [7:0] td1,
    input   ila_clk, // for debug only
    input   sclk_i,
    input   csn_i,
    input   mosi_i,
    output  miso_o
);
///////////////////////////////////////////////////////////////////////////////////////////////////
//  localparam [7:0] TESTDAT0 = 8'hF0;
//  localparam [7:0] TESTDAT1 = 8'h0F;

  //logic [2:0] bit_idx;
  logic [7:0] opcode='0,addr='0,data_rcv='0,data_snd,data_snd2;
  logic dout='0,dout_ne='0, opcode_done='0, addr_done='0, data_rcv_done='0;
  integer bit_idx=7;

  assign csn = csn_i;
  assign din = mosi_i;
  //assign miso_o = dout;
  assign miso_o = dout_ne;

  //assign data_snd   = td0;
  //assign data_snd2  = td1;

  typedef enum {
    IDLE,GET_OPCODE,GET_ADDR,GET_DATA,SEND_DATA,WAIT
  } spi_sm_type;

  spi_sm_type SPI_STATE, SPI_STATE_NEXT;

///////////////////////////////////////////////////////////////////////////////////////////////////
  
  always_ff @(negedge sclk_i) begin 
    //dout_ne <= dout;
    if (SPI_STATE == SEND_DATA)   dout_ne  <= td0[bit_idx]; 
    //else if (SPI_STATE == WAIT)   dout_ne  <= '0; 
    else dout_ne  <= '0;
  end

  always_ff @(posedge sclk_i) begin
    if (rst)  SPI_STATE <= IDLE;
    else      SPI_STATE <= SPI_STATE_NEXT;
  end 

  always_ff @(posedge sclk_i) begin
    if (rst)  bit_idx <= 7;
    else begin 
      if (bit_idx == 0) bit_idx <= 7;
      else              bit_idx <= bit_idx - 1;
    end 
  end 

  always_ff @(posedge sclk_i) begin
    if (rst) begin 
      opcode[6:0]   <= '0; //clear
      addr          <= '0; //clear
      opcode_done   <= '0; //clear
      addr_done     <= '0; //clear
      data_rcv_done <= '0;
      data_rcv      <= '0;
    end else begin 
      if (SPI_STATE == IDLE) begin
        opcode_done   <= '0;
        addr_done     <= '0;
        data_rcv_done <= '0;
      end else if (SPI_STATE == GET_OPCODE) begin 
        opcode[bit_idx] <= din;
        if (bit_idx == 0) opcode_done <= '1;
        else              opcode_done <= '0;
      end else if (SPI_STATE == GET_ADDR) begin 
        opcode_done   <= '0;
        addr[bit_idx] <= din; 
        if (bit_idx == 0) addr_done <= '1;
        else              addr_done <= '0;
      end else if (SPI_STATE == GET_DATA) begin 
        addr_done         <= '0;
        data_rcv[bit_idx] <= din; 
        if (bit_idx == 0) data_rcv_done <= '1;
        else              data_rcv_done <= '0;
      //end else if (SPI_STATE == SEND_DATA) begin 
      //end else if (SPI_STATE == WAIT) begin 
      end 
    end 
  end 

  always_comb begin 
    case (SPI_STATE) 
      IDLE: begin //0
          SPI_STATE_NEXT  = GET_OPCODE; 
      end
      GET_OPCODE: begin //1
        if (bit_idx == 0) begin
          SPI_STATE_NEXT  = GET_ADDR; 
        end else SPI_STATE_NEXT = SPI_STATE;
      end
      GET_ADDR: begin //2
        if ((bit_idx == 0)) begin
          if (opcode[0] == 1'b0) begin 
            SPI_STATE_NEXT  = GET_DATA;  
          end else begin
            SPI_STATE_NEXT  = SEND_DATA;
          end
        end else SPI_STATE_NEXT = SPI_STATE;
      end
      GET_DATA: begin //3
        if (bit_idx == 0) begin
          SPI_STATE_NEXT  = IDLE;
        end else SPI_STATE_NEXT = SPI_STATE;
      end 
      SEND_DATA: begin //4
        if (bit_idx == 0) begin
          SPI_STATE_NEXT  = IDLE;//WAIT;
        end else SPI_STATE_NEXT = SPI_STATE;
      end 
      WAIT: begin 
        SPI_STATE_NEXT = IDLE; //6
      end
    endcase
  end



/*
///////////////////////////////////////////////////////////////////////////////////////////////////
// hw debug only, disable for simulation(questa)
//`ifndef SIMULATION // requires passing in param at compile time (vlog spi.sv +define+SIMULATION)

  logic [2:0] sm,idx;

  assign sm = (SPI_STATE == IDLE         ) ? 'h0 :
              (SPI_STATE == GET_OPCODE   ) ? 'h1 :
              (SPI_STATE == GET_ADDR     ) ? 'h2 :
              (SPI_STATE == GET_DATA     ) ? 'h3 :
              (SPI_STATE == SEND_DATA    ) ? 'h4 :
              (SPI_STATE == WAIT         ) ? 'h6 : 'h7;

  assign idx = bit_idx;

`ifndef QUESTA
`ifndef MODELSIM

  ila2 ila2 (
  	.clk(ila_clk),   // input wire clk
  	.probe0(sm),
  	.probe1(csn),
  	.probe2(din),
  	.probe3(dout_ne),
  	.probe4(idx),
  	.probe5(data_snd),
  	.probe6(opcode),
  	.probe7(addr),
  	.probe8(data_rcv),
  	.probe9(opcode_done),
  	.probe10(addr_done),
    .probe11(sclk_i),
    .probe12(data_rcv_done),
    .probe13(data_rcv)
  );

`endif
`endif  //*/


endmodule


