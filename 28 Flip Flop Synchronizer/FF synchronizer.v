// ================================================================
// Generic 1-bit FF synchronizer
// - Use STAGES >= 2 (2 is standard)
// ================================================================
module ff_synchronizer #(
  parameter integer STAGES = 2
)(
  input  wire clk,
  input  wire rst_n,  // can be tied high if you don't want to reset synchronizer
  input  wire d,      // async input (single bit)
  output wire q       // synchronized output
);

  reg [STAGES-1:0] sh;

  // Note: Many designs omit the reset here to avoid coupling reset into async path.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sh <= {STAGES{1'b0}};
    end else begin
      sh <= {sh[STAGES-2:0], d};
    end
  end

  assign q = sh[STAGES-1];

endmodule
