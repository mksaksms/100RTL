module gcd_binary #(
  parameter integer WIDTH = 32
)(
  input  wire             clk,
  input  wire             rst_n,
  input  wire             start,
  input  wire [WIDTH-1:0] A,
  input  wire [WIDTH-1:0] B,
  output reg              busy,
  output reg              done,
  output reg  [WIDTH-1:0] gcd
);
  typedef enum logic [1:0] {S_IDLE, S_INIT, S_RUN, S_DONE} st_e;
  st_e st;

  reg [WIDTH-1:0] u, v;
  reg [$clog2(WIDTH+1)-1:0] k; // common factor of 2

  function [WIDTH-1:0] rshift_1(input [WIDTH-1:0] x);
    rshift_1 = x >> 1;
  endfunction

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      st<=S_IDLE; busy<=1'b0; done<=1'b0; gcd<='0; u<='0; v<='0; k<='0;
    end else begin
      done <= 1'b0;
      case (st)
        S_IDLE: begin
          busy <= 1'b0;
          if (start) begin
            u <= A; v <= B; k <= '0; busy <= 1'b1; st <= S_INIT;
          end
        end

        S_INIT: begin
          if (u == 0) begin gcd <= v; st <= S_DONE; end
          else if (v == 0) begin gcd <= u; st <= S_DONE; end
          else if (~u[0] && ~v[0]) begin u<=u>>1; v<=v>>1; k<=k+1'b1; end
          else if (~u[0]) u <= u>>1;
          else if (~v[0]) v <= v>>1;
          else st <= S_RUN;
        end

        S_RUN: begin
          if (u == v) begin
            gcd <= u << k; st <= S_DONE;
          end else begin
            if (u > v) u <= (u - v);
            else       v <= (v - u);
            st <= S_INIT; // normalize by removing powers of two
          end
        end

        S_DONE: begin
          busy <= 1'b0; done <= 1'b1; st <= S_IDLE;
        end
      endcase
    end
  end
endmodule
