module universal_switch_box_tb;
   localparam W = 7;
   
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
   
   universal_switch_box
     #(
       .W(W)
       )
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
      for(k = 0; k < W/2; k = k + 1) begin
	 assign valid[k*12] = !c[k*12] || north[k*2] === east[k*2];
	 assign valid[k*12+1] = !c[k*12+1] || east[k*2+1] === south[k*2];
	 assign valid[k*12+2] = !c[k*12+2] || south[k*2+1] === west[k*2+1];
	 assign valid[k*12+3] = !c[k*12+3] || west[k*2] === north[k*2+1];
	 assign valid[k*12+4] = !c[k*12+4] || north[k*2] === south[k*2];
	 assign valid[k*12+5] = !c[k*12+5] || east[k*2+1] === west[k*2+1];
	 assign valid[k*12+6] = !c[k*12+6] || south[k*2+1] === north[k*2+1];
	 assign valid[k*12+7] = !c[k*12+7] || west[k*2] === east[k*2];
	 assign valid[k*12+8] = !c[k*12+8] || north[k*2+1] === east[k*2+1];
	 assign valid[k*12+9] = !c[k*12+9] || east[k*2] === south[k*2+1];
	 assign valid[k*12+10] = !c[k*12+10] || south[k*2] === west[k*2];
	 assign valid[k*12+11] = !c[k*12+11] || west[k*2+1] === north[k*2];
      end
      if(W%2) begin
	 assign valid[(W-1)*6] = !c[(W-1)*6] || north[W-1] === east[W-1];
	 assign valid[(W-1)*6+1] = !c[(W-1)*6+1] || east[W-1] === south[W-1];
	 assign valid[(W-1)*6+2] = !c[(W-1)*6+2] || south[W-1] === west[W-1];
	 assign valid[(W-1)*6+3] = !c[(W-1)*6+3] || west[W-1] === north[W-1];
	 assign valid[(W-1)*6+4] = !c[(W-1)*6+4] || north[W-1] === south[W-1];
	 assign valid[(W-1)*6+5] = !c[(W-1)*6+5] || east[W-1] === west[W-1];
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
	 e = $random;
	 s= $random;
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
