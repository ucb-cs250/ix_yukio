module data_connection_block
  #(
    // The number of pairs of in and out fabric wires connecting to the MAC inputs and outputs.
    parameter W = 16, // W must be multiple of WW
    // WW = WORD_WIDTH.
    parameter WW = 8,
    // 8: Four pairs of WW-bits coming in.
    parameter DATAIN = 8,
    // 4: Four big chungus (4*WW) outputs.
    parameter DATAOUT = 16,
    // others
    parameter WN = W / WW,
    parameter SEL_PER_IN = $clog2(WN*2),
    parameter SEL_PER_OUT = $clog2(DATAOUT+1),
    parameter CONF_WIDTH = SEL_PER_IN*DATAIN*WW + SEL_PER_OUT*W*2
    ) 
   (
    input 		   clk,
    input 		   rst,
    input 		   cset,
    input [CONF_WIDTH-1:0] c,
    
    input [W-1:0] 	   north_in, south_in,
    output [W-1:0] 	   north_out, south_out,
    // To MAC block.
    output [WW*DATAIN-1:0] data_input,
    // From MAC block.
    input [WW*DATAOUT-1:0] data_output
    );
   
   reg [CONF_WIDTH-1:0]    c_reg;
   always @(posedge clk) begin
      if (rst)
	c_reg <= {CONF_WIDTH{1'b0}};
      else if (cset)
	c_reg <= c;
   end
      
   localparam BASE = SEL_PER_IN*DATAIN*WW;
   genvar 		       i, j, k;
   generate
      for(i = 0; i < DATAIN; i = i + 1) begin : data_in
	 for(j = 0; j < WW; j = j + 1) begin : bit_in
	    wire [2*WN-1:0] candidates;
	    for(k = 0; k < WN; k = k + 1) begin : mux_in
	       assign candidates[2*k] = north_in[k*WW+j];
	       assign candidates[2*k+1] = south_in[k*WW+j];
	    end
	    muxn #(.N(2*WN))
	    m (
	       .out(data_input[j+i*WW]),
	       .in(candidates),
	       .sel(c_reg[SEL_PER_IN*(j+i*WW+1)-1:SEL_PER_IN*(j+i*WW)])
	       );
	 end
      end

      for(j = 0; j < WW; j = j + 1) begin : data_out
	 wire [DATAOUT-1:0] candidates;
	 for(i = 0; i < DATAOUT; i = i + 1) begin : mux_out
	    assign candidates[i] = data_output[j+i*WW];
	 end
	 for(k = 0; k < WN; k = k + 1) begin : bit_out
	    muxn #(.N(DATAOUT+1))
	    mn (
		.out(north_out[j+k*WW]),
		.in({candidates, south_in[j+k*WW]}),
		.sel(c_reg[BASE+SEL_PER_OUT*(2*j+2*k*WW+1)-1:BASE+SEL_PER_OUT*(2*j+2*k*WW)])
		);
	    
	    muxn #(.N(DATAOUT+1))
	    ms (
		.out(south_out[j+k*WW]),
		.in({candidates, north_in[j+k*WW]}),
		.sel(c_reg[BASE+SEL_PER_OUT*(2*j+1+2*k*WW+1)-1:BASE+SEL_PER_OUT*(2*j+1+2*k*WW)])
		);
	 end
      end
   endgenerate
   
endmodule
