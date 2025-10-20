module dual_edge_ff (
 input wire clk,
 input wire rst_n,
 input wire d,
 output reg q
);

 reg q_pos, q_neg;

 always @(posedge clk or negedge rst_n)
 if (!rst_n)
 q_pos <= 1'b0;
 else
 q_pos <= d;

 always @(negedge clk or negedge rst_n)
 if (!rst_n)
 q_neg <= 1'b0;
 else
 q_neg <= d;

 // Output combines both paths (could use mux or toggle logic if needed)
 always @(*) begin
 q = clk ? q_pos : q_neg;
 end

endmodule