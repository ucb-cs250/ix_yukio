module connection_block
  #(
    parameter WS = 8,
    parameter WD= 8, // WD must be multiple of 2
    parameter WG = 3,
    parameter CLBIN = 6,
    parameter CLBIN0 = 6,
    parameter CLBIN1 = 6,
    parameter CLBOUT = 1,
    parameter CLBOUT0 = 1,
    parameter CLBOUT1 = 1,
    parameter CARRY = 1,
    parameter CLBOS = 2,
    parameter CLBOS_BIAS = 0, // incremented every block
    parameter CLBOD = 2,
    parameter CLBOD_BIAS = 0, // incremented every two blocks
    parameter CLBX = 1, // toggle using direct connections between CLBs or not
    parameter SEL_PER_IN0 = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT1),
    parameter SEL_PER_IN1 = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT0),
    parameter SEL_PER_OUT = $clog2(CLBOUT0+CLBOUT1+1),
    parameter CONF_WIDTH = SEL_PER_OUT*2*(CLBOS+CLBOD)+SEL_PER_IN0*CLBIN0+SEL_PER_IN1*CLBIN1
    ) 
   (
    input 		   clk,
    input 		   rst,
    input 		   cset,
    
    input [WS-1:0] 	    single0_in, single1_in,
    output [WS-1:0] 	    single0_out, single1_out,
    input [WD-1:0] 	    double0_in, double1_in,
    output [WD-1:0] 	    double0_out, double1_out,
    input [WG-1:0] 	    global,
    input [CLBOUT-1:0] 	    clb0_output,
    input [CLBOUT-1:0] 	    clb1_output,
    input [CARRY-1:0] 	    clb0_cout,
    input [CARRY-1:0] 	    clb1_cout,
    output [CLBIN-1:0] 	    clb0_input,
    output [CLBIN-1:0] 	    clb1_input,
    output [CARRY-1:0] 	    clb0_cin,
    output [CARRY-1:0] 	    clb1_cin,
    input [CONF_WIDTH -1:0] c
    );

   wire [WS-1:0] 	       single0, single1;
   wire [WD-1:0] 	       double0, double1;

   reg [CONF_WIDTH-1:0]        c_reg;
   always @(posedge clk) begin
      if (rst)
	c_reg <= {CONF_WIDTH{1'b0}};
     else if (cset)
       c_reg <= c;
   end
   
   genvar 		       i, j;

   // carry
   assign clb1_cin = clb0_cout;
   assign clb0_cin = clb1_cout;
   
   // output mux
   localparam CLBOS_BIAS_WIDTH = (CLBOS_BIAS * CLBOS) % WS;
   localparam CLBOD_BIAS_WIDTH = (CLBOD_BIAS * CLBOD) % (WD/2);
   localparam BASE1 = SEL_PER_OUT*2*CLBOS;
   generate
      if(CLBOUT0+CLBOUT1 == 0) begin
	 for(i = 0; i < WS; i = i + 1) begin : single_in
	    assign single0[i] = single0_in[i];
	    assign single1[i] = single1_in[i];
	 end
	 for(i = 0; i < WD; i = i + 1) begin : double_in
	    assign double0[i] = double0_in[i];
	    assign double1[i] = double1_in[i];
	 end
      end // if (CLBOUT0+CLBOUT1 == 0)
      else begin
	 wire [CLBOUT0+CLBOUT1-1:0] clb_output;
	 if(CLBOUT0 != 0) assign clb_output[CLBOUT0-1:0] = clb0_output[CLBOUT0-1:0];
	 if(CLBOUT1 != 0) assign clb_output[CLBOUT0+CLBOUT1-1:CLBOUT0] = clb1_output[CLBOUT1-1:0];
	 
	 for(i = 0; i < CLBOS; i = i + 1) begin : clb_output_single0
	    muxn #(.N(CLBOUT0+CLBOUT1+1))
	    m0 (
	       .out(single0[(i+CLBOS_BIAS_WIDTH)%WS]),
	       .in({clb_output, single0_in[(i+CLBOS_BIAS_WIDTH)%WS]}),
	       .sel(c_reg[SEL_PER_OUT*(i+1)-1:SEL_PER_OUT*i])
	    );
	 end
	 for(i = 0; i < CLBOS; i = i + 1) begin : clb_output_single1
	    muxn #(.N(CLBOUT0+CLBOUT1+1))
	    m1 (
	       .out(single1[(i+CLBOS_BIAS_WIDTH)%WS]),
	       .in({clb_output, single1_in[(i+CLBOS_BIAS_WIDTH)%WS]}),
	       .sel(c_reg[SEL_PER_OUT*CLBOS+SEL_PER_OUT*(i+1)-1:SEL_PER_OUT*CLBOS+SEL_PER_OUT*i])
	    );
	 end
	 for(i = CLBOS; i < WS; i = i + 1) begin
	    assign single0[(i+CLBOS_BIAS_WIDTH)%WS] = single0_in[(i+CLBOS_BIAS_WIDTH)%WS];
	    assign single1[(i+CLBOS_BIAS_WIDTH)%WS] = single1_in[(i+CLBOS_BIAS_WIDTH)%WS];
	 end
	 
	 for(i = 0; i < CLBOD; i = i + 1) begin : clb_output_double0
	    muxn #(.N(CLBOUT0+CLBOUT1+1))
	    m0 (
		.out(double0[(i+CLBOD_BIAS_WIDTH)%(WD/2)]),
		.in({clb_output, double0_in[(i+CLBOD_BIAS_WIDTH)%(WD/2)]}),
		.sel(c_reg[BASE1+SEL_PER_OUT*(i+1)-1:BASE1+SEL_PER_OUT*i])
		);
	 end
	 for(i = 0; i < CLBOD; i = i + 1) begin : clb_output_double1
	    muxn #(.N(CLBOUT0+CLBOUT1+1))
	    m1 (
		.out(double1[(i+CLBOD_BIAS_WIDTH)%(WD/2)]),
		.in({clb_output, double1_in[(i+CLBOD_BIAS_WIDTH)%(WD/2)]}),
		.sel(c_reg[BASE1+SEL_PER_OUT*CLBOD+SEL_PER_OUT*(i+1)-1:BASE1+SEL_PER_OUT*CLBOD+SEL_PER_OUT*i])
		);
	 end
	 for(i = CLBOD; i < WD/2; i = i + 1) begin
	    assign double0[(i+CLBOD_BIAS_WIDTH)%(WD/2)] = double0_in[(i+CLBOD_BIAS_WIDTH)%(WD/2)];
	    assign double1[(i+CLBOD_BIAS_WIDTH)%(WD/2)] = double1_in[(i+CLBOD_BIAS_WIDTH)%(WD/2)];
	 end
	 for(i = WD/2; i < WD; i = i + 1) begin : double_in
	    assign double0[i] = double0_in[i];
	    assign double1[i] = double1_in[i];
	 end
      end // else: !if(CLBOUT0+CLBOUT1 == 0)
      for(i = 0; i < WS; i = i + 1) begin : single_out
	 assign single0_out[i] = single1[i];
	 assign single1_out[i] = single0[i];
      end
      for(i = 0; i < WD; i = i + 1) begin : double_out
	 assign double0_out[i] = double1[i];
	 assign double1_out[i] = double0[i];
      end
   endgenerate

   // input mux
   localparam BASE2 = SEL_PER_OUT*2*(CLBOS+CLBOD);
   generate
      if(CLBX && CLBOUT1 != 0) begin
	 for(i = 0; i < CLBIN0; i = i + 1) begin : clb0_inputs
	    muxn #(.N((WS+WD)*2+WG+CLBOUT1))
	    m
		 (
		  .out(clb0_input[i]),
		  .in({clb1_output[CLBOUT1-1:0], global, double1, double0, single1, single0}),
		  .sel(c_reg[BASE2+SEL_PER_IN0*(i+1)-1:BASE2+SEL_PER_IN0*i])
		  );
	 end
      end // if (CLBX && CLBOUT1 != 0)
      else begin
	 for(i = 0; i < CLBIN0; i = i + 1) begin : clb0_inputs
	    muxn #(.N((WS+WD)*2+WG))
	    m
		 (
		  .out(clb0_input[i]),
		  .in({global, double1, double0, single1, single0}),
		  .sel(c_reg[BASE2+SEL_PER_IN0*(i+1)-1:BASE2+SEL_PER_IN0*i])
		  );
	 end
      end
   endgenerate
   
   localparam BASE3 = BASE2+SEL_PER_IN0*CLBIN0;
   generate
      if(CLBX && CLBOUT0 != 0) begin
	 for(i = 0; i < CLBIN1; i = i + 1) begin : clb1_inputs
	    muxn #(.N((WS+WD)*2+WG+CLBOUT0))
	    m
		 (
		  .out(clb1_input[i]),
		  .in({clb0_output[CLBOUT0-1:0], global, double1, double0, single1, single0}),
		  .sel(c_reg[BASE3+SEL_PER_IN1*(i+1)-1:BASE3+SEL_PER_IN1*i])
		  );
	 end
      end // if (CLBX && CLBOUT0 != 0)
      else begin
	 for(i = 0; i < CLBIN1; i = i + 1) begin : clb1_inputs
	    muxn #(.N((WS+WD)*2+WG))
	    m
		 (
		  .out(clb1_input[i]),
		  .in({global, double1, double0, single1, single0}),
		  .sel(c_reg[BASE3+SEL_PER_IN1*(i+1)-1:BASE3+SEL_PER_IN1*i])
		  );
	 end
      end
   endgenerate
   
endmodule
