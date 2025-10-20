module key_reg #(parameter W=128)(
  input  logic clk, rst_n, we, zeroize,
  input  logic [W-1:0] d,
  output logic [W-1:0] q
);
  always_ff @(posedge clk or negedge rst_n)
    if (!rst_n || zeroize) q <= '0;
    else if (we)           q <= d;
endmodule







module key_reg_zeroize #(
  parameter integer W = 128
)(
  input  wire             clk,
  input  wire             rst_n,        // cold reset (active-low)
  input  wire             load,         // load key when 1
  input  wire [W-1:0]     key_in,
  input  wire             tamper,       // async tamper (active-high)
  input  wire             soft_zeroize, // fw request to wipe
  output reg  [W-1:0]     key_out,
  output wire             parity_ok     // simple integrity check
);
  // async zeroize: OR tamper into reset domain safely
  wire zeroize = soft_zeroize | tamper;

  // store + clear
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)           key_out <= {W{1'b0}};
    else if (zeroize)     key_out <= {W{1'b0}};
    else if (load)        key_out <= key_in;
  end

  // simple parity integrity (odd parity over 8-bit lanes)
  wire [W/8-1:0] lane_par;
  genvar i;
  generate for (i=0;i<W/8;i=i+1) begin : g_lane
    assign lane_par[i] = ^key_out[8*i +: 8];
  end endgenerate
  assign parity_ok = ~^lane_par; // 1 if lanes reduce to even (example policy)
endmodule