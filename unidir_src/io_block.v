module io_block
  #(
    parameter WS = 6,
    parameter WD = 3,
    parameter WG = 3,
    parameter EXTIN = 3,
    parameter EXTOUT = 3,
    parameter SEL_PER_IN = $clog2(EXTIN),
    parameter SEL_PER_OUT = $clog2(WS+WD)
    )
   (
    input [WS-1:0] 			  single_in,
    input [WD-1:0] 			  double_in,
    output [WS-1:0] 			  single_out,
    output [WD-1:0] 			  double_out,
    output [WG-1:0] 			  global,
    input [EXTIN-1:0] 			  external_input,
    output [EXTOUT-1:0] 		  external_output,
    input [SEL_PER_IN*(WS+WD+WG)+SEL_PER_OUT*EXTOUT-1:0] c
    );

   localparam BASE1 = SEL_PER_IN*WS;
   localparam BASE2 = SEL_PER_IN*(WS+WD);
   localparam BASE3 = SEL_PER_IN*(WS+WD+WG);

   genvar 	       i, j;
   generate
      for(j = 0; j < WS; j = j + 1) begin : single
	 muxn #(.N(EXTIN))
	 m (
	    .out(single_out[j]),
	    .in(external_input),
	    .sel(c[SEL_PER_IN*(j+1)-1:SEL_PER_IN*j])
	    );
      end
      for(j = 0; j < WD; j = j + 1) begin : double
	 muxn #(.N(EXTIN))
	 m (
	    .out(double_out[j]),
	    .in(external_input),
	    .sel(c[BASE1+SEL_PER_IN*(j+1)-1:BASE1+SEL_PER_IN*j])
	    );
      end
      for(j = 0; j < WG; j = j + 1) begin : globals
	 muxn #(.N(EXTIN))
	 m (
	    .out(global[j]),
	    .in(external_input),
	    .sel(c[BASE2+SEL_PER_IN*(j+1)-1:BASE2+SEL_PER_IN*j])
	    );
      end
      
      for(i = 0; i < EXTOUT; i = i + 1) begin
	 muxn #(.N(WS+WD))
	 m (
	    .out(external_output[i]),
	    .in({double_in, single_in}),
	    .sel(c[BASE3+SEL_PER_OUT*(i+1)-1:BASE3+SEL_PER_OUT*i])
	    );
      end
   endgenerate
   
endmodule
