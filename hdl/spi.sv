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

module spi (
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
  logic [2:0] bit_idx='h7;

  assign csn = csn_i;
  assign din = mosi_i;
  //assign miso_o = dout;
  assign miso_o = dout_ne;

  //assign data_snd   = td0;
  //assign data_snd2  = td1;

  typedef enum {
    IDLE,GET_OPCODE,GET_ADDR,GET_DATA,SEND_DATA,WAIT
  } spi_sm_type;

  spi_sm_type SPI_SM;

///////////////////////////////////////////////////////////////////////////////////////////////////
  
  always_ff @(negedge sclk_i) begin 
    dout_ne <= dout;
  end


  always_ff @(posedge sclk_i) begin 
    if (csn) SPI_SM <= IDLE; // if clock is running but this CS is not active, make sure in IDLE
    else begin
      case (SPI_SM) 
        IDLE: begin //0
          data_snd    <= td0;
          data_snd2   <= td1;
          opcode[6:0] <= '0; //clear
          addr        <= '0; //clear
          opcode_done <= '0; //clear
          addr_done   <= '0; //clear
          data_rcv_done <= '0;
          data_rcv    <= '0;
          bit_idx     <= 'h7;
          if (~csn) begin 
            opcode[7] <= din; // 1st bit
            bit_idx   <= bit_idx - 1;
            SPI_SM    <= GET_OPCODE; 
          end
        end
        GET_OPCODE: begin //1
          if (bit_idx == 0) begin
            opcode[0]   <= din;  //last bit
            bit_idx     <= 7;
            opcode_done <= '1;
            SPI_SM      <= GET_ADDR; 
          end else begin
            opcode[bit_idx] <= din;
            bit_idx         <= bit_idx - 1;
          end 
        end
        GET_ADDR: begin //2
          if (bit_idx == '0) begin
            addr[0]   <= din;  //last bit
            addr_done <= '1;
            if (opcode[0] == 1'b0) begin 
              bit_idx     <= 'h7;
              //data_rcv[7] <= din;
              SPI_SM      <= GET_DATA;  // write command from SRC, this module will receive data
            end else begin
              bit_idx   <= 'h6;
              dout      <= data_snd[7];
              SPI_SM    <= SEND_DATA; // read command from SRC, this module will send data to SRC
            end
          end else begin
            addr[bit_idx] <= din; 
            bit_idx       <= bit_idx - 1;
          end 
        end
        GET_DATA: begin //3
          if (bit_idx == 0) begin
            data_rcv[0] <= din;  //last bit
            bit_idx     <= 'h7;
            SPI_SM      <= IDLE;
            opcode      <= '0; //clear
            addr        <= '0; //clear
            opcode_done <= '0; //clear
            addr_done   <= '0; //clear
            data_rcv_done <= '1;
          end else begin
            data_rcv[bit_idx] <= din; 
            bit_idx           <= bit_idx - 1;
          end 
        end 
        SEND_DATA: begin //4
          if (bit_idx == '0) begin
            dout        <= data_snd[0];  //last bit
            bit_idx     <= 'h7;
            //SPI_SM      <= SEND_DATA2;
            SPI_SM <= WAIT;
            opcode      <= '0; //clear
            addr        <= '0; //clear
            opcode_done <= '0; //clear
            addr_done   <= '0; //clear
          end else begin
            dout    <= data_snd[bit_idx];
            bit_idx <= bit_idx - 1;
          end 
        end 
        WAIT: begin 
          dout <= '0;         
          SPI_SM <= IDLE; //6
        end
      endcase
    end
  end

/*
///////////////////////////////////////////////////////////////////////////////////////////////////
// hw debug only, disable for simulation(questa)
//`ifndef SIMULATION // requires passing in param at compile time (vlog spi.sv +define+SIMULATION)
`ifndef QUESTA
`ifndef MODELSIM

  logic [2:0] sm,idx;

  assign sm = (SPI_SM == IDLE         ) ? 'h0 :
              (SPI_SM == GET_OPCODE   ) ? 'h1 :
              (SPI_SM == GET_ADDR     ) ? 'h2 :
              (SPI_SM == GET_DATA     ) ? 'h3 :
              (SPI_SM == SEND_DATA    ) ? 'h4 :
              (SPI_SM == WAIT         ) ? 'h6 : 'h7;

  assign idx = bit_idx;

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


