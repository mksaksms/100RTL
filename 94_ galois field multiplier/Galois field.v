// ======================================================
// 4-bit Galois Field Multiplier in GF(2^4)
// Irreducible polynomial: P(x) = x^4 + x + 1
// ======================================================
module galois_mult4 (
  input  [3:0] a,
  input  [3:0] b,
  output [3:0] product
);
  reg [6:0] tmp;
  integer i;

  always @(*) begin
    tmp = 0;
    for (i = 0; i < 4; i = i + 1)
      if (b[i])
        tmp = tmp ^ (a << i);  // XOR = addition in GF(2)
    
    // modular reduction by P(x) = x^4 + x + 1 => 0b10011
    for (i = 6; i >= 4; i = i - 1)
      if (tmp[i])
        tmp = tmp ^ (7'b10011 << (i - 4));
  end

  assign product = tmp[3:0];
endmodule
