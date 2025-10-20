module clock_gating_glitch_free (
  input wire clk, 
  
  input wire enable, 
  
  output wire gated_clk
  
) ; 
  
  
  
  reg enable_latch; 
  
   // A level‑sensitive latch for enable
  //   - transparent when clk=0, captures enable
  //   - holds when clk=1
  always @(clk or enable) 
    
    begin 
      
      if(!clk) begin 
        enable_latch <= enable;
      end
        
    end
  // AND the latched enable with the clock
  // gated_clk only toggles when enable_latch=1
  assign gated_clk = enable_latch & clk ; 
  
endmodule
