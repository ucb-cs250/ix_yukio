module control_connection_block
  #(
    parameter W = 8,
    parameter CONTROLIN = 6,
    parameter SEL_PER_IN = $clog2(W*2),
    parameter CONF_WIDTH = SEL_PER_IN*CONTROLIN
    ) 
   (
    input 			     clk,
    input 			     rst,
    input 			     cset,
    input [W-1:0] 		     east_in, west_in,
    output [W-1:0] 		     east_out, west_out,
    output [CONTROLIN-1:0] 	     control_input,
    input [CONF_WIDTH-1:0] c
    );

   reg [CONF_WIDTH-1:0]    c_reg;
   always @(posedge clk) begin
      if (rst)
	c_reg <= {CONF_WIDTH{1'b0}};
      else if (cset)
	c_reg <= c;
   end
   
   assign east_out = west_in;
   assign west_out = east_in;
	 
   genvar 		    i, j;
   generate
      for(i = 0; i < CONTROLIN; i = i + 1) begin : muxs
	 muxn #(.N(W*2))
	 m (
	    .out(control_input[i]),
	    .in({west_in, east_in}),
	    .sel(c_reg[SEL_PER_IN*(i+1)-1:SEL_PER_IN*i])
	    );
      end
   endgenerate
   
endmodule
