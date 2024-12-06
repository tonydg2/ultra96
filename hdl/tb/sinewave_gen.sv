module sinewave_gen #
(
  parameter real FREQ = 10e6,
  parameter real FS   = 100e6
)(
    input logic clk,            // Clock input at 100MHz
    input logic reset_n,        // Active-low reset
    output logic signed [15:0] sine_out  // 16-bit output for sine wave
);

    // Parameters for sine wave generation
   // parameter real FREQ = 20e6;          // Sinewave frequency of 20 MHz
   // parameter real FS = 100e6;  // Sample rate of 100 MHz
    parameter int SAMPLES_PER_CYCLE = FS / FREQ; // Number of samples per cycle

    // ROM to store sine wave samples (scaled to 16-bit signed values)
    logic signed [15:0] sine_lut [0:SAMPLES_PER_CYCLE-1];

    // Populate sine wave look-up table with samples
    initial begin
        for (int i = 0; i < SAMPLES_PER_CYCLE; i++) begin
            real angle = 2.0 * 3.14159265358979 * i / SAMPLES_PER_CYCLE;
            sine_lut[i] = $rtoi(32767 * $sin(angle)); // 16-bit signed value
        end
    end

    // Counter to iterate through LUT
    logic [$clog2(SAMPLES_PER_CYCLE)-1:0] index;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            index <= 0;
            sine_out <= 0;
        end else begin
            sine_out <= sine_lut[index];
            index <= (index + 1) % SAMPLES_PER_CYCLE;
        end
    end

endmodule
