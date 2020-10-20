module universal_switch_box 
  #(
    parameter WS = 8,
    parameter WD= 8, // WD must be multiple of 2
    parameter WG = 3
    ) 
   (
    inout [WS-1:0] 	    north_single, east_single, south_single, west_single,
    inout [WD-1:0] 	    north_double, east_double, south_double, west_double,
    inout [WG-1:0] 	    north_global, east_global, south_global, west_global,
    input [WS*6+WD/2*6-1:0] c
    );
   
   genvar 		    i;
   generate
      for(i = 0; i < WS / 2; i = i + 1) begin : single_switch_box_element_two
	 switch_box_element_two elem
	      (
	       .north({north_single[WS-1-i], north_single[i]}),
	       .east({east_single[WS-1-i], east_single[i]}),
	       .south({south_single[WS-1-i], south_single[i]}),
	       .west({west_single[WS-1-i], west_single[i]}),
	       .c(c[12*(i+1)-1:12*i])
	       );
      end
      if(WS%2) begin : single_switch_box_element_one
	 switch_box_element_one elem 
	   (
	    .north(north_single[WS/2]),
	    .east(east_single[WS/2]),
	    .south(south_single[WS/2]),
	    .west(west_single[WS/2]),
	    .c(c[WS*6-1:(WS-1)*6])
	    );
      end
      
      localparam BASE = WS*6;
      
      for(i = 0; i < WD / 2; i = i + 1) begin : double_direct_connection
	 tran(north_double[i+WD/2], south_double[i]);
	 tran(east_double[i], west_double[i+WD/2]);
      end
      for(i = 0; i < WD / 4; i = i + 1) begin : double_switch_box_element_two
	 switch_box_element_two elem
	      (
	       .north({north_double[WD/2-1-i], north_double[i]}),
	       .east({east_double[WD-1-i], east_double[i+WD/2]}),
	       .south({south_double[WD-1-i], south_double[i+WD/2]}),
	       .west({west_double[WD/2-1-i], west_double[i]}),
	       .c(c[12*(i+1)-1+BASE:12*i+BASE])
	       );
      end
      if(WD/2%2) begin : double_switch_box_element_one
	 switch_box_element_one elem 
	   (
	    .north(north_double[WD/4]),
	    .east(east_double[WD/2+WD/4]),
	    .south(south_double[WD/2+WD/4]),
	    .west(west_double[WD/4]),
	    .c(c[WD/2*6-1+BASE:(WD/2-1)*6+BASE])
	    );
      end
      
      for(i = 0; i < WG; i = i + 1) begin : global_direct_connection
	 tran(north_global[i], south_global[i]);
	 tran(east_global[i], west_global[i]);
      end
   endgenerate
   
endmodule
