// Upconversion module: converts I/Q baseband (16-bit) to a real passband signal.
module duc #(
    parameter real IF = 50e6,   // Intermediate frequency in Hz.
    parameter real FS = 200e6   // Sample rate in Hz.
)(
    input  logic                clk,
    input  logic                reset,
    input  logic signed [15:0]  dds_tdata,
    input  logic signed [15:0]  I_data,  // In-phase component.
    input  logic signed [15:0]  Q_data,  // Quadrature component.
    output logic signed [15:0]  dac_out  // Real-valued (digitized) output to DAC.
);

//  logic [15:0] dds_tdata;
  logic signed [17:0]  dds_sin, dds_cos, q_ext, i_ext;
  logic signed [47:0]  QxSIN, duc_data;
//  dds_50 dds_50_inst (
//    .aclk(clk), // input wire aclk
//    .m_axis_data_tvalid(),  // output wire m_axis_data_tvalid
//    .m_axis_data_tdata(dds_tdata) // output wire [15 : 0] m_axis_data_tdata
//  );

  assign dds_sin = signed'({dds_tdata[15:8]});
  assign dds_cos = signed'({dds_tdata[7:0]});
  
  assign i_ext = signed'({I_data});
  assign q_ext = signed'({Q_data});

  // A*B-C
  dsp_macro_AxBmC dsp_QxSIN (
    .CLK  (clk      ),
    .A    (q_ext    ),
    .B    (dds_sin  ),
    .C    ('0       ),
    .P    (QxSIN    )
  );

  dsp_macro_AxBmC dsp_IxCOSmQxSIN (
    .CLK  (clk      ),
    .A    (i_ext    ),
    .B    (dds_cos  ),
    .C    (QxSIN    ),
    .P    (duc_data )
  );

  assign dac_out = duc_data[22:7];

endmodule

