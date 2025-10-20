// ================================================================
// Glitch filter (active-low input)
// - Updates out_n only after in_n stays stable for STABLE_CYCLES
// ================================================================
module glitch_filter #(
  parameter integer STABLE_CYCLES = 4
)(
  input  wire clk,
  input  wire rst_n,     // active-low reset for this filter logic
  input  wire in_n,      // active-low, possibly glitchy
  output reg  out_n      // active-low, filtered
);

  // Clamp to at least 1 to avoid zero-length behavior
  localparam integer THRESH = (STABLE_CYCLES < 1) ? 1 : STABLE_CYCLES;
  localparam integer CW     = $clog2(THRESH + 1);

  reg                last;         // last observed level of in_n
  reg [CW-1:0]       cnt;          // stability counter

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Choose safe reset state: assume input is NOT asserted (1)
      last  <= 1'b1;
      out_n <= 1'b1;
      cnt   <= {CW{1'b0}};
    end else begin
      // Track stability of in_n
      if (in_n == last) begin
        // increment up to THRESH (saturate)
        if (cnt < THRESH[CW-1:0]) cnt <= cnt + 1'b1;
      end else begin
        // level changed -> start counting again from 1 at this new level
        last <= in_n;
        cnt  <= {{(CW-1){1'b0}}, 1'b1}; // 1
      end

      // Commit new stable level to output after THRESH samples
      if (cnt == THRESH[CW-1:0]) begin
        out_n <= last;
      end
    end
  end

endmodule
