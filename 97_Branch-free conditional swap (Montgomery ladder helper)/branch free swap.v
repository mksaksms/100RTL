module ct_cswap #(parameter W=256)(
  input  logic sel,
  input  logic [W-1:0] a_in, b_in,
  output logic [W-1:0] a_out, b_out
);
  wire [W-1:0] m = {W{sel}};
  wire [W-1:0] t = (a_in ^ b_in) & m;
  assign a_out = a_in ^ t;
  assign b_out = b_in ^ t;
endmodule
