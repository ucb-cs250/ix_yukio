module control_connection_block_tb;
   localparam W = 7;
   localparam CONTROLIN = 3;

   localparam SEL_PER_IN = $clog2(W+W);
   
   reg clk = 0;
   always #10 clk = ~clk;

   reg rst, cset;
   
   reg [W-1:0] ei, wi;
   wire [W-1:0] eo, wo;
   reg [SEL_PER_IN*CONTROLIN-1:0] c;
   
   wire [CONTROLIN-1:0]  control_input;
   
   control_connection_block 
     #(
       .W(W),
       .CONTROLIN(CONTROLIN)
       )
   dut
     (
      .clk(clk),
      .rst(rst),
      .cset(cset),
      .east_in(ei),
      .west_in(wi),
      .east_out(eo),
      .west_out(wo),
      .control_input(control_input),
      .c(c)
      );
   
   integer   count = 0;
   always @(posedge clk) begin
      #1;
      if(eo != wi) count = count + 1;
      if(wo != ei) count = count + 1;
   end

   wire [W*2-1:0] candidate = {wi, ei};
   
   integer   i, j, j_tmp, t, k, BASE;
   initial begin
      rst = 0;
      cset = 1;
      ei = 0;
      wi = 0;
      for(j = 0; j < SEL_PER_IN*CONTROLIN; j = j + 1) begin
	 c[j] = 0;
      end
      
      for(t = 0; t < 100; t = t + 1) begin
	 ei = $random;
	 wi = $random;
	 BASE = 0;
	 for(i = 0; i < CONTROLIN; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % (W*2);
	    j_tmp = j;
	    for(k = 0; k < SEL_PER_IN; k = k + 1) begin
	       c[k+BASE] = j_tmp%2;
	       j_tmp = j_tmp/2;
	    end
	    @(posedge clk);
	    #1;
	    if(control_input[i] !== candidate[j]) count = count + 1;
	    BASE = BASE + SEL_PER_IN;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
   
endmodule
