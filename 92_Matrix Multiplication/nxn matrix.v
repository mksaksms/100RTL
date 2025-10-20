// ================================================================
// N x N Matrix Multiplication (parameterized version)
// ================================================================
module matrix_mult #(
  parameter N = 3,
  parameter W = 8
)(
  input  [W-1:0] A [0:N-1][0:N-1],
  input  [W-1:0] B [0:N-1][0:N-1],
  output reg [2*W-1:0] C [0:N-1][0:N-1]
);
  integer i, j, k;

  always @(*) begin
    for (i = 0; i < N; i = i + 1)
      for (j = 0; j < N; j = j + 1) begin
        C[i][j] = 0;
        for (k = 0; k < N; k = k + 1)
          C[i][j] = C[i][j] + A[i][k] * B[k][j];
      end
  end
endmodule
