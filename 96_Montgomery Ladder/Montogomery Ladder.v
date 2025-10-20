// ================================================================
// Basic Montgomery Ladder (conceptual RTL)
// Computes Y = X^E mod N
// Always does two multiplies per bit (constant pattern).
// ================================================================
module montgomery_ladder_basic (
  input  [7:0] X,     // base
  input  [7:0] E,     // exponent
  input  [7:0] N,     // modulus
  output [7:0] Y      // result
);
  integer i;
  reg [7:0] R0, R1;
  reg [7:0] base, exp;

  always @(*) begin
    base = X;
    exp  = E;
    R0   = 8'd1;   // initialize R0 = 1
    R1   = base;   // initialize R1 = X

    // Ladder loop (bit by bit)
    for (i = 7; i >= 0; i = i - 1) begin
      if (exp[i] == 1'b0) begin
        R1 = (R0 * R1) % N;  // multiply
        R0 = (R0 * R0) % N;  // square
      end else begin
        R0 = (R0 * R1) % N;  // multiply
        R1 = (R1 * R1) % N;  // square
      end
    end
  end

  assign Y = R0;
endmodule
