// ================================================================
// Simple GF(2^8) Inverse (Itoh–Tsujii style, for AES field)
// Polynomial: x^8 + x^4 + x^3 + x + 1  (0x11B)
// ================================================================
module gf_inv_basic (
  input  [7:0] a,
  output [7:0] inv
);
  // Helper: GF(2^8) multiply
  function [7:0] gf_mult;
    input [7:0] x, y;
    reg [7:0] p;
    reg [7:0] temp;
    integer i;
    begin
      p = 8'h00;
      temp = x;
      for (i = 0; i < 8; i = i + 1) begin
        if (y[i]) p = p ^ temp; // add (XOR)
        temp = (temp[7] ? ((temp << 1) ^ 8'h1B) : (temp << 1));
      end
      gf_mult = p;
    end
  endfunction

  // Helper: GF(2^8) square
  function [7:0] gf_square;
    input [7:0] x;
    begin
      gf_square = gf_mult(x, x);
    end
  endfunction

  // ============================================================
  // Step-by-step chain (like manual exponentiation)
  // ============================================================
  wire [7:0] a2   = gf_square(a);               // a^2
  wire [7:0] a4   = gf_square(a2);              // a^4
  wire [7:0] a8   = gf_square(a4);              // a^8
  wire [7:0] a16  = gf_square(a8);              // a^16
  wire [7:0] a32  = gf_square(a16);             // a^32
  wire [7:0] a64  = gf_square(a32);             // a^64
  wire [7:0] a128 = gf_square(a64);             // a^128

  // Multiply chain to reach a^254 = a^(128+64+32+16+8+4+2)
  wire [7:0] m1 = gf_mult(a128, a64);
  wire [7:0] m2 = gf_mult(m1, a32);
  wire [7:0] m3 = gf_mult(m2, a16);
  wire [7:0] m4 = gf_mult(m3, a8);
  wire [7:0] m5 = gf_mult(m4, a4);
  wire [7:0] m6 = gf_mult(m5, a2);

  assign inv = m6;  // final a^254
endmodule
