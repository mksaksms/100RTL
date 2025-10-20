// ================================================================
// Basic Xtime Function for AES (GF(2^8) multiply by 2)
// ------------------------------------------------
// Input : 8-bit value 'a'
// Output: 8-bit value 'result' = (a * 2) mod (x^8 + x^4 + x^3 + x + 1)
// ================================================================
module xtime_basic (
  input  [7:0] a,
  output [7:0] result
);
  wire [7:0] shifted;
  wire [7:0] reduction;

  assign shifted   = a << 1;           // multiply by x (shift left)
  assign reduction = 8'h1B;            // AES irreducible polynomial (0x1B)

  // If MSB was 1, XOR with 0x1B for modular reduction
  assign result = (a[7]) ? (shifted ^ reduction) : shifted;
endmodule
