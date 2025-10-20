module fibonacci_gen #(
  parameter int N = 8              // width of each Fibonacci number
)(
  input  logic clk,
  input  logic rst_n,
  input  logic start,              // pulse to begin sequence
  output logic [N-1:0] fib_out,    // current Fibonacci number
  output logic done                // pulses each time fib_out updates
);

  logic [N-1:0] a, b;              // previous two Fibonacci numbers
  logic working;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      a       <= '0;
      b       <= '0;
      fib_out <= '0;
      done    <= 1'b0;
      working <= 1'b0;
    end else begin
      done <= 1'b0;                // default low

      if (start) begin
        a <= 0 ; 
	b <= 1; 
	fib_out <= 0;
        working <= 1'b1;
      end
      else if (working) begin
        fib_out <= a;              // output current Fibonacci number

        a <= b;
        b <= a + b;                // next = a + b
        done <= 1'b1;              // indicate valid output each cycle
      end
    end
  end
endmodule