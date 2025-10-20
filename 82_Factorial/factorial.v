`timescale 1ns / 1ps

module factorial_synthesizable(
    input  wire        clk,
    input  wire        reset,     // active-high synchronous reset
    input  wire        start,     // start pulse
    input  wire [3:0]  n,         // input number (0–15)
    output reg  [31:0] result,    // factorial output
    output reg         done       // high when done
);
    reg [3:0] i;

    always @(posedge clk) begin
        if (reset) begin
            i      <= 0;
            result <= 1;
            done   <= 0;
        end 
        else if (start) begin
            // initialize on start
            i      <= 1;
            result <= 1;
            done   <= 0;
        end 
        else if (!done) begin
            if (i <= n) begin
                result <= result * i;  // multiply each cycle
                i <= i + 1;
            end 
            else begin
                done <= 1;  // computation finished
            end
        end
    end
endmodule
