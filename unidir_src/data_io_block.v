module data_io_block
  #(
    parameter W = 6, // W must be multiple of WW
    parameter WW = 3,
    parameter EXTDATAIN = 2,
    parameter EXTDATAOUT = 3,
    parameter WN = W / WW,
    parameter SEL_PER_IN = $clog2(EXTDATAIN),
    parameter SEL_PER_OUT = $clog2(WN)
    )
   (
    input [W-1:0] 			 data_in,
    output [W-1:0] 			 data_out,
    input [WW*EXTDATAIN-1:0] 		 external_input,
    output [WW*EXTDATAOUT-1:0] 		 external_output,
    input [SEL_PER_IN*W+SEL_PER_OUT*WW*EXTDATAOUT-1:0] c
    );

   localparam BASE = SEL_PER_IN * W;
   
   genvar 				 i, j, k;
   generate
      for(j = 0; j < WW; j = j + 1) begin
	 wire [EXTDATAIN-1:0] candidate;
	 for(i = 0; i < EXTDATAIN; i = i + 1) begin
	    assign candidate[i] = external_input[WW*i+j];
	 end
	 for(k = 0; k < WN; k = k + 1) begin
	    muxn #(.N(EXTDATAIN))
	    m (
	       .out(data_out[j+k*WW]),
	       .in(candidate),
	       .sel(c[SEL_PER_IN*(j+k*WW+1)-1:SEL_PER_IN*(j+k*WW)])
	       );
	 end
      end // for (j = 0; j < WW; j = j + 1)

      for(j = 0; j < WW; j = j + 1) begin
	 wire [WN-1:0] candidate;
	 for(k = 0; k < WN; k = k + 1) begin
	    assign candidate[k] = data_in[WW*k+j];
	 end
	 for(i = 0; i < EXTDATAOUT; i = i + 1) begin
	    muxn #(.N(WN))
	    m (
	       .out(external_output[j+i*WW]),
	       .in(candidate),
	       .sel(c[BASE+SEL_PER_OUT*(j+i*WW+1)-1:BASE+SEL_PER_OUT*(j+i*WW)])
	       );
	 end
      end // for (j = 0; j < WW; j = j + 1)
   endgenerate
   
endmodule
