// ================================================================
// Minimum pulse-width qualifier (active-high signal)
// - sig_o changes only if sig_i remains high/low long enough

// ================================================================
module min_pw_qual #(
  parameter integer MIN_PW_ASSERT   = 2,  // cycles high required to assert
  parameter integer MIN_PW_DEASSERT = 2   // cycles low  required to deassert
)(
  input  wire clk,
  input  wire rst_n,    // active-low reset
  input  wire sig_i,    // raw input (active-high)
  output reg  sig_o     // qualified output (active-high)
);

  localparam integer TH_A = (MIN_PW_ASSERT   < 1) ? 1 : MIN_PW_ASSERT;
  localparam integer TH_D = (MIN_PW_DEASSERT < 1) ? 1 : MIN_PW_DEASSERT;
  localparam integer CWA  = $clog2(TH_A + 1);
  localparam integer CWD  = $clog2(TH_D + 1);

  reg                last;
  reg [CWA-1:0]      cnt_a;  // high-duration counter
  reg [CWD-1:0]      cnt_d;  // low-duration counter

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sig_o <= 1'b0;     // choose safe reset state for your system
      last  <= 1'b0;
      cnt_a <= {CWA{1'b0}};
      cnt_d <= {CWD{1'b0}};
    end else begin
      // Count consecutive high or low samples
      if (sig_i) begin
        // counting '1's
        if (sig_i == last) begin
          if (cnt_a < TH_A[CWA-1:0]) cnt_a <= cnt_a + 1'b1;
        end else begin
          cnt_a <= {{(CWA-1){1'b0}}, 1'b1};
        end
        cnt_d <= {CWD{1'b0}};
      end else begin
        // counting '0's
        if (sig_i == last) begin
          if (cnt_d < TH_D[CWD-1:0]) cnt_d <= cnt_d + 1'b1;
        end else begin
          cnt_d <= {{(CWD-1){1'b0}}, 1'b1};
        end
        cnt_a <= {CWA{1'b0}};
      end

      // Commit transitions only when thresholds are reached
      if (sig_i && !sig_o && (cnt_a == TH_A[CWA-1:0])) sig_o <= 1'b1;
      if (!sig_i && sig_o && (cnt_d == TH_D[CWD-1:0])) sig_o <= 1'b0;

      last <= sig_i;
    end
  end

endmodule
