module top_io (
    output [1:0]    RADIO_LED // 1=BLUE, 0=Yellow
);
///////////////////////////////////////////////////////////////////////////////////////////////////
  logic led0,led1;
  logic [4:0] led_div1;
  logic clk200;
///////////////////////////////////////////////////////////////////////////////////////////////////

  top_bd_wrapper top_bd_wrapper_inst (
    .clk100       (clk100   ),
    .rstn         (rstn     ),
    .led_div1_o   (led_div1 ),
    .led_o        (led0     )//Yellow
  );

  led_cnt led_cnt_inst (
    .rst      (~rstn    ),
    .clk100   (clk100   ),
    .div_i    (led_div1 ),
    .wren_i   ('0       ),
    .led_o    (led1     ) //BLUE
  );

  assign RADIO_LED[0] = led0;
  assign RADIO_LED[1] = led1;

///////////////////////////////////////////////////////////////////////////////////////////////////

  mmcm_clk_wiz mmcm_clk_wiz_inst
   (
    .clk_in1(clk100),
    .clk_200(clk200),
    .locked()
   );

  logic test_data, data_out;
  localparam [63:0] test_vector = 64'h1010_0000_3300_ff001;

  data_stream_gen #(
    .STREAM_LEN   (64),
    .BIT_STREAM   (test_vector),
    .HOLD_CYCLES  (20),
    .LOOP         (0)
  ) data_stream_gen_inst (
    .clk          (clk200),   
    .reset        (~rstn),   
    .start_in     (led0),   
    .data_out     (test_data)
  );

  
  logic signed [15:0] i_out, q_out,dc_I,dc_Q,real_out;

  msk_mod #(
    .FS(200.0e6)
  ) msk_mod_inst (
    .clk(clk200),
    .reset_n(rstn),
    .data_in(test_data),
    .i_out(i_out),
    .q_out(q_out)
  );

  duc_ddc_top #(
    .FS(200e6)
  ) duc_ddc_top_inst (
    .clk      (clk200      ),
    .reset    (~rstn      ),
    //DDC
    .adc_in   (real_out ), // from ADC
    .I_out    (dc_I     ), // to demod
    .Q_out    (dc_Q     ), // to demod
    //DUC
    .I_in     (i_out    ), // from modulator
    .Q_in     (q_out    ), // from modulator
    .dac_out  (real_out )  // to DAC
  );

  logic signed [31:0] fir_I_tdata, fir_Q_tdata;

  fir_lpf fir_lpf_dc_I (
    .aclk               (clk200       ),  // input wire aclk
    .s_axis_data_tvalid ('1           ),  // input wire s_axis_data_tvalid
    .s_axis_data_tready (             ),  // output wire s_axis_data_tready
    .s_axis_data_tdata  (dc_I         ),  // input wire [15 : 0] s_axis_data_tdata
    .m_axis_data_tvalid (             ),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata  (fir_I_tdata  )   // output wire [31 : 0] m_axis_data_tdata
  );

  fir_lpf fir_lpf_dc_Q (
    .aclk               (clk200       ),  // input wire aclk
    .s_axis_data_tvalid ('1           ),  // input wire s_axis_data_tvalid
    .s_axis_data_tready (             ),  // output wire s_axis_data_tready
    .s_axis_data_tdata  (dc_Q         ),  // input wire [15 : 0] s_axis_data_tdata
    .m_axis_data_tvalid (             ),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata  (fir_Q_tdata  )   // output wire [31 : 0] m_axis_data_tdata
  );

  msk_demod #(
    .FS(200.0e6)
  ) msk_demod_inst (
    .clk(clk200),
    .reset_n(rstn),
    .midpoint_adj(1),
    .i_in(fir_I_tdata[30:15]),
    .q_in(fir_Q_tdata[30:15]),
    .data_out(data_out)
  );

  logic [4:0] probe0,probe1;
  
  ila1 ila1_inst (
  	.clk(clk200), // input wire clk
  	.probe0(probe0), // input wire [4:0]  probe0  
  	.probe1(probe1) // input wire [4:0]  probe1
  );

  assign probe0[0] = test_data;
  assign probe0[1] = data_out;
  assign probe0[2] = led0;


endmodule
