//N-bit Counter
module P1P6_counter#(parameter n = 4)(input logic UP, input logic CLK, input logic RESET, output logic [n-1:0] out);
    

  always_ff @(posedge CLK) begin

       
    if (RESET)
      out <= 0; //check for reset
    
    else if (UP) //increment counter
      begin
        if (out < 2**n-1)
        out <= out + 1;
          else out <= out; //output if max is reached
      end
    
    else if (~UP) //decrement counter
      begin
        if (out > 0)
      out <= out - 1;
        else out <= out; //output 
      end
  		
  end //always_combs
  
endmodule