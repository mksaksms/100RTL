// ================================================================
// GCD by iterative subtraction (Euclid's algorithm)
// - Loads A,B on start
// - Repeats: if x>y x-=y else y-=x
// - Stops when either becomes 0; the other is the GCD
// ------------------------------------------------
// Notes:
// * Works for unsigned values
// * Handles zeros: gcd(0,b)=b, gcd(a,0)=a
// ================================================================
module gcd_basic #(
  parameter integer WIDTH = 32
)(
  input  wire                 clk,
  input  wire                 rst_n,     // active-low reset
  input  wire                 start,     // pulse to begin
  input  wire [WIDTH-1:0]     A,
  input  wire [WIDTH-1:0]     B,
  output reg                  busy,
  output reg                  done,      // 1-cycle pulse
  output reg  [WIDTH-1:0]     gcd
);

  typedef enum logic [1:0] {S_IDLE, S_RUN, S_DONE} st_e;
  st_e st;

  reg [WIDTH-1:0] x, y;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st   <= S_IDLE;
      busy <= 1'b0;
      done <= 1'b0;
      gcd  <= {WIDTH{1'b0}};
      x    <= '0;
      y    <= '0;
    end else begin
      done <= 1'b0;

      case (st)
        S_IDLE: begin
          busy <= 1'b0;
          if (start) begin
            x    <= A;
            y    <= B;
            busy <= 1'b1;
            st   <= S_RUN;
          end
        end

        S_RUN: begin
          // termination checks
          if (x == 0) begin
            gcd <= y;
            st  <= S_DONE;
          end else if (y == 0) begin
            gcd <= x;
            st  <= S_DONE;
          end else begin
            // subtractive step
            if (x > y) x <= x - y;
            else       y <= y - x;
          end
        end

        S_DONE: begin
          busy <= 1'b0;
          done <= 1'b1;
          st   <= S_IDLE;
        end

        default: st <= S_IDLE;
      endcase
    end
  end
endmodule
