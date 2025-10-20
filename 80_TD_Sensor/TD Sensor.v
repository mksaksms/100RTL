// ================================================================
// Simple FPGA TDC Using Xilinx CARRY4 Delay Line
// ------------------------------------------------
// - Launches 'start_pulse' into carry chain
// - Captures state of each tap with STOP edge (clk_stop)
// - Produces thermometer code (sampled) and simple binary fine output
// ================================================================
`timescale 1ns/1ps
module tdc_carry4_basic #(
  parameter integer NUM_CARRY = 8   // number of CARRY4s (4 taps each)
)(
  input  wire clk_stop,     // sampling clock (STOP edge)
  input  wire start_pulse,  // launch pulse (START)
  output reg  [NUM_CARRY*4-1:0] thermo, // raw thermometer bits
  output reg  [$clog2(NUM_CARRY*4):0] fine // fine time (count of 1s)
);

  localparam integer TAPS = NUM_CARRY * 4;
  wire [TAPS-1:0] taps;

  // Launch into carry chain
  assign taps[0] = start_pulse;

  // ================================================================
  // Delay chain using Xilinx CARRY4 primitives
  // ------------------------------------------------
  // Each CARRY4 provides CO[3:0] outputs with ~15–25ps spacing.
  // Mark them KEEP / DONT_TOUCH to preserve placement.
  // ================================================================
  genvar i;
  generate
    for (i = 0; i < NUM_CARRY; i = i + 1) begin : G_CHAIN
      wire ci_in  = (i==0) ? start_pulse : G_CHAIN[i-1].co_out[3];
      wire [3:0] co;
      (* keep = "true", dont_touch = "true" *)
      CARRY4 u_carry4 (
        .CI(ci_in),        // carry input
        .CYINIT(1'b0),
        .DI(4'b1111),      // enable propagation
        .S(4'b1111),
        .CO(co),
        .O()               // ignore sum outputs
      );
      assign G_CHAIN[i].co_out = co;
      assign taps[i*4 +: 4] = co;
    end
  endgenerate

  // ================================================================
  // Sample delay line at STOP edge
  // ================================================================
  always @(posedge clk_stop) begin
    thermo <= taps;
  end

  // ================================================================
  // Simple thermometer → binary encoder
  // (counts number of 1s from LSB upwards until first 0)
  // ================================================================
  integer k;
  always @* begin
    fine = 0;
    for (k = 0; k < TAPS; k = k + 1) begin
      if (thermo[k]) fine = fine + 1;
      else break;
    end
  end
endmodule
