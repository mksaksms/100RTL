module sync_2ff(
  input  logic clk, rst_n, async_d,
  output logic q
);
  logic s1;
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n) {q,s1} <= 2'b00;
    else        {q,s1} <= {s1, async_d};
endmodule
