`timescale 1ns/1ps

module frequency_counter_tb;

    reg ref_clk;
    reg reset;
    reg signal_in;

    wire [31:0] frequency_hz;
    wire measurement_done;

    // Use small values for simulation
    frequency_counter #(
        .REF_FREQ_HZ(1_000_000),
        .GATE_TIME_MS(10)
    ) dut (
        .ref_clk(ref_clk),
        .reset(reset),
        .signal_in(signal_in),
        .frequency_hz(frequency_hz),
        .measurement_done(measurement_done)
    );

    // 1 MHz reference clock
    initial begin
        ref_clk = 1'b0;
        forever #500 ref_clk = ~ref_clk;
    end

    // Generate approximately 10 kHz input signal
    initial begin
        signal_in = 1'b0;

        forever begin
            #50 signal_in = ~signal_in;
        end
    end

    initial begin
        reset = 1'b1;

        #2000;
        reset = 1'b0;

        // Run simulation
        #20_000_000;

        $display("Simulation completed.");
        $display("Measured Frequency = %0d Hz", frequency_hz);

        $finish;
    end

    // Monitor measurement
    always @(posedge measurement_done) begin
        $display(
            "Time = %0t ns : Frequency = %0d Hz",
            $time,
            frequency_hz
        );
    end

endmodule
