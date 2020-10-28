module vertical_disjoint_switch_box 
  #(
    parameter W = 8
    ) 
   (
    inout [W-1:0] north, south,
    input [W-1:0] c
    );
   
   genvar 	  i;
   generate
      for(i = 0; i < W; i = i + 1) begin : switches
	 transmission_gate s(north[i], south[i], c[i]);
      end
   endgenerate
   
endmodule
