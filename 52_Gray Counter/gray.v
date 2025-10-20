// ------------------------------------------------------------
// Gray counter
//  - Internal binary counter; output is Gray-coded: g = b ^ (b >> 1)
//  - Only one bit changes per increment
// ------------------------------------------------------------
module gray_counter #(
    parameter int unsigned WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 rst_n,  // sync active-low reset
    input  logic                 en,
    output logic [WIDTH-1:0]     gray
);
    logic [WIDTH-1:0] bin;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            bin <= '0;
        end else if (en) begin
            bin <= bin + 1'b1;
        end
    end



    // Gray encoding
    always_comb begin
        gray = bin ^ (bin >> 1);
    end
endmodule



// ------------------------------------------------------------
// Binary up-counter
// ------------------------------------------------------------
module binary_counter #(
    parameter int unsigned WIDTH = 8
) (
    input  logic                 clk,
    input  logic                 rst_n,  // sync active-low reset
    input  logic                 en,
    output logic [WIDTH-1:0]     q
);
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            q <= '0;
        end else if (en) begin
            q <= q + 1'b1;
        end
    end
endmodule



