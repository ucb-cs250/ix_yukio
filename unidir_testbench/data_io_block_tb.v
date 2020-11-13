module data_io_block_tb;
   localparam W = 12;
   localparam WW = 4;
   localparam EXTDATAIN = 3;
   localparam EXTDATAOUT = 2;

   localparam SEL_PER_IN = $clog2(EXTDATAIN);
   localparam SEL_PER_OUT = $clog2(W/WW);
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [WW*EXTDATAIN-1:0] external_input;
   wire [WW*EXTDATAOUT-1:0] external_output;
   
   reg [W-1:0] 		    data_in;
   wire [W-1:0] 	    data_out;
   reg [SEL_PER_IN*W+SEL_PER_OUT*EXTDATAOUT*WW-1:0] c;
   
   data_io_block
     #(
       .W(W),
       .WW(WW),
       .EXTDATAIN(EXTDATAIN),
       .EXTDATAOUT(EXTDATAOUT)
       )
   dut
     (
      .data_in(data_in),
      .data_out(data_out),
      .external_input(external_input),
      .external_output(external_output),
      .c(c)
      );
   
   integer   count = 0;
   
   integer   i, j, t, k, k_tmp, l, BASE;
   initial begin
      for(j = 0; j < SEL_PER_IN*W+SEL_PER_OUT*EXTDATAOUT*WW; j = j + 1) c[j] = 0;
      
      for(t = 0; t < 100; t = t + 1) begin
	 data_in = $random;
	 external_input = $random;
	 BASE = 0;
	 for(j = 0; j < W; j = j + 1) begin
	    @(negedge clk);
	    k = $urandom % EXTDATAIN;
	    k_tmp = k;
	    for(l = 0; l < SEL_PER_IN; l = l + 1) begin
	       c[l+BASE] = k_tmp%2;
	       k_tmp = k_tmp/2;
	    end
	    @(posedge clk);
	    if(data_out[j] != external_input[k*WW+j%WW]) count = count + 1;
	    BASE = BASE + SEL_PER_IN;
	 end
	 
	 for(i = 0; i < EXTDATAOUT; i = i + 1) begin
	    for(j = 0; j < WW; j = j + 1) begin
	       @(negedge clk);
	       k = $urandom % (W/WW);
	       k_tmp = k;
	       for(l = 0; l < SEL_PER_OUT; l = l + 1) begin
		  c[l+BASE] = k_tmp%2;
		  k_tmp = k_tmp/2;
	       end
	       @(posedge clk);
	       if(external_output[j+i*WW] != data_in[k*WW+j]) count = count + 1;
	       BASE = BASE + SEL_PER_OUT;
	    end
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
   
endmodule
