module johnson_counter #(
    parameter int unsigned N = 8
) (
    input  logic           clk,
    input  logic           rst_n,  // sync active-low reset
    input  logic           en,
    output logic [N-1:0]   q
);
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            q <= '0;                 // common reset state: all zeros
        end else if (en) begin
            q <= { q[N-2:0], ~q[N-1] }; // left-shift in inverted MSB
        end
    end
endmodule