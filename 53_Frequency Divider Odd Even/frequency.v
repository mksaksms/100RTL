module divN_even_clk #(
    parameter int unsigned N = 8  // must be even (>=2)
) (
    input  logic clk,
    input  logic rst_n,
    output logic clk_div
);
    localparam int HALF = N/2;
    localparam int W    = $clog2(HALF);
    logic [W-1:0] cnt;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            cnt     <= '0;
            clk_div <= 1'b0;
        end else if (cnt == HALF-1) begin
            cnt     <= '0;
            clk_div <= ~clk_div;  // toggle every HALF cycles
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
