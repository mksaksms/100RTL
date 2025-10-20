module updown_counter #(
    parameter int unsigned WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,   // sync active-low reset
    input  logic                  en,      // count enable
    input  logic                  up_n,    // 1=up, 0=down
    output logic [WIDTH-1:0]      q
);
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            q <= '0;
        end else if (en) begin
            q <= up_n ? (q + 1'b1) : (q - 1'b1);
        end
    end
endmodule