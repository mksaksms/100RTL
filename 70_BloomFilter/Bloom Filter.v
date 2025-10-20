// ================================================================
// Bloom Filter (Fundamentals RTL)
// ------------------------------------------------
// - Parameterizable bit array size (power-of-two recommended).
// - K independent hash functions via XOR-salt + multiplicative mix.
// - Single-cycle INSERT and QUERY (combinational hash).
// - CLEAR_ALL synchronously zeros the bit array.
// - Active-low rst_n; simple start/done handshake.
// ------------------------------------------------
// Notes:
// * For large M_BITS on FPGA, replace 'reg [M_BITS-1:0]' with block RAM.
// * M_BITS should be >= 64 and ideally a power of 2. INDEX_W = $clog2(M_BITS).
// * Insert: sets K bits. Query: hit only if all K bits are set.
// ================================================================
module bloom_filter #(
  parameter integer KEY_W     = 32,
  parameter integer M_BITS    = 1024,  // size of filter bit array
  parameter integer K_HASH    = 3,     // number of hash functions (>=1)
  // salts for hash functions (must have K_HASH entries)
  parameter [KEY_W-1:0] SALT0 = 32'h243F_6A88,
  parameter [KEY_W-1:0] SALT1 = 32'h85A3_08D3,
  parameter [KEY_W-1:0] SALT2 = 32'h1319_8A2E
)(
  input  wire                 clk,
  input  wire                 rst_n,

  // Command
  input  wire                 start,     // pulse to begin op
  input  wire                 op_insert, // 1=INSERT, 0=QUERY
  input  wire                 clear_all, // synchronous clear all bits (dominant)
  input  wire [KEY_W-1:0]     key,

  // Status / Result
  output reg                  busy,
  output reg                  done,      // 1-cycle pulse when op completes
  output reg                  hit        // valid only for QUERY
);

  // ------------------------------
  // Parameters & locals
  // ------------------------------
  localparam integer INDEX_W = $clog2(M_BITS);
  localparam [KEY_W-1:0] MIX_C = 32'h9E37_79B1; // Knuth-like multiplicative constant

  // Bit array
  reg [M_BITS-1:0] bf_bits;

  // ------------------------------
  // Hash functions (combinational)
  // idx_i = ((key ^ SALT_i) * MIX_C) >> (KEY_W - INDEX_W)
  // ------------------------------
  wire [INDEX_W-1:0] idx0, idx1, idx2;

  wire [KEY_W-1:0] h0 = (key ^ SALT0) * MIX_C;
  wire [KEY_W-1:0] h1 = (key ^ SALT1) * MIX_C;
  wire [KEY_W-1:0] h2 = (key ^ SALT2) * MIX_C;

  assign idx0 = h0[KEY_W-1 -: INDEX_W];
  assign idx1 = (K_HASH>1) ? h1[KEY_W-1 -: INDEX_W] : {INDEX_W{1'b0}};
  assign idx2 = (K_HASH>2) ? h2[KEY_W-1 -: INDEX_W] : {INDEX_W{1'b0}};

  // Build a one-hot mask for bits to set / check
  reg [M_BITS-1:0] mask;

  always @* begin
    mask = {M_BITS{1'b0}};
    mask[idx0] = 1'b1;
    if (K_HASH > 1) mask[idx1] = 1'b1;
    if (K_HASH > 2) mask[idx2] = 1'b1;
    // (Extend similarly if you add more SALTs / hash lanes)
  end

  // Query evaluates if all K bits are set
  wire all_set = & (bf_bits & mask) == 1'b1 ? 1'b1 : 1'b0;
  // The '&' above is bitwise AND; we want to know “are all mask bits 1 in bf_bits?”
  // Implement safely:
  reg must_be_all_set;
  integer bi;
  always @* begin
    must_be_all_set = 1'b1;
    if (!bf_bits[idx0]) must_be_all_set = 1'b0;
    if (K_HASH > 1 && !bf_bits[idx1]) must_be_all_set = 1'b0;
    if (K_HASH > 2 && !bf_bits[idx2]) must_be_all_set = 1'b0;
  end

  // ------------------------------
  // Control: start/done; clear dominates
  // ------------------------------
  typedef enum logic [1:0] {S_IDLE, S_OP, S_DONE} st_e;
  st_e st, st_n;

  always @* begin
    st_n = st;
    case (st)
      S_IDLE: if (start)  st_n = S_OP;
      S_OP  :             st_n = S_DONE;   // single-cycle INSERT/QUERY
      S_DONE:             st_n = S_IDLE;
      default:            st_n = S_IDLE;
    endcase
  end

  // ------------------------------
  // Sequential: array, status, outputs
  // ------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st   <= S_IDLE;
      busy <= 1'b0;
      done <= 1'b0;
      hit  <= 1'b0;
      bf_bits <= {M_BITS{1'b0}};
    end else begin
      done <= 1'b0;

      if (clear_all) begin
        // Synchronous clear dominates any operation
        bf_bits <= {M_BITS{1'b0}};
        st      <= S_IDLE;
        busy    <= 1'b0;
        hit     <= 1'b0;
      end else begin
        st <= st_n;

        case (st)
          S_IDLE: begin
            busy <= 1'b0;
            if (start) busy <= 1'b1;
          end

          S_OP: begin
            // Perform the operation in one cycle
            if (op_insert) begin
              bf_bits <= bf_bits | mask;         // set bits
              hit     <= 1'b0;                   // not used for insert
            end else begin
              // Query
              hit     <= must_be_all_set;        // 1 if all k bits set
            end
          end

          S_DONE: begin
            busy <= 1'b0;
            done <= 1'b1;                        // pulse
          end
        endcase
      end
    end
  end

endmodule
