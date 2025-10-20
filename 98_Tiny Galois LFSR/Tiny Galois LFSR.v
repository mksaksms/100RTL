module lfsr_galois #(parameter W=16, parameter TAPS=16'hB400)(
  input  logic clk, rst_n, en,
  output logic [W-1:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= 'h1;
    else if (en) q <= {q[W-2:0],1'b0} ^ (q[W-1] ? TAPS : '0);
  end
endmodule
