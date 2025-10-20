module T_flipflop (
  
  
  input clk, rst, t,  
  
  output reg Q
  
); 
  
  
  
  always @(posedge clk) begin 
    if(!rst) begin 
      Q <= 0 ; 
    end 
    else begin 
      if(t) 
      	Q < = ~Q; 
      else 
        Q <= Q; 
        end
    end
    
  end 
  
endmodule