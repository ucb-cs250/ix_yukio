module data_io_block
  #(
    parameter W = 6, // W must be multiple of WW
    parameter WW = 3,
    parameter EXTDATAIN = 2,
    parameter EXTDATAOUT = 3
    )
   (
    inout [W-1:0] 			 data,
    input [WW*EXTDATAIN-1:0] 		 external_input,
    output [WW*EXTDATAOUT-1:0] 		 external_output,
    input [W*(EXTDATAIN+EXTDATAOUT)-1:0] c
    );
   
   genvar 				 i, j;
   generate
      for(i = 0; i < EXTDATAIN; i = i + 1) begin
	 for(j = 0; j < W; j = j + 1) begin
	    transmission_gate s(data[j], external_input[j%WW+i*WW], c[j+i*W]);
	 end
      end
      
      for(i = 0; i < EXTDATAOUT; i = i + 1) begin
	 for(j = 0; j < W; j = j + 1) begin
	    transmission_gate s(data[j], external_output[j%WW+i*WW], c[j+i*W+EXTDATAIN*W]);
	 end
      end
   endgenerate
   
endmodule
