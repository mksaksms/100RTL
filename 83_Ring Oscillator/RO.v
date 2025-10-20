// ================================================================
// Fundamental FPGA Ring Oscillator (RO)
// ------------------------------------------------
// * Simple N-stage inverter loop
// * Synthesizable on FPGAs when marked as KEEP / DONT_TOUCH
// * The oscillation frequency depends on routing + logic delay
// * Usually connected to a counter or sampler for measurement
// ================================================================
module ring_oscillator #(
  parameter integer STAGES = 5   // must be odd for oscillation
)(
  input  wire en,        // enable (1 = run, 0 = stop)
  output wire ro_out     // oscillating output
);

  // Internal ring nodes
  wire [STAGES-1:0] node;

  // ================================================================
  // Generate inverter chain
  // ================================================================
  genvar i;
  generate
    for (i = 0; i < STAGES; i = i + 1) begin : G_INV
      // LUT1 acts as inverter (INIT=2'b01)
      (* keep = "true", dont_touch = "true" *)
      LUT1 #(.INIT(2'b01)) u_inv (
        .I0( (i == 0) ? (en ? node[STAGES-1] : 1'b0) : node[i-1] ),
        .O ( node[i] )
      );
    end
  endgenerate

  // Output
  assign ro_out = node[STAGES-1];

endmodule
