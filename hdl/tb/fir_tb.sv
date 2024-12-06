// for verifying 'axis_stim_syn' only. 

`timescale 1ns / 1ps  // <time_unit>/<time_precision>
  // time_unit: measurement of delays / simulation time (#10 = 10<time_unit>)
  // time_precision: how delay values are rounded before being used in simulation (degree of accuracy of the time unit)

//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

module fir_tb ;

  logic clk=0, rstn=0, rst;

  //always #2 clk = ~clk; // 250mhz period = 4ns, invert every 2ns
  always #5 clk = ~clk; // 100mhz 

  initial begin
    rstn <= 0;
    #20;
    rstn <= 1;
  end
  assign rst = !rstn;


//-------------------------------------------------------------------------------------------------
//
//-------------------------------------------------------------------------------------------------

  logic [15:0] data = '0;
  logic signed [15:0] sin1_d, sin2_d;
  logic signed [16:0] mixed_sine_out;
  logic dval = 1'b0;

  sinewave_gen # (
      .FREQ (1e5),
      .FS   (100e6)
    ) sin10 (
      .clk      (clk   ),      // Clock input at 100MHz
      .reset_n  (rstn  ),   // Active-low reset
      .sine_out (sin1_d) // 16-bit output for sine wave
  );

  sinewave_gen # (
      .FREQ (25e6),
      .FS   (100e6)
    ) sin20 (
      .clk      (clk   ),      // Clock input at 100MHz
      .reset_n  (rstn  ),   // Active-low reset
      .sine_out (sin2_d) // 16-bit output for sine wave
  );


  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)  mixed_sine_out <= 0;
    else        mixed_sine_out <= sin1_d + sin2_d;
  end

  fir0 fir0_inst (
    .aclk               (clk  ),  // input wire aclk
    .s_axis_data_tvalid (dval ),  // input wire s_axis_data_tvalid
    .s_axis_data_tready (drdy ),  // output wire s_axis_data_tready
    .s_axis_data_tdata  (mixed_sine_out[16:1] ),  // input wire [15 : 0] s_axis_data_tdata
    .m_axis_data_tvalid (     ),  // output wire m_axis_data_tvalid
    .m_axis_data_tdata  (     )   // output wire [47 : 0] m_axis_data_tdata
  );


  initial begin 
    wait(rst==0);
    wait(drdy==1);
    dval <= 1'b1;
    #100ns;
    @(posedge clk);
    data <= 16'h2000; 
    @(posedge clk);
    @(posedge clk);
    data <= 16'h0000; //dval <= 1'b0;
  end 


endmodule