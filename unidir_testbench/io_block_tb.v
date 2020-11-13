module io_block_tb;
   localparam WS = 7;
   localparam WD = 6;
   localparam WG = 3;
   localparam EXTIN = 5;
   localparam EXTOUT = 2;

   localparam SEL_PER_IN = $clog2(EXTIN);
   localparam SEL_PER_OUT = $clog2(WS+WD);
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [EXTIN-1:0] external_input;
   wire [EXTOUT-1:0] external_output;
   
   reg [WS-1:0]      si;
   wire [WS-1:0]     so;
   reg [WD-1:0]      di;
   wire [WD-1:0]     dout;
   wire [WG-1:0]      g;
   
   reg [SEL_PER_IN*(WS+WD+WG)+SEL_PER_OUT*EXTOUT-1:0] c;
   
   io_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .EXTIN(EXTIN),
       .EXTOUT(EXTOUT)
       )
   dut
     (
      .single_in(si),
      .double_in(di),
      .single_out(so),
      .double_out(dout),
      .global(g),
      .external_input(external_input),
      .external_output(external_output),
      .c(c)
      );

   integer   count = 0;

   wire [WS+WD-1:0] candidate = {di, si};

   integer   i, j, BASE, t, k, k_tmp, l;
   initial begin
      for(j = 0; j < SEL_PER_IN*(WS+WD+WG)+SEL_PER_OUT*EXTOUT; j = j + 1) c[j] = 0;
      
      for(t = 0; t < 100; t = t + 1) begin
	 BASE = 0;
	 si = $random;
	 di = $random;
	 external_input = $random;
	 for(j = 0; j < WS; j = j + 1) begin
	    @(negedge clk);
	    k = $urandom % EXTIN;
	    k_tmp = k;
	    for(l = 0; l < SEL_PER_IN; l = l + 1) begin
	       c[l+BASE] = k_tmp%2;
	       k_tmp = k_tmp/2;
	    end
	    @(posedge clk);
	    if(so[j] != external_input[k]) count = count + 1;
	    BASE = BASE + SEL_PER_IN;
	 end // for (j = 0; j < WS; j = j + 1)
	 for(j = 0; j < WD; j = j + 1) begin
	    @(negedge clk);
	    k = $urandom % EXTIN;
	    k_tmp = k;
	    for(l = 0; l < SEL_PER_IN; l = l + 1) begin
	       c[l+BASE] = k_tmp%2;
	       k_tmp = k_tmp/2;
	    end
	    @(posedge clk);
	    if(dout[j] != external_input[k]) count = count + 1;
	    BASE = BASE + SEL_PER_IN;
	 end // for (j = 0; j < WD; j = j + 1)
	 for(j = 0; j < WG; j = j + 1) begin
	    @(negedge clk);
	    k = $urandom % EXTIN;
	    k_tmp = k;
	    for(l = 0; l < SEL_PER_IN; l = l + 1) begin
	       c[l+BASE] = k_tmp%2;
	       k_tmp = k_tmp/2;
	    end
	    @(posedge clk);
	    if(g[j] != external_input[k]) count = count + 1;
	    BASE = BASE + SEL_PER_IN;
	 end // for (j = 0; j < WG; j = j + 1)
	 
	 for(i = 0; i < EXTOUT; i = i + 1) begin
	    @(negedge clk);
	    k = $urandom % (WS+WD);
	    k_tmp = k;
	    for(l = 0; l < SEL_PER_OUT; l = l + 1) begin
	       c[l+BASE] = k_tmp%2;
	       k_tmp = k_tmp/2;
	    end
	    @(posedge clk);
	    if(external_output[i] != candidate[k]) count = count + 1;
	    BASE = BASE + SEL_PER_OUT;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
