module io_block
  #(
    parameter WS = 6,
    parameter WD = 3,
    parameter WG = 3,
    parameter EXTIN = 3,
    parameter EXTOUT = 3
    )
   (
    inout [WS-1:0]     single,
    inout [WD-1:0]     double,
    inout [WG-1:0]     global,
    input [EXTIN-1:0]  external_input,
    output [EXTOUT-1:0] external_output,
    input [(EXTIN+EXTOUT)*(WS+WD+WG)-1:0] c
    );

   genvar 	       i, j;
   generate
      for(i = 0; i < EXTIN; i = i + 1) begin
	 for(j = 0; j < WS; j = j + 1) begin
	    transmission_gate s(single[j], external_input[i], c[j+i*(WS+WD+WG)]);
	 end
	 for(j = 0; j < WD; j = j + 1) begin
	    transmission_gate s(double[j], external_input[i], c[WS+j+i*(WS+WD+WG)]);
	 end
	 for(j = 0; j < WG; j = j + 1) begin
	    transmission_gate s(global[j], external_input[i], c[WS+WD+j+i*(WS+WD+WG)]);
	 end
      end
      
      for(i = 0; i < EXTOUT; i = i + 1) begin
	 for(j = 0; j < WS; j = j + 1) begin
	    transmission_gate s(single[j], external_output[i], c[j+i*(WS+WD+WG)+EXTIN*(WS+WD+WG)]);
	 end
	 for(j = 0; j < WD; j = j + 1) begin
	    transmission_gate s(double[j], external_output[i], c[WS+j+i*(WS+WD+WG)+EXTIN*(WS+WD+WG)]);
	 end
	 for(j = 0; j < WG; j = j + 1) begin
	    transmission_gate s(global[j], external_output[i], c[WS+WD+j+i*(WS+WD+WG)+EXTIN*(WS+WD+WG)]);
	 end
      end
   endgenerate
   
   
endmodule
