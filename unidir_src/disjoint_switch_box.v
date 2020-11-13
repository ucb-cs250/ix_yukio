module disjoint_switch_box 
  #(
    // The number of pairs of in and out wires each side.
    parameter W = 8,
    // There are 8 switches in each of the switch_box_element_ones.
    parameter CONF_WIDTH = 8*W
    ) 
   (
    input 		   clk,
    input 		   rst,
    input 		   cset,
    input [CONF_WIDTH-1:0] c,

    input [W-1:0] 	   north_in, east_in, south_in, west_in,
    output [W-1:0] 	   north_out, east_out, south_out, west_out
    );

   reg [CONF_WIDTH-1:0] c_reg;
   always @(posedge clk) begin
     if (rst)
       c_reg <= {CONF_WIDTH{1'b0}};
     else if (cset)
       c_reg <= c;
   end
   
   genvar 	    i;
   generate
      for(i = 0; i < W; i = i + 1) begin : switches
	 switch_box_element_one elem 
	      (
	       .north_in(north_in[i]),
	       .east_in(east_in[i]),
	       .south_in(south_in[i]),
	       .west_in(west_in[i]),
	       .north_out(north_out[i]),
	       .east_out(east_out[i]),
	       .south_out(south_out[i]),
	       .west_out(west_out[i]),
	       .c(c_reg[(i+1)*8-1:i*8])
	       );
      end
   endgenerate
   
endmodule
