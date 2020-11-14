module data_connection_block_tb;
   localparam W = 16;
   localparam WW = 4;
   localparam DATAIN = 4;
   localparam DATAOUT = 3;

   localparam SEL_PER_IN = $clog2(2*W/WW);
   localparam SEL_PER_OUT = $clog2(DATAOUT+1);
   
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] ni, si;
   wire [W-1:0] no, so;
   reg [SEL_PER_IN*DATAIN*WW+SEL_PER_OUT*W*2-1:0] c;
   
   wire [WW*DATAIN-1:0] 	data_input;
   reg [WW*DATAOUT-1:0] 	data_output;
   
   reg 				rst, cset;
   
   data_connection_block
     #(
       .W(W),
       .WW(WW),
       .DATAIN(DATAIN),
       .DATAOUT(DATAOUT)
       )
   dut
     (
      .clk(clk),
      .rst(rst),
      .cset(cset),
      .north_in(ni),
      .south_in(si),
      .north_out(no),
      .south_out(so),
      .data_input(data_input),
      .data_output(data_output),
      .c(c)
      );

   wire [W*2-1:0] 		candidate = {si, ni};
   
   
   integer   count = 0;
   
   integer   i, j, t, k, k_tmp, l, BASE;
   initial begin
      rst = 0;
      cset = 1;
      ni = 0;
      si = 0;
      for(j = 0; j < SEL_PER_IN*DATAIN*WW+SEL_PER_OUT*W*2; j = j + 1) begin
	 c[j] = 0;
      end

      // default
      @(posedge clk);
      @(negedge clk);
      if(no != si) count = count + 1;
      if(so != ni) count = count + 1;
      
      for(t = 0; t < 100; t = t + 1) begin
	 ni = $random;
	 si = $random;
	 data_output = $random;
	 BASE = 0;
	 for(i = 0; i < DATAIN; i = i + 1) begin
	    for(j = 0; j < WW; j = j + 1) begin
	       @(negedge clk);
	       k = $urandom % (2*W/WW);
	       k_tmp = k;
	       for(l = 0; l < SEL_PER_IN; l = l + 1) begin
		  c[l+BASE] = k_tmp%2;
		  k_tmp = k_tmp/2;
	       end
	       @(negedge clk);
	       if(data_input[j+i*WW] != candidate[k*WW+j]) count = count + 1;
	       BASE = BASE + SEL_PER_IN;
	    end
	 end // for (i = 0; i < DATAIN; i = i + 1)

	 for(i = 0; i < W; i = i + 1) begin
	    @(negedge clk);
	    k = $urandom % (DATAOUT+1);
	    k_tmp = k;
	    for(l = 0; l < SEL_PER_OUT; l = l + 1) begin
	       c[l+BASE] = k_tmp%2;
	       k_tmp = k_tmp/2;
	    end
	    @(negedge clk);
	    if(k == 0 && no[i] != si[i]) count = count + 1;
	    if(k != 0 && no[i] != data_output[i%WW+(k-1)*WW]) count = count + 1;
	    BASE = BASE + SEL_PER_OUT;
	 end // for (i = 0; i < W; i = i + 1)
	 for(i = 0; i < W; i = i + 1) begin
	    @(negedge clk);
	    k = $urandom % (DATAOUT+1);
	    k_tmp = k;
	    for(l = 0; l < SEL_PER_OUT; l = l + 1) begin
	       c[l+BASE] = k_tmp%2;
	       k_tmp = k_tmp/2;
	    end
	    @(negedge clk);
	    if(k == 0 && so[i] != ni[i]) count = count + 1;
	    if(k != 0 && so[i] != data_output[i%WW+(k-1)*WW]) count = count + 1;
	    BASE = BASE + SEL_PER_OUT;
	 end // for (i = 0; i < W; i = i + 1)
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
   
endmodule
