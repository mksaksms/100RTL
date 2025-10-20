module rnd_clk_enable #(
  parameter integer LFSR_W = 8
)(
  input  wire clk,
  input  wire rst_n,
  input  wire en_i,          // original enable
  output wire en_o           // randomized enable (sometimes stalled)
);
  // Simple Fibonacci LFSR (non-zero seed assumed after reset)
  reg [LFSR_W-1:0] lfsr;
  wire feedback = lfsr[LFSR_W-1] ^ lfsr[5] ^ lfsr[3] ^ lfsr[0]; // example taps

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) lfsr <= {LFSR_W{1'b1}}; // non-zero
    else        lfsr <= {lfsr[LFSR_W-2:0], feedback};
  end

  // stall with low probability when LFSR LSBs match pattern
  wire stall = (lfsr[2:0] == 3'b000); // ~1/8 of cycles
  assign en_o = en_i & ~stall;
endmodule
