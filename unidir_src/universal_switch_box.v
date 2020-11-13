module universal_switch_box 
  #(
    // the number of pairs of in and out wires each side
    parameter W = 8
    ) 
   (
    input [W-1:0]   north_in, east_in, south_in, west_in,
    output [W-1:0]   north_out, east_out, south_out, west_out,
    input [W*8-1:0] c
    );
   
   genvar 	    i;
   generate
      for(i = 0; i < W / 2; i = i + 1) begin : switch_box_element_two
	 switch_box_element_two elem
	      (
	       .north_in(north_in[i*2+1:i*2]),
	       .east_in(east_in[i*2+1:i*2]),
	       .south_in(south_in[i*2+1:i*2]),
	       .west_in(west_in[i*2+1:i*2]),
	       .north_out(north_out[i*2+1:i*2]),
	       .east_out(east_out[i*2+1:i*2]),
	       .south_out(south_out[i*2+1:i*2]),
	       .west_out(west_out[i*2+1:i*2]),
	       .c(c[16*(i+1)-1:16*i])
	       );
      end
      if(W%2 == 1) begin : switch_box_element_one
	 switch_box_element_one elem 
	   (
	    .north_in(north_in[W-1]),
	    .east_in(east_in[W-1]),
	    .south_in(south_in[W-1]),
	    .west_in(west_in[W-1]),
	    .north_out(north_out[W-1]),
	    .east_out(east_out[W-1]),
	    .south_out(south_out[W-1]),
	    .west_out(west_out[W-1]),
	    .c(c[W*8-1:(W-1)*8])
	    );
      end
   endgenerate
   
endmodule
