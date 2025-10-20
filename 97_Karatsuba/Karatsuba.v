// ================================================================
// 16x16 -> 32 Karatsuba Multiplier (unsigned, single-level)
// a = a1·2^8 + a0,  b = b1·2^8 + b0
// z0 = a0*b0
// z2 = a1*b1
// z1 = (a0+a1)*(b0+b1) - z0 - z2
// result = z2<<16 + z1<<8 + z0
// ================================================================
module karatsuba16_basic (
  input  wire [15:0] a,
  input  wire [15:0] b,
  output wire [31:0] p
);
  // split into 8-bit halves
  wire [7:0] a0 = a[7:0];
  wire [7:0] a1 = a[15:8];
  wire [7:0] b0 = b[7:0];
  wire [7:0] b1 = b[15:8];

  // 3 half-size products
  wire [15:0] z0 = a0 * b0;     // 8x8
  wire [15:0] z2 = a1 * b1;     // 8x8

  // middle term
  wire [8:0]  sa = a0 + a1;     // 0..510
  wire [8:0]  sb = b0 + b1;     // 0..510
  wire [17:0] m  = sa * sb;     // (9x9) -> 18 bits

  // z1 = m - z0 - z2 (align widths for safe subtraction)
  wire [17:0] z0e = {2'b00, z0};        // 18-bit extend
  wire [17:0] z2e = {2'b00, z2};        // 18-bit extend
  wire [17:0] z1  = m - z0e - z2e;      // can be up to 18 bits

  // assemble
  wire [31:0] part_z2 = {z2, 16'h0000};           // z2 << 16
  wire [31:0] part_z1 = { {14{1'b0}}, z1, 8'h00}; // z1 << 8 (18+8 = 26 bits total)
  wire [31:0] part_z0 = {16'h0000, z0};           // z0

  assign p = part_z2 + part_z1 + part_z0;
endmodule


// ================================================================
// Recursive Karatsuba Multiplier (unsigned)
// - WIDTH must be a power of 2, WIDTH >= BASE
// - BASE is the leaf multiply width that uses built-in *
// ================================================================
module karatsuba_mul #(
  parameter integer WIDTH = 32,
  parameter integer BASE  = 8
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  output wire [(2*WIDTH)-1:0] p
);
  localparam HALF = WIDTH/2;

  generate
    if (WIDTH <= BASE) begin : G_LEAF
      assign p = a * b;  // leaf multiply (let synthesis/DSP handle it)
    end else begin : G_REC
      // split
      wire [HALF-1:0] a0 = a[HALF-1:0];
      wire [HALF-1:0] a1 = a[WIDTH-1:HALF];
      wire [HALF-1:0] b0 = b[HALF-1:0];
      wire [HALF-1:0] b1 = b[WIDTH-1:HALF];

      // z0, z2 (recursive)
      wire [(2*HALF)-1:0] z0, z2;
      karatsuba_mul #(.WIDTH(HALF), .BASE(BASE)) U_Z0 (.a(a0), .b(b0), .p(z0));
      karatsuba_mul #(.WIDTH(HALF), .BASE(BASE)) U_Z2 (.a(a1), .b(b1), .p(z2));

      // middle product m = (a0+a1)*(b0+b1)
      wire [HALF:0] sa = {1'b0, a0} + {1'b0, a1};  // (HALF+1) bits
      wire [HALF:0] sb = {1'b0, b0} + {1'b0, b1};  // (HALF+1) bits
      wire [(2*(HALF+1))-1:0] m;
      karatsuba_mul #(.WIDTH(HALF+1), .BASE(BASE)) U_M (.a(sa), .b(sb), .p(m));

      // z1 = m - z0 - z2  (align widths)
      // z0/z2 are 2*HALF wide; extend to 2*(HALF+1)
      localparam integer WZ = 2*HALF;
      localparam integer WM = 2*(HALF+1); // m's width
      wire [WM-1:0] z0e = {{(WM-WZ){1'b0}}, z0};
      wire [WM-1:0] z2e = {{(WM-WZ){1'b0}}, z2};
      wire [WM-1:0] z1  = m - z0e - z2e;

      // assemble:
      // p = (z2 << (2*HALF)) + (z1 << HALF) + z0
      wire [(2*WIDTH)-1:0] part_z2 = {z2, {2*HALF{1'b0}}};
      wire [(2*WIDTH)-1:0] part_z1 = {{(2*WIDTH-WM-HALF){1'b0}}, z1, {HALF{1'b0}}};
      wire [(2*WIDTH)-1:0] part_z0 = {{(2*WIDTH-WZ){1'b0}}, z0};

      assign p = part_z2 + part_z1 + part_z0;
    end
  endgenerate
endmodule




