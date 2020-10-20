module disjoint_switch_box_tb;
   localparam W = 8;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] n, e, s, w, ne, ee, se, we;
   reg [W*6-1:0] c;
   wire [W-1:0]  north, east, south, west;
   
   genvar 	 k;
   generate
      for(k = 0; k < W; k = k + 1) begin
	 assign north[k] = ne[k]? n[k]: 1'bz;
	 assign east[k] = ee[k]? e[k]: 1'bz;
	 assign south[k] = se[k]? s[k]: 1'bz;
	 assign west[k] = we[k]? w[k]: 1'bz;
      end
   endgenerate
   
   disjoint_switch_box
     #(.W(W))
   dut
     (
      .north(north),
      .east(east),
      .south(south),
      .west(west),
      .c(c)
      );

   wire [W*6-1:0] valid;
   generate 
      for(k = 0; k < W; k = k + 1) begin
	 assign valid[k*6] = !c[k*6] || north[k] == east[k];
	 assign valid[k*6+1] = !c[k*6+1] || east[k] == south[k];
	 assign valid[k*6+2] = !c[k*6+2] || south[k] == west[k];
	 assign valid[k*6+3] = !c[k*6+3] || west[k] == north[k];
	 assign valid[k*6+4] = !c[k*6+4] || north[k] == south[k];
	 assign valid[k*6+5] = !c[k*6+5] || east[k] == west[k];
      end
   endgenerate
   
   integer   count = 0;
   always @(posedge clk) begin
      if(!(&valid)) count = count + 1;
   end

   integer   i, j;
   initial begin
      ne = 0;
      ee = 0;
      se = 0;
      we = 0;
      c = 0;
      @(posedge clk);
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 n = $random;
	 e = $random;
	 s = $random;
	 w = $random;
	 ne = $random;
	 ee = $random;
	 se = $random;
	 we = $random;
	 for(j = 0; j < W*6; j = j + 1) begin
	    c[j] = $random;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
