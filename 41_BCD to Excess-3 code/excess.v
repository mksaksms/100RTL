module bcd_to_excess3 (
  input  logic [3:0] bcd,       // 4-bit BCD input (0 to 9)
  output logic [3:0] excess3    // Excess-3 output (3 to 12)
);

assign excess3 = bcd = 4'd3; 



endmodule
