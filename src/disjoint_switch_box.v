module disjoint_switch_box 
  #(
    parameter W = 8
    ) 
   (
    inout [W-1:0]   north, east, south, west,
    input [W*6-1:0] c
    );
   
   genvar 	    i;
   generate
      for(i = 0; i < W; i = i + 1) begin : switches
	 switch_box_element_one elem 
	      (
	       .north(north[i]),
	       .east(east[i]),
	       .south(south[i]),
	       .west(west[i]),
	       .c(c[(i+1)*6-1:i*6])
	       );
      end
   endgenerate
   
endmodule
