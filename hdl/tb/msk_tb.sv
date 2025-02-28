module msk_tb;

    // Clock and reset
    logic clk;
    logic reset_n;

    // Binary data input
    logic data_in,demod_data;

    // I/Q signals
    logic signed [15:0] i_out, q_out, i_demod, q_demod;
    
    // Real-valued IF signal
    logic signed [15:0] real_out;

    // Clock generation (200 MHz)
    //always #2.5 clk = ~clk; // 5 ns period (200 MHz)
    always #625ps clk = ~clk; // 800 MHz

    // DUTs (Device Under Test)
    msk_modulator msk_modulator_inst (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .i_out(i_out),
        .q_out(q_out)
    );

    iq_to_real iq_to_real_inst (
        .clk(clk),
        .reset_n(reset_n),
        .i_in(i_out),
        .q_in(q_out),
        .real_out(real_out)
    );

    real_to_iq real_to_iq_inst (
        .clk(clk),
        .reset_n(reset_n),
        .real_in(real_out),
        .i_out(i_demod),
        .q_out(q_demod)
    );

    msk_demodulator msk_demodulator_inst (
        .clk(clk),
        .reset_n(reset_n),
        .i_in(i_out),
        .q_in(q_out),
        .data_out(demod_data)
    );


    // Test vector
    integer file;
    integer i;
    logic [7:0] test_vector[0:31] = '{8'h10, 8'h10, 0, 0, 0, 8'h33, 0, 0, 
                                      0, 8'hff, 8'hff, 8'hff, 8'hff, 8'h1a, 8'h01, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0,
                                      0, 0, 0, 0, 0, 0, 0, 0};
//    logic [7:0] test_vector[0:31] = '{8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 
//                                      8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA,
//                                      8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA,
//                                      8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA, 8'hAA};
//    logic [7:0] test_vector[0:31] = '{8'hAA, 8'h55, 8'hFF, 8'h00, 8'hCC, 8'h33, 8'h0F, 8'hF0, 
//                                      8'hA5, 8'h5A, 8'h3C, 8'hC3, 8'h78, 8'h87, 8'hE1, 8'h1E,
//                                      8'h92, 8'h6D, 8'h4B, 8'hB4, 8'hF7, 8'h08, 8'hD3, 8'h2C,
//                                      8'h19, 8'hE6, 8'hAC, 8'h53, 8'h07, 8'hF8, 8'hB9, 8'h46};

    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        data_in = 0;
        
        // Apply reset
        #20 reset_n = 1;

        // Open file for writing real IF data
        //file = $fopen("msk_real_output.txt", "w");

        // Feed binary test vector
        for (i = 0; i < 32; i = i + 1) begin
            // Send bits serially (each bit lasts 20 clock cycles, assuming 10 MHz symbol rate)
            for (int j = 0; j < 8; j = j + 1) begin
                data_in = test_vector[i][7 - j]; // MSB first
                repeat (80) @(posedge clk); // Hold for 20 clock cycles
            end
        end

        // Run for some extra cycles
        repeat (100) @(posedge clk);

        // Close file and end simulation
        //$fclose(file);
        //$stop;
    end

    // Write output to file
  // always @(posedge clk) begin
  //     if (reset_n) begin
  //         $fwrite(file, "%d\n", real_out);
  //     end
  // end

  // always @(posedge clk) begin
  //     if (reset_n) begin
  //         $display("Data In: %b | I: %d | Q: %d | Real: %d | Recovered I: %d | Recovered Q: %d | Demod Data: %b", 
  //             data_in, i_out, q_out, real_out, i_demod, q_demod, demod_data);
  //     end
  // end


endmodule
