module top_io (
    input         UART0_RX_I,
    output        UART0_TX_O,
    input         UART1_RX_I,
    output        UART1_TX_O,
    output [1:0]  RADIO_LED     // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////
  logic [31:0] debug28, debug29, debug30, debug31;
  logic [4:0] led_div1;

  logic rx0,tx0,rx1,tx1;
  logic clk_p78125, clk_12p8;

  logic MISO,mosi_i,sclk_i,cs0_i,MOSI,MISO_i,miso_o,SCLK,CS,CS1,CS2,mosi_t,cs0_t,miso_t,sclk_t;
  logic emio_spi1_mo_t_0,emio_spi1_s_o_0,emio_spi1_sclk_t_0,emio_spi1_so_t_0,emio_spi1_ss_n_t_0;
  logic emio_spi1_s_i_0,emio_spi1_sclk_i_0,emio_spi1_ss_i_n_0;
///////////////////////////////////////////////////////////////////////////////////////////////////

  assign rx0 = UART0_RX_I;
  assign rx1 = UART1_RX_I;
  assign UART0_TX_O = tx0;
  assign UART1_TX_O = tx1;

/*
  assign MISO_i = (debug28 == 'h1)? 1'b1 : //force high 0x70
                  (debug28 == 'h2)? 1'b0 : //force low
                  MISO;

  assign emio_spi1_s_i_0    = (debug29 == 'h1) ? 1'b1 : //0x74
                              1'b0;
  
  assign emio_spi1_sclk_i_0 = (debug30 == 'h1) ? 1'b1 : //0x78
                              (debug30 == 'h2) ? SCLK : 
                              1'b0;
  
  assign emio_spi1_ss_i_n_0 = (debug31 == 'h1) ? 1'b1 : //0x7C
                              1'b0;
*/

  top_bd_wrapper top_bd_wrapper_inst (
    .clk100     (clk100       ),
    .clk200     (clk200       ),
    .rstn       (rstn         ),
/*
    .emio_spi1_s_i_0      (emio_spi1_s_i_0),  // input 
    .emio_spi1_sclk_i_0   (emio_spi1_sclk_i_0),  // input 
    .emio_spi1_ss_i_n_0   (emio_spi1_ss_i_n_0),  // input 
    .emio_spi1_mo_t_0     (emio_spi1_mo_t_0  ),  // output
    .emio_spi1_s_o_0      (emio_spi1_s_o_0   ),  // output
    .emio_spi1_sclk_t_0   (emio_spi1_sclk_t_0),  // output
    .emio_spi1_so_t_0     (emio_spi1_so_t_0  ),  // output
    .emio_spi1_ss_n_t_0   (emio_spi1_ss_n_t_0),  // output
*/
    .MISO       (MISO         ),  // input    - 
    .MOSI       (MOSI         ),  // output   - 
    .SCLK       (SCLK         ),  // output   - 
    .CS0n       (CS           ),  // output   - 
    .CS1n       (CS1          ),  // output   - 
    .CS2n       (CS2          ),  // output   - 
    .UART_0_rxd (rx0          ), // IN
    .UART_0_txd (tx0          ), // OUT
    .UART_1_rxd (rx1          ), // IN
    .UART_1_txd (tx1          ), // OUT
    .debug28    (debug28),
    .debug29    (debug29),
    .debug30    (debug30),
    .debug31    (debug31),
    .led_div1_o (led_div1     ),
    .led_o      (RADIO_LED[0] )//Yellow
  );

  led_cnt led_cnt_inst (
    .rst      (~rstn        ),
    .clk100   (clk100       ),
    .div_i    (5'h9         ),//led_div1
    .wren_i   ('0           ),
    .led_o    (RADIO_LED[1] ) //BLUE
  );

//  ila1 ila1_inst (
//  	.clk(clk_12p8),   // input wire clk
//  	.probe0(MOSI),
//  	.probe1(miso_o),
//  	.probe2(SCLK),
//  	.probe3(CS   ),
//  	.probe4(CS1   ),
//  	.probe5(CS2   ),
//  	.probe6(mosi_t),
//  	.probe7(cs0_t ),
//  	.probe8(miso_t),
//  	.probe9(sclk_t)
//  );

  ila1 ila1 (
  	.clk(clk100),
  	.probe0(MOSI),
  	.probe1(debug29[7:0]),
  	.probe2(SCLK),
  	.probe3(CS),
  	.probe4(CS1),
  	.probe5(MISO),
  	.probe6(CS2),
  	.probe7(),
  	.probe8(),
  	.probe9(),
  	.probe10(),
  	.probe11(),
    .probe12(),
    .probe13(),
    .probe14()
  );

  spi spi_inst (
    .rst    (~rstn  ),
    .td0    (debug29[7:0]),
    .td1    (debug30[7:0]),
    .ila_clk(clk200 ),
    .sclk_i (SCLK   ),
    .csn_i  (CS     ),
    .mosi_i (MOSI   ),
    .miso_o (MISO   )
  );


  BUFGCE_DIV #(
    .BUFGCE_DIVIDE(8),              // 1-8
    // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
    .IS_CE_INVERTED(1'b0),          // Optional inversion for CE
    .IS_CLR_INVERTED(1'b0),         // Optional inversion for CLR
    .IS_I_INVERTED(1'b0),           // Optional inversion for I
    .SIM_DEVICE("ULTRASCALE_PLUS")  // ULTRASCALE, ULTRASCALE_PLUS
  ) BUFGCE_DIV_inst (
    .O(clk_12p8), // 1-bit output: Buffer
    .CE('1),        // 1-bit input: Buffer enable
    .CLR('0),       // 1-bit input: Asynchronous clear
    .I(clk100)    // 1-bit input: Buffer
  );


endmodule



