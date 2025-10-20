module lfsr #(
  parameter WIDTH = 8,
  parameter [WIDTH-1:0] TAPS = 8'b10000011  // Taps for 8-bit maximal LFSR
)(
  input  logic       clk,
  input  logic       rst_n,
  input  logic       enable,
  output logic [WIDTH-1:0] lfsr_out
);

  logic feedback;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      lfsr_out <= '1;  // seed value ≠ 0
    else if (enable) begin
     
    end
  end

endmodule