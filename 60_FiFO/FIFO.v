`timescale 1ns/1ns; 

`include "uvm_macros.svh" 

import uvm_pkg :: * ; 



module tb_top ; 

logic clk, rst_n; 


always #5 clk = ~clk; 

initial begin 

	clk = 0 ;
	
	rst_n = 0 ; 
	
	#20 rst_n = 1; 
	
	
end 

endmodule 