module priority_encoder_8to3 #(parameter int WIDTH = 8) 
  
  
  ( 
    
    input logic en, 
    input logic [ WIDTH  - 1 : 0 ]	in  , 
   	output logic [ 2 : 0 ]	out  
  
  ) ; 
  
  
  always_comb 
    
    
    begin 
		if (en) begin
            casez (in)
                8'b1??????? : out = 3'b111;
                8'b01?????? : out = 3'b110;
                8'b001????? : out = 3'b101;
                8'b0001???? : out = 3'b100;
                8'b00001??? : out = 3'b011;
                8'b000001?? : out = 3'b010;
                8'b0000001? : out = 3'b001;
                8'b00000001 : out = 3'b000;
                default     : out = 3'b000;
            endcase


		casez(in) begin 

		8'b1???????: out = 3'b111;

		endcase
        end
      
    end 
	
	
	
	
	
	// This is one way 
	
	// another way is to use if 
	
	
	always_comb begin
        out = 3'b000;  // default
        if (en) begin
            if (in[7])      out = 3'b111;
            else if (in[6]) out = 3'b110;
            else if (in[5]) out = 3'b101;
            else if (in[4]) out = 3'b100;
            else if (in[3]) out = 3'b011;
            else if (in[2]) out = 3'b010;
            else if (in[1]) out = 3'b001;
            else if (in[0]) out = 3'b000;
        end
    end
	
	
	
	
endmodule 