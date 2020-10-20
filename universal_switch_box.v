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
	       .north({north_single[i*2+1], north_single[i*2]}),
	       .east({east_single[i*2+1], east_single[i*2]}),
	       .south({south_single[i*2+1], south_single[i*2]}),
	       .west({west_single[i*2+1], west_single[i*2]}),
	       .c(c[12*(i+1)-1:12*i])
	       );
      end
      if(WS%2) begin : single_switch_box_element_one
	 switch_box_element_one elem 
	   (
	    .north(north_single[WS-1]),
	    .east(east_single[WS-1]),
	    .south(south_single[WS-1]),
	    .west(west_single[WS-1]),
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
	       .north({north_double[i*2+1], north_double[i*2]}),
	       .east({east_double[i*2+1+WD/2], east_double[i*2+WD/2]}),
	       .south({south_double[i*2+1+WD/2], south_double[i*2+WD/2]}),
	       .west({west_double[i*2+1], west_double[i*2]}),
	       .c(c[12*(i+1)-1+BASE:12*i+BASE])
	       );
      end
      if(WD/2%2) begin : double_switch_box_element_one
	 switch_box_element_one elem 
	   (
	    .north(north_double[WD/2-1]),
	    .east(east_double[WD-1]),
	    .south(south_double[WD-1]),
	    .west(west_double[WD/2-1]),
	    .c(c[WD/2*6-1+BASE:(WD/2-1)*6+BASE])
	    );
      end
      
      for(i = 0; i < WG; i = i + 1) begin : global_direct_connection
	 tran(north_global[i], south_global[i]);
	 tran(east_global[i], west_global[i]);
      end
   endgenerate
   
endmodule
