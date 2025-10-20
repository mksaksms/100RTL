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



module single_rom ( 
  
  
  input logic clk, 
  
  input logic rst_n,
  
  
  input logic rd_en, 
  
  input logic wr_en, 
  
  input logic [7:0 ] addr,
  
  input logic [31:0 ] data_in, 
  
  output logic [31:0 ] data_out
  
  
  
); 
  
  
  logic [31:0 ] mem [0 : 255] ; 
  
  
  always_ff @(posedge clk or negedge rst_n) begin 
    
    
    
    if(!rst_n) begin 
      
      for (int  i = 0 ; i < 256 ; i++) begin 
        
        mem [ i] <= 32'h0; 
        
        
      end 
      
      data_out <= 0 ; 
    end 
    else begin
      if(rd_en) begin 
        data_out <= mem [addr]; 
      end 
      if(wr_en) begin 
        mem [addr] <= data_in ; 
        
      end
      
    end
    
  end 
  
  
 
endmodule
  
  


    
    

