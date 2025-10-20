// ------------------------------------------------------------
// Specific counter (table-driven sequence)
//  - Walks through SEQ[0..LEN-1] in order, then wraps
//  - q outputs the current sequence value
// ------------------------------------------------------------
module specific_counter_tbl #(
    parameter int unsigned WIDTH = 8,
    parameter int unsigned LEN   = 4,
    // Example: '{8'd3, 8'd5, 8'd9, 8'd12}
    parameter logic [WIDTH-1:0]  SEQ [LEN] = '{default:'0}
) (
    input  logic                 clk,
    input  logic                 rst_n,  // sync active-low reset
    input  logic                 en,
    output logic [WIDTH-1:0]     q
);
    logic [$clog2(LEN)-1:0] idx;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            idx <= '0;
            q   <= SEQ[0];
        end else if (en) begin
            q   <= SEQ[idx];
            idx <= (idx == LEN-1) ? '0 : (idx + 1'b1);
        end
    end
endmodule
