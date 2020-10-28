module vertical_disjoint_switch_box_tb;
   localparam W = 8;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] n, s, ne, se;
   reg [W-1:0] c;
   wire [W-1:0] north, south;
   
   genvar 	k;
   generate
      for(k = 0; k < W; k = k + 1) begin
	 assign north[k] = ne[k]? n[k]: 1'bz;
	 assign south[k] = se[k]? s[k]: 1'bz;
      end
   endgenerate
   
   vertical_disjoint_switch_box
     #(.W(W))
   dut
     (
      .north(north),
      .south(south),
      .c(c)
      );

   wire [W-1:0] valid;
   generate 
      for(k = 0; k < W; k = k + 1) begin
	 assign valid[k] = !c[k] || north[k] === south[k];
      end
   endgenerate
   
   integer   count = 0;
   always @(posedge clk) begin
      if(!(&valid)) count = count + 1;
   end

   integer   i, j;
   initial begin
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 n = $random;
	 s = $random;
	 ne = $random;
	 se = $random;
	 for(j = 0; j < W; j = j + 1) begin
	    c[j] = $random;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
