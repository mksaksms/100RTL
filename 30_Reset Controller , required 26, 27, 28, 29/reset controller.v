// ================================================================
// Reset Controller / Sequencer (v1.1-style)
// ------------------------------------------------
// - Primary async reset input with optional glitch filter (active-low)
// - Aux reset and PLL lock gating
// - Minimum pulse-width validator (assert & deassert)
// - Fully synchronous OR sync-on-deassert selectable
// - 3 staged outputs: RST0_n, RST1_n, RST2_n (active-low)
// - Programmable inter-stage delays (stretch)
// ================================================================
module reset_controller #(
  // ---------- Behavior ----------
  parameter bit  GF_ENABLE        = 1'b1,       // enable digital glitch filter on primary reset
  parameter int  GF_STABLE_CYCLES = 4,          // cycles input must stay stable to pass filter
  parameter int  MIN_PW_ASSERT    = 2,          // min cycles reset must be asserted to be recognized
  parameter int  MIN_PW_DEASSERT  = 2,          // min cycles reset must be deasserted to be recognized
  parameter bit  FULLY_SYNC       = 1'b0,       // 0: async assert / sync deassert ; 1: fully synchronous

  // ---------- Sequencing (deassert gaps, in clk cycles) ----------
  parameter int  DELAY_R0         = 16,         // cycles before deasserting RST0_n
  parameter int  DELAY_R1         = 16,         // +cycles after RST0_n deassert before RST1_n
  parameter int  DELAY_R2         = 16,         // +cycles after RST1_n deassert before RST2_n

  // ---------- Implementation ----------
  parameter int  SYNC_STAGES      = 2,          // FF sync depth
  parameter int  CW               = 16          // generic counter width (>= max of delays)
)(
  input  wire clk,               // system clock
  input  wire async_reset_n,     // primary external reset (usually async, active-low)
  input  wire aux_reset,         // optional aux reset (active-high). ORed after filter
  input  wire pll_locked,        // active-high when clock stable; reset holds while !pll_locked

  output wire rst0_n,            // stage 0 reset (active-low)
  output wire rst1_n,            // stage 1 reset (active-low)
  output wire rst2_n             // stage 2 reset (active-low)
);

  // ------------------------------
  // 1) Optional glitch filter on primary async_reset_n (active-low)
  //     Outputs 'gf_out_low' = filtered active-low primary reset
  // ------------------------------
  wire gf_out_low;

  generate
    if (GF_ENABLE) begin : g_gf
      glitch_filter #(.STABLE_CYCLES(GF_STABLE_CYCLES)) u_gf (
        .clk (clk),
        .in_n(async_reset_n), // active-low
        .out_n(gf_out_low)
      );
    end else begin : g_gf_bypass
      assign gf_out_low = async_reset_n;
    end
  endgenerate

  // ------------------------------
  // 2) Combine sources (active-high request)
  //     rst_req = (!primary_ok) OR aux_reset OR (!pll_locked)
  // ------------------------------
  wire rst_req_raw = (~gf_out_low) | aux_reset | (~pll_locked);

  // ------------------------------
  // 3) Minimum pulse-width qualify (assert & deassert)
  //     Output: rst_req_qual (active-high, debounced width-wise)
  // ------------------------------
  wire rst_req_qual;
  min_pw_qual #(
    .MIN_PW_ASSERT  (MIN_PW_ASSERT),
    .MIN_PW_DEASSERT(MIN_PW_DEASSERT)
  ) u_minpw (
    .clk (clk),
    .sig_i(rst_req_raw),
    .sig_o(rst_req_qual)
  );

  // ------------------------------
  // 4) Synchronization policy
  //     FULLY_SYNC = 0 -> async assert, sync deassert
  //     FULLY_SYNC = 1 -> fully synchronous (both edges through FFs)
  // ------------------------------
  wire rst_sync;  // active-high internal reset request after policy
  generate
    if (FULLY_SYNC) begin : g_full_sync
      // Both edges through synchronizer
      ff_synchronizer #(.STAGES(SYNC_STAGES)) u_sync_both (
        .clk (clk),
        .d   (rst_req_qual),
        .q   (rst_sync)
      );
    end else begin : g_sync_on_deassert
      // Async assert path, sync deassert:
      // Implement by forcing the synchronizer flops to '1' immediately on assertion
      // and shift down to '0' only when rst_req_qual is 0 (classic reset sync).
      reset_deassert_synchronizer #(.STAGES(SYNC_STAGES)) u_sync_deassert (
        .clk (clk),
        .rst_req (rst_req_qual), // active-high
        .rst_sync(rst_sync)
      );
    end
  endgenerate

  // ------------------------------
  // 5) Sequencer: hold all asserted while rst_sync==1.
  //    When it drops to 0, deassert RST0/RST1/RST2 with gaps.
  // ------------------------------
  reg [CW-1:0] ctr;
  reg          r0_n, r1_n, r2_n;  // active-low outputs (regs)
  assign rst0_n = r0_n;
  assign rst1_n = r1_n;
  assign rst2_n = r2_n;

  typedef enum logic [1:0] {SEQ_HOLD=2'd0, SEQ_R0=2'd1, SEQ_R1=2'd2, SEQ_R2=2'd3} seq_e;
  seq_e state, state_n;

  // next-state
  always @* begin
    state_n = state;
    case (state)
      SEQ_HOLD: if (!rst_sync) state_n = SEQ_R0;
      SEQ_R0  : if (ctr >= DELAY_R0) state_n = SEQ_R1;
      SEQ_R1  : if (ctr >= (DELAY_R0 + DELAY_R1)) state_n = SEQ_R2;
      SEQ_R2  : if (ctr >= (DELAY_R0 + DELAY_R1 + DELAY_R2)) state_n = SEQ_R2; // stay released
      default : state_n = SEQ_HOLD;
    endcase
  end

  // seq / outputs
  always @(posedge clk or posedge rst_sync) begin
    if (rst_sync) begin
      // immediate assertion of all resets
      state <= SEQ_HOLD;
      ctr   <= {CW{1'b0}};
      r0_n  <= 1'b0; // asserted (active-low)
      r1_n  <= 1'b0;
      r2_n  <= 1'b0;
    end else begin
      state <= state_n;
      case (state)
        SEQ_HOLD: begin
          ctr  <= {CW{1'b0}};
          r0_n <= 1'b0;
          r1_n <= 1'b0;
          r2_n <= 1'b0;
        end
        SEQ_R0: begin
          ctr  <= ctr + 1'b1;
          r0_n <= 1'b1; // deassert stage 0
          r1_n <= 1'b0;
          r2_n <= 1'b0;
        end
        SEQ_R1: begin
          ctr  <= ctr + 1'b1;
          r0_n <= 1'b1;
          r1_n <= 1'b1; // deassert stage 1
          r2_n <= 1'b0;
        end
        SEQ_R2: begin
          ctr  <= ctr;  // optional stop counting
          r0_n <= 1'b1;
          r1_n <= 1'b1;
          r2_n <= 1'b1; // deassert stage 2
        end
        default: begin
          ctr  <= {CW{1'b0}};
          r0_n <= 1'b0;
          r1_n <= 1'b0;
          r2_n <= 1'b0;
        end
      endcase
    end
  end

endmodule

// ================================================================
// Digital glitch filter for an active-low input.
// Updates output only after the input stays STABLE_CYCLES low OR high.
// ================================================================
module glitch_filter #(
  parameter int STABLE_CYCLES = 4,
  parameter int CW            = $clog2((STABLE_CYCLES<1)?1:STABLE_CYCLES)+2
)(
  input  wire clk,
  input  wire in_n,     // active-low
  output reg  out_n     // active-low
);
  reg last;
  reg [CW-1:0] cnt;

  always @(posedge clk) begin
    if (in_n == last) begin
      if (cnt < STABLE_CYCLES[CW-1:0]) cnt <= cnt + 1'b1;
    end else begin
      cnt  <= '0;
      last <= in_n;
    end

    if (cnt == STABLE_CYCLES[CW-1:0]) begin
      out_n <= last;
    end
  end

  // init
  initial begin
    last  = 1'b1;
    out_n = 1'b1;
    cnt   = '0;
  end
endmodule

// ================================================================
// Minimum pulse-width qualifier for a 1-bit signal (active-high).
// Requires stable '1' for MIN_PW_ASSERT cycles and stable '0' for
// MIN_PW_DEASSERT cycles to toggle the qualified output.
// ================================================================
module min_pw_qual #(
  parameter int MIN_PW_ASSERT   = 2,
  parameter int MIN_PW_DEASSERT = 2,
  parameter int CW_A            = $clog2((MIN_PW_ASSERT  <1)?1:MIN_PW_ASSERT )+2,
  parameter int CW_D            = $clog2((MIN_PW_DEASSERT<1)?1:MIN_PW_DEASSERT)+2
)(
  input  wire clk,
  input  wire sig_i,
  output reg  sig_o
);
  reg        last;
  reg [CW_A-1:0] cnt_a;
  reg [CW_D-1:0] cnt_d;

  always @(posedge clk) begin
    // Track stability windows separately for hi/lo
    if (sig_i) begin
      cnt_a <= (sig_i==last) ? (cnt_a + (cnt_a < MIN_PW_ASSERT[CW_A-1:0])) : '0;
      cnt_d <= '0;
    end else begin
      cnt_d <= (sig_i==last) ? (cnt_d + (cnt_d < MIN_PW_DEASSERT[CW_D-1:0])) : '0;
      cnt_a <= '0;
    end

    // Commit transition only after min width satisfied
    if (sig_i && !sig_o && (cnt_a == MIN_PW_ASSERT[CW_A-1:0])) sig_o <= 1'b1;
    if (!sig_i && sig_o && (cnt_d == MIN_PW_DEASSERT[CW_D-1:0])) sig_o <= 1'b0;

    last <= sig_i;
  end

  initial begin
    sig_o = 1'b0;
    last  = 1'b0;
    cnt_a = '0;
    cnt_d = '0;
  end
endmodule

// ================================================================
// Generic FF synchronizer for control signals.
// ================================================================
module ff_synchronizer #(
  parameter int STAGES = 2
)(
  input  wire clk,
  input  wire d,
  output wire q
);
  reg [STAGES-1:0] sh;
  always @(posedge clk) begin
    sh <= {sh[STAGES-2:0], d};
  end
  assign q = sh[STAGES-1];
  initial sh = {STAGES{1'b1}}; // optional power-up bias
endmodule

// ================================================================
// Reset deassertion synchronizer (classic):
//  - Asserts 'rst_sync' immediately when rst_req=1 (async-style assertion)
//  - Deasserts only after STAGES clock edges when rst_req=0.
// ================================================================
module reset_deassert_synchronizer #(
  parameter int STAGES = 2
)(
  input  wire clk,
  input  wire rst_req,   // active-high
  output wire rst_sync   // active-high
);
  reg [STAGES-1:0] sh;

  always @(posedge clk or posedge rst_req) begin
    if (rst_req) begin
      sh <= {STAGES{1'b1}};    // assert immediately
    end else begin
      sh <= {sh[STAGES-2:0], 1'b0}; // shift out to 0 = synchronized deassert
    end
  end

  assign rst_sync = sh[STAGES-1];

  initial sh = {STAGES{1'b1}};
endmodule
