module data_whitener #(
  parameter integer W=32, LFSR_W=16
)(
  input  wire clk, input wire rst_n,
  input  wire valid_i, input wire [W-1:0] d_i,
  output reg  valid_o, output reg [W-1:0] d_o
);
  reg [LFSR_W-1:0] lfsr;
  wire fb = lfsr[LFSR_W-1] ^ lfsr[4] ^ lfsr[1] ^ lfsr[0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin lfsr<={LFSR_W{1'b1}}; valid_o<=1'b0; d_o<='0; end
    else begin
      valid_o <= valid_i;
      if (valid_i) begin
        d_o <= d_i ^ {W{lfsr[0]}}; // simple whitening (same bit replicated)
        lfsr <= {lfsr[LFSR_W-2:0], fb};
      end
    end
  end
endmodule
