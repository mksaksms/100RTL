module mux_2to1 (
                 
                 input logic in0,
  				input logic in1, 
  				input logic sel,
  				output logic out
                 
                 
                );
  
  	assign out = sel == 1'b1 ? in1 : in0 ; 
  
endmodule