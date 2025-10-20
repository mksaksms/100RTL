module pwm_generator (
  input  wire       clk,
  input  wire       reset_n,
  input  wire [3:0] duty_cycle,
  output reg        pwm_out
);

  reg [3:0] counter;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      counter <= 4'd0;
      pwm_out <= 1'b0;
    end
    else begin
      counter <= counter + 4'd1;
      // procedural assignment, no "assign", use <= or =
      pwm_out <= (counter < duty_cycle) ? 1'b1 : 1'b0;
      
      
	  
	  
    end
  end

endmodule