module binary2gray # ( parameter WIDTH = 16 ) 

( 
input logic [WIDTH - 1 : 0 ] binary, 
output logic [WIDTH - 1 : 0 ] gray

);

always_comb begin 

gray [WIDTH - 1 ] = binary [ WIDTH - 1] ; // MSB same 


for (int i = WIDTH -2 ; i >= 0 ; i -- ) begin 

gray [i] = binary [i + 1 ] ^ binary [i]; 

// The equation for gray to binary is 

// gray = bin ^ (bin << 1)  
end 

end







endmodule


