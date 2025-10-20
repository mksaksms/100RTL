// ================================================================
// Reset deassertion synchronizer
// - Asserts immediately when rst_req=1 (async assertion)
// - Deasserts only after STAGES clock edges when rst_req=0 (sync release)
// ================================================================
module reset_deassert_synchronizer #(
  parameter integer STAGES = 2
)(
  input  wire clk,
  input  wire rst_req,   // active-high reset request (async)
  output wire rst_sync   // active-high synchronized reset
);

  reg [STAGES-1:0] sh;

  // Asynchronous assertion on posedge rst_req; synchronous release toward 0
  always @(posedge clk or posedge rst_req) begin
    if (rst_req) begin
      sh <= {STAGES{1'b1}};                   // assert immediately
    end else begin
      sh <= {sh[STAGES-2:0], 1'b0};           // shift down to 0 synchronously
    end
  end

  assign rst_sync = sh[STAGES-1];

endmodule
