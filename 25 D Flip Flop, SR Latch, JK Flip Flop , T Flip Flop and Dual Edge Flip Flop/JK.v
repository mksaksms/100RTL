
module JK (
  
  
  input clk, rst, J,K   
  
  output reg Q
  
); 
  
  
  
  always @(posedge clk) begin 
    if(!rst) begin 
      Q <= 0 ; 
    end 
    else begin 
      case ( {J,K}) 
        2'b00 : Q<= Q; 
        2'b01 : Q<= 1; // Reset  
        2'b10 : Q<= 0; // Set 
        2'b11 : Q<= ~Q; // Alter 
      endcase
  end 
  
endmodule 