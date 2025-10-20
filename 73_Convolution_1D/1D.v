module conv1d_3tap (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  data_in,     // input pixel/sample
    input  wire        data_valid,  // input valid signal
    output reg  [15:0] data_out,    // convolution output
    output reg         out_valid
);

    // Example kernel coefficients (signed)
    parameter signed [7:0] K0 = 8'sd1;
    parameter signed [7:0] K1 = 8'sd2;
    parameter signed [7:0] K2 = 8'sd1;

    // Shift registers for input samples
    reg [7:0] x0, x1, x2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x0 <= 0;
            x1 <= 0;
            x2 <= 0;
            data_out <= 0;
            out_valid <= 0;
        end else begin
            if (data_valid) begin
                // Shift input samples
                x2 <= x1;
                x1 <= x0;
                x0 <= data_in;

                // Perform convolution
                data_out <= (K0 * x0) + (K1 * x1) + (K2 * x2);

                // Output is valid after pipeline fills
                out_valid <= 1'b1;
            end else begin
                out_valid <= 1'b0;
            end
        end
    end

endmodule
