
// Works for small prime number  (for example 2–255)

module prime_checker (
  input  logic        clk,      // clock
  input  logic        rst_n,    // active-low reset
  input  logic        start,    // start pulse
  input  logic [7:0]  number,   // number to check
  output logic        done,     // goes high when result ready
  output logic        is_prime  // 1 = prime, 0 = not prime
);

  // internal registers
  logic [7:0] n;        // copy of the number
  logic [7:0] d;        // current divisor

  // simple state flags
  logic working;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      n        <= 0;
      d        <= 0;
      is_prime <= 0;
      done     <= 0;
      working  <= 0;
    end else begin
      if (start) begin
        // initialize when start signal comes
        n        <= number;
        d        <= 2;
        done     <= 0;
        working  <= 1;
        is_prime <= 1; // assume prime until proven otherwise
      end else if (working) begin
        // check simple cases
        if (n < 2) begin
          is_prime <= 0;
          done     <= 1;
          working  <= 0;
        end
        // if divisor squared greater than n, we are done
        else if (d * d > n) begin
          done     <= 1;
          working  <= 0;
        end
        // if divisible, not prime
        else if (n % d == 0) begin
          is_prime <= 0;
          done     <= 1;
          working  <= 0;
        end
        // otherwise keep checking next divisor
        else begin
          d <= d + 1;
        end
      end
    end
  end

endmodule
