module msk_modulator (
    input  logic        clk,           // 200 MHz clock
    input  logic        reset_n,       // Active-low reset
    input  logic        data_in,       // Binary input data
    output logic signed [15:0] i_out,  // In-phase (I) output
    output logic signed [15:0] q_out   // Quadrature (Q) output
);

    logic dbg_phase_step=0;

    // MSK Parameters
    localparam real FS_REAL = 800.0e6;
    localparam real F_IF_REAL = 50.0e6;
    localparam real F_SYM_REAL = 10.0e6;
    localparam real FREQ_DEV_REAL = 0.25 * F_SYM_REAL;
    
    // NCO Phase Accumulators
    logic [31:0] phase_acc;
    logic [31:0] phase_step_high=0, phase_step_low=0;
    
    // MSK Frequency Deviation ± 0.25 * F_SYM
    localparam int PHASE_STEP_HIGH = int'((F_IF_REAL + FREQ_DEV_REAL) * (2.0**32) / FS_REAL);
    localparam int PHASE_STEP_LOW  = int'((F_IF_REAL - FREQ_DEV_REAL) * (2.0**32) / FS_REAL);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            phase_acc <= 0;
        end else begin
            // Select phase increment based on input bit
            phase_step_high <= PHASE_STEP_HIGH;
            phase_step_low  <= PHASE_STEP_LOW;
            phase_acc <= phase_acc + (data_in ? phase_step_high : phase_step_low);
            dbg_phase_step <= data_in ? 1:0;
        end
    end

    // Generate sine and cosine waveforms (I/Q)
    function signed [15:0] sine_wave(input [31:0] phase);
        real phase_radians;
        phase_radians = (phase * 2.0 * 3.14159265) / (2.0**32); // Convert fixed-point phase to radians
        return $signed(32767 * $sin(phase_radians));
    endfunction

    function signed [15:0] cosine_wave(input [31:0] phase);
        real phase_radians;
        phase_radians = (phase * 2.0 * 3.14159265) / (2.0**32);
        return $signed(32767 * $cos(phase_radians));
    endfunction

    logic signed [15:0] i_o=0,q_o=0;
    always_ff @(posedge clk) begin
        i_o <= cosine_wave(phase_acc - (2**30));
        q_o <= -sine_wave(phase_acc - (2**30));
    end

  assign i_out = i_o;
  assign q_out = q_o;

endmodule
