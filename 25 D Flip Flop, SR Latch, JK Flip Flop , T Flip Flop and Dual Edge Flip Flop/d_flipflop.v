module D_flipflop (
  
  
  input clk, rst, d, 
  
  output reg Q
  
); 
  
  
  
  always @(posedge clk) begin 
    if(!rst) begin 
      Q <= 0 ; 
    end 
    else begin 
      Q <= d; 
      
    end
    
  end 
  
endmodule 