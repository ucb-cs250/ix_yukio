module control_connection_block
  #(
    parameter W = 8,
    parameter CONTROLIN = 6
    ) 
   (
    inout [W-1:0] 	    east, west,
    output [CONTROLIN-1:0]  control_input,
    input [W*CONTROLIN-1:0] c
    );
   
   genvar 		    i, j;
   
   generate
      for(i = 0; i < W; i = i + 1) begin : wires
	 tran(east[i], west[i]);
      end
      
      for(i = 0; i < CONTROLIN; i = i + 1) begin
	 for(j = 0; j < W; j = j + 1) begin : switches
	    transmission_gate s(control_input[i], east[j], c[j+i*W]);
	 end
      end
   endgenerate
   
endmodule
