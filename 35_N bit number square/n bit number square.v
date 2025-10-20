module nbit_square #(
  parameter int N = 8
)(
  input  logic             clk,
  input  logic             rst_n,
  input  logic             start,        // pulse 1 cycle to start
  input  logic [N-1:0]     data,
  output logic [2*N-1:0]   square_out,
  output logic             done          // pulses 1 cycle when ready
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      square_out <= '0;
      done       <= 1'b0;
    end else begin
      done <= 1'b0;                     // default
      if (start) begin
        square_out <= data * data;      // compute this cycle
        done       <= 1'b1;             // result valid now
      end
    end
  end
endmodule