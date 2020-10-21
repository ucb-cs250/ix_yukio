module data_connection_block
  #(
    parameter W = 16, // W must be multiple of WW
    parameter WW = 8,
    parameter DATAIN = 3,
    parameter DATAOUT = 2
    ) 
   (
    inout [W-1:0] 	       north, south,
    output [WW*DATAIN-1:0]     data_input,
    input [WW*DATAOUT-1:0]     data_output,
    input [W*(DATAIN+DATAOUT)-1:0] c
    );
   
   genvar 		       i, j;
   
   generate
      for(i = 0; i < W; i = i + 1) begin : wires
	 tran(north[i], south[i]);
      end
      
      for(i = 0; i < DATAIN; i = i + 1) begin
	 for(j = 0; j < W; j = j + 1) begin : input_switches
	    transmission_gate s(data_input[j%WW+i*WW], north[j], c[j+i*W]);
	 end
      end
      
      for(i = 0; i < DATAOUT; i = i + 1) begin
	 for(j = 0; j < W; j = j + 1) begin : input_switches
	    transmission_gate s(data_output[j%WW+i*WW], north[j], c[j+i*W+DATAIN*W]);
	 end
      end
   endgenerate
   
endmodule
