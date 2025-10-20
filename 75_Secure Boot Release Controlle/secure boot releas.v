module secure_boot_ctrl #(
  parameter integer TIMEOUT_CYCLES = 32'h00FF_FFFF
)(
  input  wire clk,
  input  wire rst_n,
  input  wire start_verify,   // begin crypto verify
  input  wire verify_done,    // crypto core finished
  input  wire sig_valid,      // signature valid
  input  wire tamper,         // sensor/tamper
  output reg  cpu_rst_n,      // release CPU when 1
  output reg  locked          // permanent lock until cold reset
);
  reg [31:0] ctr;
  typedef enum logic [1:0] {S_IDLE,S_WAIT,S_PASS,S_LOCK} st_t;
  st_t st, st_n;

  always @(*) begin
    st_n = st;
    case (st)
      S_IDLE: if (start_verify) st_n = S_WAIT;
      S_WAIT: if (tamper) st_n = S_LOCK;
              else if (verify_done && sig_valid) st_n = S_PASS;
              else if (ctr == TIMEOUT_CYCLES)    st_n = S_LOCK;
      S_PASS: st_n = S_PASS;
      S_LOCK: st_n = S_LOCK;
      default: st_n = S_LOCK;
    endcase
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st <= S_IDLE; ctr <= 32'd0; cpu_rst_n <= 1'b0; locked <= 1'b0;
    end else begin
      st <= st_n;
      case (st)
        S_IDLE: begin ctr <= 32'd0; cpu_rst_n <= 1'b0; end
        S_WAIT: begin ctr <= ctr + 1'b1; cpu_rst_n <= 1'b0; end
        S_PASS: begin cpu_rst_n <= 1'b1; end
        S_LOCK: begin locked <= 1'b1; cpu_rst_n <= 1'b0; end
      endcase
    end
  end
endmodule
