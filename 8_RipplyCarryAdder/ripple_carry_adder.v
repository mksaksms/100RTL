module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);

  assign {cout, sum} = a + b + cin;

endmodule





module ripple_carry_adder #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             carry_in,
    output logic [WIDTH-1:0] sum,
    output logic             carry_out
);




    logic [WIDTH:0] carry;  // carry[0] is carry_in, carry[WIDTH] is carry_out

	
    assign carry[0] = carry_in ; 


    // Generate WIDTH full adders
    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_full_adders
            full_adder fa_inst (
                .a    (in0[i]),
                .b    (in1[i]),
                .cin  (carry[i]),
                .sum  (sum[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate

    assign carry_out = carry[WIDTH];


		
	end

	endgenerate 

endmodule



module ripple_carry_adder # ( parameter int WIDTH = 8 ) 

(
	input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             carry_in,
    output logic [WIDTH-1:0] sum,
    output logic             carry_out
);
	
	
	 logic [WIDTH : 0 ] carry; 
	
	
	assign carry[0] = carry_in ; 
	
	genvar i ; 
	
	generate 
		for(i = 0 ; i < WIDTH ; i++ ) begin 
		
		 ( 
		 
		 .a (in0),  
		 .b( in1), 
		 .cin(carry[i]), 
		 .sum ( sum [i] ), 
		 .cout ( carry_out [i + 1])
		 
		 
		 ) ; 
	endgenerate
	assign carry_out = carry_out [WIDTH] ; 
endmodule


