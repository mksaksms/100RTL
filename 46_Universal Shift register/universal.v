module universal_shift_register #(
  parameter WIDTH = 8
)(
  input  logic             clk,
  input  logic             rst_n,
  input  logic [1:0]       mode,     // 00=Hold, 01=Shift Left, 10=Shift Right, 11=Parallel Load
  input  logic             serial_in,
  input  logic [WIDTH-1:0] data_in,
  output logic [WIDTH-1:0] data_out
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      data_out <= '0;
    else begin
     case (mode) 
	
     2'b00 : data_out <= data_out; 
     2'b01 : data_out <= {data_out[WIDTH -2 : 0 ], serial_in }; // Left shift 
     2'b10 : data_out <= { serial_in , data_out[WIDTH -1 : 1 ], }; // Right shift  10001111
     2'b11 : data_out <= data_in; 

     endcase
    end
  end

endmodule
