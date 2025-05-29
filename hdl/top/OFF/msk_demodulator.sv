module msk_demodulator (
    input  logic        clk,          // 200 MHz system clock
    input  logic        reset_n,      // Active-low reset
    input  logic signed [15:0] i_in,  // In-phase (I) input from real_to_iq
    input  logic signed [15:0] q_in,  // Quadrature (Q) input from real_to_iq
    output logic        data_out      // Recovered binary data
);

    // Symbol timing parameters
    localparam int SAMPLES_PER_SYM = 80; // Based on 10 MHz symbol rate (200 MHz / 10 MHz)

    // Registers for phase tracking
    logic signed [31:0] phase_prev, phase_curr;
    logic signed [31:0] phase_diff;
    integer sample_count;

    // Function to compute atan2 in fixed-point format
    function signed [31:0] atan2_fixed(input signed [15:0] y, input signed [15:0] x);
        real phase_radians;
        phase_radians = $atan2(real'(y), real'(x)); // Compute arctan2 in radians
        return int'(phase_radians * (2.0**30) / 3.14159265); // Scale to fixed-point (Q30 format)
    endfunction

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            phase_prev  <= 0;
            phase_curr  <= 0;
            phase_diff  <= 0;
            sample_count <= 0;
            data_out <= 0;
        end else begin
            // Update phase
            phase_prev <= phase_curr;
            phase_curr <= atan2_fixed(q_in, i_in);
            phase_diff <= phase_curr - phase_prev;

            // Handle phase wrapping
            if (phase_diff > (2**30)) 
                phase_diff <= phase_diff - (2**31);
            else if (phase_diff < -(2**30)) 
                phase_diff <= phase_diff + (2**31);

            // Symbol timing: Sample at the middle of a symbol period
            sample_count <= sample_count + 1;
            if (sample_count >= 40) begin
                sample_count <= 0;

                // Make a decision based on phase difference
                if (phase_diff > 0)
                    data_out <= 1;
                else
                    data_out <= 0;
            end
        end
    end
endmodule
