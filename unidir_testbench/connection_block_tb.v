module connection_block_tb;
   localparam WS = 7;
   localparam WD = 6;
   localparam WG = 3;
   localparam CLBIN = 6;
   localparam CLBIN0 = 2;
   localparam CLBIN1 = 2;
   localparam CLBOUT = 2;
   localparam CLBOUT0 = 2;
   localparam CLBOUT1 = 2;
   localparam CARRY = 1;
   localparam CLBOS = 2;
   localparam CLBOS_BIAS = 1;
   localparam CLBOD = 2;
   localparam CLBOD_BIAS = 1;
   localparam CLBX = 1;
   
   reg 				     clk = 0;
   always #10 clk = ~clk;

   reg 				     rst, cset;

   localparam SEL_PER_OUT = $clog2(CLBOUT0+CLBOUT1+1);
   localparam SEL_PER_IN0 = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT1);
   localparam SEL_PER_IN1 = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT0);

   reg [WS-1:0] 		     single0_in, single1_in;
   wire [WS-1:0] 		     single0_out, single1_out;
   reg [WD-1:0] 		     double0_in, double1_in;
   wire [WD-1:0] 		     double0_out, double1_out;
   reg [WG-1:0] 		     global;
   reg [CLBOUT-1:0] 		     clb0_output;
   reg [CLBOUT-1:0] 		     clb1_output;
   reg [CARRY-1:0] 		     clb0_cout;
   reg [CARRY-1:0] 		     clb1_cout;
   wire [CLBIN-1:0] 		     clb0_input;
   wire [CLBIN-1:0] 		     clb1_input;
   wire [CARRY-1:0] 		     clb0_cin;
   wire [CARRY-1:0] 		     clb1_cin;
   reg [SEL_PER_OUT*2*(CLBOS+CLBOD)
	+SEL_PER_IN0*CLBIN0
	+SEL_PER_IN1*CLBOUT1
	-1:0] 			     c;
   
   connection_block 
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIN0),
       .CLBIN1(CLBIN1),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBOUT0),
       .CLBOUT1(CLBOUT1),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(CLBOS_BIAS),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(CLBOD_BIAS),
       .CLBX(CLBX)
       )
   dut
     (
      .clk(clk),
      .rst(rst),
      .cset(cset),
      .single0_in(single0_in),
      .single1_in(single1_in),
      .double0_in(double0_in),
      .double1_in(double1_in),
      .single0_out(single0_out),
      .single1_out(single1_out),
      .double0_out(double0_out),
      .double1_out(double1_out),
      .global(global),
      .clb0_output(clb0_output),
      .clb1_output(clb1_output),
      .clb0_cout(clb0_cout),
      .clb1_cout(clb1_cout),
      .clb0_input(clb0_input),
      .clb1_input(clb1_input),
      .clb0_cin(clb0_cin),
      .clb1_cin(clb1_cin),
      .c(c)
      );
   
   integer   count = 0;
   always @(posedge clk) begin
      #1;
      if(clb0_cout != clb1_cin) count = count + 1;
      if(clb1_cout != clb0_cin) count = count + 1;
   end

   localparam IN0_CAND = (WS+WD)*2+WG+CLBX*CLBOUT1;
   localparam IN1_CAND = (WS+WD)*2+WG+CLBX*CLBOUT0;
   localparam OUT_CAND = CLBOUT0+CLBOUT1;

   wire [IN0_CAND-1:0] clb0_input_candidate = {clb1_output[CLBOUT1-1:0], global, double0_out, double1_out, single0_out, single1_out};
   wire [IN1_CAND-1:0] clb1_input_candidate = {clb0_output[CLBOUT0-1:0], global, double0_out, double1_out, single0_out, single1_out};
   wire [OUT_CAND-1:0] clb_output_candidate = {clb1_output[CLBOUT1-1:0], clb0_output[CLBOUT0-1:0]};
   
   integer   i, j, k, j_tmp, BASE, t;
   initial begin
      rst = 0;
      cset = 1;
      single0_in = $random;
      single1_in = $random;
      double0_in = $random;
      double1_in = $random;
      global = $random;
      clb0_output = $random;
      clb1_output = $random;
      clb0_cout = $random;
      clb1_cout = $random;
      for(j = 0; j < SEL_PER_OUT*2*(CLBOS+CLBOD)+SEL_PER_IN0*CLBIN0+SEL_PER_IN1*CLBOUT1; j = j + 1) begin
	 c[j] = 0;
      end
      
      // output default
      @(posedge clk);
      #1;
      if(single1_out != single0_in) count = count + 1;
      if(single0_out != single1_in) count = count + 1;
      if(double1_out != double0_in) count = count + 1;
      if(double0_out != double1_in) count = count + 1;
      
      for(t = 0; t < 100; t = t + 1)  begin
	 single0_in = $random;
	 single1_in = $random;
	 double0_in = $random;
	 double1_in = $random;
	 global = $random;
	 clb0_output = $random;
	 clb1_output = $random;
	 clb0_cout = $random;
	 clb1_cout = $random;

	 // output mux
	 BASE = 0;
	 for(i = 0; i < CLBOS; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % (OUT_CAND + 1);
	    j_tmp = j;
	    for(k = 0; k < SEL_PER_OUT; k = k + 1) begin
	       c[BASE+k] = j_tmp%2;
	       j_tmp = j_tmp/2;
	    end
	    @(negedge clk);
	    if(j == 0 && single1_out[(i+CLBOS_BIAS*CLBOS)%WS] != single0_in[(i+CLBOS_BIAS*CLBOS)%WS]) count = count + 1;
	    if(j != 0 && single1_out[(i+CLBOS_BIAS*CLBOS)%WS] != clb_output_candidate[j-1]) count = count + 1;
	    BASE = BASE + SEL_PER_OUT;
	    j = $urandom % (OUT_CAND + 1);
	    j_tmp = j;
	    for(k = 0; k < SEL_PER_OUT; k = k + 1) begin
	       c[BASE+k] = j_tmp%2;
	       j_tmp = j_tmp/2;
	    end
	    @(negedge clk);
	    if(j == 0 && single0_out[(i+CLBOS_BIAS*CLBOS)%WS] != single1_in[(i+CLBOS_BIAS*CLBOS)%WS]) count = count + 1;
	    if(j != 0 && single0_out[(i+CLBOS_BIAS*CLBOS)%WS] != clb_output_candidate[j-1]) count = count + 1;
	    BASE = BASE + SEL_PER_OUT;
	 end // for (i = 0; i < CLBOS; i = i + 1)
	 for(i = CLBOS; i < WS; i = i + 1) begin
	    if(single1_out[(i+CLBOS_BIAS*CLBOS)%WS] != single0_in[(i+CLBOS_BIAS*CLBOS)%WS]) count = count + 1;
	    if(single0_out[(i+CLBOS_BIAS*CLBOS)%WS] != single1_in[(i+CLBOS_BIAS*CLBOS)%WS]) count = count + 1;
	 end
	 for(i = 0; i < CLBOD; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % (OUT_CAND + 1);
	    j_tmp = j;
	    for(k = 0; k < SEL_PER_OUT; k = k + 1) begin
	       c[BASE+k] = j_tmp%2;
	       j_tmp = j_tmp/2;
	    end
	    @(negedge clk);
	    if(j == 0 && double1_out[(i+CLBOD_BIAS*CLBOD)%(WD/2)] != double0_in[(i+CLBOD_BIAS*CLBOD)%(WD/2)]) count = count + 1;
	    if(j != 0 && double1_out[(i+CLBOD_BIAS*CLBOD)%(WD/2)] != clb_output_candidate[j-1]) count = count + 1;
	    BASE = BASE + SEL_PER_OUT;
	    j = $urandom % (OUT_CAND + 1);
	    j_tmp = j;
	    for(k = 0; k < SEL_PER_OUT; k = k + 1) begin
	       c[BASE+k] = j_tmp%2;
	       j_tmp = j_tmp/2;
	    end
	    @(negedge clk);
	    if(j == 0 && double0_out[(i+CLBOD_BIAS*CLBOD)%(WD/2)] != double1_in[(i+CLBOD_BIAS*CLBOD)%(WD/2)]) count = count + 1;
	    if(j != 0 && double0_out[(i+CLBOD_BIAS*CLBOD)%(WD/2)] != clb_output_candidate[j-1]) count = count + 1;
	    BASE = BASE + SEL_PER_OUT;
	 end // for (i = 0; i < CLBOD; i = i + 1)
	 for(i = CLBOD; i < WD/2; i = i + 1) begin
	    if(double1_out[(i+CLBOD_BIAS*CLBOD)%(WD/2)] != double0_in[(i+CLBOD_BIAS*CLBOD)%(WD/2)]) count = count + 1;	    
	    if(double0_out[(i+CLBOD_BIAS*CLBOD)%(WD/2)] != double1_in[(i+CLBOD_BIAS*CLBOD)%(WD/2)]) count = count + 1;
	 end
	 for(i = WD/2; i < WD; i = i + 1) begin
	    if(double1_out[i] != double0_in[i]) count = count + 1;	    
	    if(double0_out[i] != double1_in[i]) count = count + 1;
	 end
	 
	 // input
	 for(i = 0; i < CLBIN0; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % IN0_CAND;
	    j_tmp = j;
	    for(k = 0; k < SEL_PER_IN0; k = k + 1) begin
	       c[BASE+k] = j_tmp%2;
	       j_tmp = j_tmp/2;
	    end
	    @(negedge clk);
	    if(clb0_input[i] != clb0_input_candidate[j]) count = count + 1;
	    BASE = BASE + SEL_PER_IN0;
	 end // for (i = 0; i < CLBIN0; i = i + 1)
	 for(i = 0; i < CLBIN1; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % IN1_CAND;
	    j_tmp = j;
	    for(k = 0; k < SEL_PER_IN1; k = k + 1) begin
	       c[BASE+k] = j_tmp%2;
	       j_tmp = j_tmp/2;
	    end
	    @(negedge clk);
	    if(clb1_input[i] != clb1_input_candidate[j]) count = count + 1;
	    BASE = BASE + SEL_PER_IN1;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
   
endmodule
