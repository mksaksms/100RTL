module cla_adder_4bit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);

    logic [3:0] g, p;
    logic [4:0] c;


    assign g = a & b;
    assign p = a ^ b;
    assign c[0] = cin;

    // Loop to compute carry
    always_comb begin
        for (int i = 0; i < 4; i++) begin
            c[i+1] = g[i] | (p[i] & c[i]);
        end
    end

    assign sum  = p ^ c[3:0];
    assign cout = c[4];



assign sum = p [3 : 0 ] ^ c[3 :0 ] ; // as c is greater 

assign cout = c[4] ; 
endmodule


