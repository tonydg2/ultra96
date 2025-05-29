module real_to_iq (
    input  logic        clk,         // 200 MHz system clock
    input  logic        reset_n,     // Active-low reset
    input  logic signed [15:0] real_in,  // Real-valued IF input
    output logic signed [15:0] i_out,    // Recovered In-phase (I)
    output logic signed [15:0] q_out     // Recovered Quadrature (Q)
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

    // Generate sine and cosine waveforms for demodulation
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

    // Multiply real-valued IF signal with local oscillator
    logic signed [31:0] i_mixed=0, q_mixed=0;
    
    always_ff @(posedge clk) begin
        i_mixed <= real_in * cosine_wave(phase_acc);
        q_mixed <= -real_in * sine_wave(phase_acc);
    end

    // Simple low-pass filter: Moving average over 4 samples
    logic signed [31:0] i_sum=0, q_sum=0;
    
    always_ff @(posedge clk) begin
        i_sum <= (i_mixed + i_sum) >>> 1;
        q_sum <= (q_mixed + q_sum) >>> 1;
    end

    assign i_out = i_sum[30:15]; // Scale back to 16-bit
    assign q_out = q_sum[30:15];

endmodule
