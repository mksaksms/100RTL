// ================================================================
// 4-bit Mastrovito Multiplier for GF(2^4)
// Irreducible Polynomial: P(x) = x^4 + x + 1  (0b10011)
// ------------------------------------------------
// Inputs : A, B (4-bit)
// Output : P (4-bit product = (A * B) mod P(x))
// ================================================================
module mastrovito_4bit (
  input  [3:0] A,
  input  [3:0] B,
  output [3:0] P
);
  wire [6:0] partial; // up to 7-bit before reduction

  // Polynomial multiplication (no carries, XOR = addition)
  assign partial[0] = A[0] & B[0];
  assign partial[1] = (A[1]&B[0]) ^ (A[0]&B[1]);
  assign partial[2] = (A[2]&B[0]) ^ (A[1]&B[1]) ^ (A[0]&B[2]);
  assign partial[3] = (A[3]&B[0]) ^ (A[2]&B[1]) ^ (A[1]&B[2]) ^ (A[0]&B[3]);
  assign partial[4] = (A[3]&B[1]) ^ (A[2]&B[2]) ^ (A[1]&B[3]);
  assign partial[5] = (A[3]&B[2]) ^ (A[2]&B[3]);
  assign partial[6] = (A[3]&B[3]);

  // Modular reduction by x^4 + x + 1
  // step 1: reduce high terms (x^4, x^5, x^6)
  wire r3, r2, r1, r0;

  assign r3 = partial[3] ^ partial[5] ^ partial[6];             // x^3 term
  assign r2 = partial[2] ^ partial[5] ^ partial[6];             // x^2 term
  assign r1 = partial[1] ^ partial[4] ^ partial[6];             // x^1 term
  assign r0 = partial[0] ^ partial[4] ^ partial[5];             // constant term

  assign P = {r3, r2, r1, r0};
endmodule
