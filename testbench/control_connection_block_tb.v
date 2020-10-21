module control_connection_block_tb;
   localparam W = 7;
   localparam CONTROLIN = 3;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] e, w, ee, we;
   reg [W*CONTROLIN-1:0] c;
   wire [W-1:0] 	 east, west;
   
   
   wire [CONTROLIN-1:0]  control_input;
   
   genvar 		 k;
   generate
      for(k = 0; k < W; k = k + 1) begin
	 assign east[k] = ee[k]? e[k]: 1'bz;
	 assign west[k] = we[k]? w[k]: 1'bz;
      end
   endgenerate
   
   control_connection_block 
     #(
       .W(W),
       .CONTROLIN(CONTROLIN)
       )
   dut
     (
      .east(east),
      .west(west),
      .control_input(control_input),
      .c(c)
      );
   
   integer   count = 0;
   always @(posedge clk) begin
      if(east !== west) count = count + 1;
   end
   
   integer   i, j, t;
   initial begin
      ee = 0;
      we = 0;
      for(j = 0; j < W*CONTROLIN; j = j + 1) begin
	 c[j] = 0;
      end
      
      for(i = 0; i < W; i = i + 1) ee[i] = 1;
      for(t = 0; t < 100; t = t + 1) begin
	 e = $random;
	 for(i = 0; i < CONTROLIN; i = i + 1) begin
	    for(j = 0; j < W; j = j + 1) begin
	       @(negedge clk);
	       c[j+i*W] = 1;
	       @(posedge clk);
	       if(control_input[i] !== east[j]) count = count + 1;
	       @(negedge clk);
	       c[j+i*W] = 0;
	    end
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
   
endmodule
