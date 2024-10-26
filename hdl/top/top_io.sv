module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [63:0]  git_hash;
logic [4:0]   led_div_i;
logic [31:0]  timestamp, int_cnt_fiq, int_cnt_irq;
logic [3:0]   led_sel;
logic [15:0]  probe0;
logic [2:0]   int_vec, int_vec1;
logic [11:0]  div1,div2,div3;
logic [3:0]   fiq,irq;

///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .int_clr_fiq_o      (int_clr_fiq),
    .int_clr_irq_o      (int_clr_irq),
    .int_cnt_fiq_i      (int_cnt_fiq),
    .int_cnt_irq_i      (int_cnt_irq),
    .fiq_en_o           (fiq_en_o),
    .int_en_o           (int_en_o),
    .led4_int_o         (led4_int),
//    .pl_ps_apugic_fiq   (fiq),
//    .pl_ps_apugic_irq   (irq),
    .pl_ps_irq1         (int_vec1),
    .div1_o             (div1),
    .div2_o             (div2),
    .div3_o             (div3),
    .wren1_o            (wren1),
    .wren2_o            (wren2),
    .wren3_o            (wren3),
    .led_sel_o          (led_sel    ),
    .pl_int_vec         (int_vec    ),
    .git_hash           (git_hash   ),
    .timestamp          (timestamp  ),
    .clk100             (clk100     ),
    .rstn               (rstn       ),
    .led_o              (led_bd     )
  );

  led_cnt_pr led_cnt_pr_inst (
    .rst        (~rstn        ),
    .clk100     (clk100       ),
    .div_i      (div1         ),
    .int_clr_i  ('0  ),
    .int_cnt_o  (),
    .wren_i     (wren1        ),
    .led_int_o  (int_vec[0]   ),
    .led_o      (led1         )
  );

  led_cnt2_pr led_cnt2_pr_inst (
    .rst        (~rstn        ),
    .clk100     (clk100       ),
    .div_i      (div2         ),
    .wren_i     (wren2        ),
    .int_clr_i  ('0),
    .int_cnt_o  (),
    .led_int_o  (int_vec[1]   ),
    .led_o      (led2         )
  );

  led_cnt3_pr led_cnt3_pr_inst (
    .rst        (~rstn        ),
    .clk100     (clk100       ),
    .div_i      (div3         ),
    .wren_i     (wren3        ),
    .int_clr_i  ('0),
    .int_cnt_o  (),
    .led_int_o  (int_vec[2]   ),
    .led_o      (led3         )
  );

  //Yellow
  assign RADIO_LED[0] = led_bd;
  
  //BLUE
  assign RADIO_LED[1] = (led_sel == 4'h0)? led1:
                        (led_sel == 4'h1)? led2:
                        (led_sel == 4'h2)? led3:
                        (led_sel == 4'h3)? 1'b0: // led off
                        (led_sel == 4'h4)? 1'b1: // led on
                        led_bd;

//led4_int
assign led4_intn = ~led4_int;


// FIQ/IRQ are Active-HIGH at the pins into the PS
// Active-HIGH
//assign fiq[3:1] = 3'b000;
//assign fiq[0] = (fiq_en_o == 1'b1)? int_vec[0] : 1'b0; //led4_int
//assign irq[3:1] = 3'b000;
//assign irq[0] = (int_en_o == 1'b1)? int_vec[1] : 1'b0;
// END Active-HIGH


//assign fiq = (int_en_o == 1'b1)? {led4_intn,led4_intn,led4_intn,led4_intn}:{1'b1,1'b1,1'b1,1'b1}; // legacy interrupts "per CPU", so 4bit vector one for each 4 cores?
//assign irq = (int_en_o == 1'b1)? {led4_intn,led4_intn,led4_intn,led4_intn}:{1'b1,1'b1,1'b1,1'b1}; // legacy interrupts "per CPU", so 4bit vector one for each 4 cores?
assign int_vec1 = int_vec;



endmodule
