`timescale 1ns/1ps

module frequency_counter #(
    parameter REF_FREQ_HZ = 50_000_000,
    parameter GATE_TIME_MS = 100
)(
    input  wire        ref_clk,
    input  wire        reset,
    input  wire        signal_in,
    output reg [31:0]  frequency_hz,
    output reg         measurement_done
);

    localparam integer GATE_CYCLES =
        (REF_FREQ_HZ / 1000) * GATE_TIME_MS;

    reg [31:0] gate_counter;
    reg [31:0] pulse_counter;

    reg signal_sync1;
    reg signal_sync2;
    reg signal_prev;

    always @(posedge ref_clk) begin
        if (reset) begin
            gate_counter      <= 32'd0;
            pulse_counter     <= 32'd0;
            frequency_hz      <= 32'd0;
            measurement_done  <= 1'b0;

            signal_sync1      <= 1'b0;
            signal_sync2      <= 1'b0;
            signal_prev       <= 1'b0;
        end
        else begin
            // Synchronize input signal to reference clock
            signal_sync1 <= signal_in;
            signal_sync2 <= signal_sync1;

            // Default
            measurement_done <= 1'b0;

            // Rising-edge detection
            signal_prev <= signal_sync2;

            if (signal_sync2 && !signal_prev)
                pulse_counter <= pulse_counter + 1'b1;

            // Measurement gate
            if (gate_counter < GATE_CYCLES - 1) begin
                gate_counter <= gate_counter + 1'b1;
            end
            else begin
                // Convert measured pulses to Hz
                frequency_hz <=
                    (pulse_counter * 1000) / GATE_TIME_MS;

                gate_counter     <= 32'd0;
                pulse_counter    <= 32'd0;
                measurement_done <= 1'b1;
            end
        end
    end

endmodule
