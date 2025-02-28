module iq_to_real (
    input  logic        clk,           // 200 MHz system clock
    input  logic        reset_n,       // Active-low reset
    input  logic signed [15:0] i_in,   // In-phase input (I)
    input  logic signed [15:0] q_in,   // Quadrature input (Q)
    output logic signed [15:0] real_out // Real-valued IF output
);

    // Parameters for IF frequency and sampling rate
    localparam real FS_REAL = 800.0e6;  // Sampling rate
    localparam real F_IF_REAL = 50.0e6; // Intermediate Frequency

    // Compute phase step using real arithmetic first
    localparam int PHASE_STEP = int'((F_IF_REAL * (2.0**32)) / FS_REAL);

    // Phase accumulator for NCO
    logic [31:0] phase_acc=0;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            phase_acc <= 0;
        else
            phase_acc <= phase_acc + PHASE_STEP;
    end

    // Generate sine and cosine waveforms for modulation
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

    // Real-valued IF signal generation: I * cos - Q * sin
    logic signed [15:0] real_o=0;
    logic signed [31:0] mix_result=0;
    always_ff @(posedge clk) begin
        mix_result <= (i_in * cosine_wave(phase_acc)) - (q_in * sine_wave(phase_acc));
        real_o <= mix_result[30:15]; // Scale correctly to 16-bit output
    end

  assign real_out = real_o;

endmodule
