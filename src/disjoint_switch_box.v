module disjoint_switch_box 
  #(
    // The number of fabric wires out each side.
    parameter W = 8,
    // There are 6 switches in each of the switch_box_element_ones.
    parameter CONF_WIDTH = 6*W
    ) 
   (
    input clk,
    input rst,
    input cset,
    input [CONF_WIDTH-1:0] c,

    inout [W-1:0]   north, east, south, west,
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
	       .north(north[i]),
	       .east(east[i]),
	       .south(south[i]),
	       .west(west[i]),
	       .c(c_reg[(i+1)*6-1:i*6])
	       );
      end
   endgenerate
   
endmodule
