module top_io (
    input         UART0_RX_I,
    output        UART0_TX_O,
    input         UART1_RX_I,
    output        UART1_TX_O,
    output [1:0]  RADIO_LED     // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

  logic [4:0] led_div1;

  logic rx0,tx0,rx1,tx1;
  logic clk_p78125;// 0.781250 MHz

///////////////////////////////////////////////////////////////////////////////////////////////////

  assign rx0 = UART0_RX_I;
  assign rx1 = UART1_RX_I;
  assign UART0_TX_O = tx0;
  assign UART1_TX_O = tx1;

  top_bd_wrapper top_bd_wrapper_inst (
    .clk100       (clk100       ),
    .clk_6p25     (clk_6p25     ),
    .clk_10       (clk_10       ),
    .rstn         (rstn         ),
    .UART_0_rxd   (rx0          ), // IN
    .UART_0_txd   (tx0          ), // OUT
    .UART_1_rxd   (rx1          ), // IN
    .UART_1_txd   (tx1          ), // OUT
    .led_div1_o   (led_div1     ),
    .led_o        (RADIO_LED[0] )//Yellow
  );

  BUFGCE_DIV #(
    .BUFGCE_DIVIDE(8),              // 1-8
    // Programmable Inversion Attributes: Specifies built-in programmable inversion on specific pins
    .IS_CE_INVERTED(1'b0),          // Optional inversion for CE
    .IS_CLR_INVERTED(1'b0),         // Optional inversion for CLR
    .IS_I_INVERTED(1'b0),           // Optional inversion for I
    .SIM_DEVICE("ULTRASCALE_PLUS")  // ULTRASCALE, ULTRASCALE_PLUS
  ) BUFGCE_DIV_inst (
    .O(clk_p78125), // 1-bit output: Buffer
    .CE('1),        // 1-bit input: Buffer enable
    .CLR('0),       // 1-bit input: Asynchronous clear
    .I(clk_6p25)    // 1-bit input: Buffer
  );

  led_cnt led_cnt_inst (
    .rst      (~rstn        ),
    .clk100   (clk_p78125   ),
    .div_i    (5'h3         ),//led_div1
    .wren_i   ('0           ),
    .led_o    (RADIO_LED[1] ) //BLUE
  );

  ila1 ila1_inst (
  	.clk(clk_p78125),   // input wire clk
  	.probe0(rx0),      // input wire [0:0]  probe0  
  	.probe1(tx0),       // input wire [0:0]  probe1
  	.probe2(rx1),       // input wire [0:0]  probe1
  	.probe3(tx1)       // input wire [0:0]  probe1
  );

  ila1 ila1_inst2 (
  	.clk(clk100),   // input wire clk
  	.probe0(rx0),      // input wire [0:0]  probe0  
  	.probe1(tx0),       // input wire [0:0]  probe1
  	.probe2(rx1),       // input wire [0:0]  probe1
  	.probe3(tx1)       // input wire [0:0]  probe1
  );


endmodule


