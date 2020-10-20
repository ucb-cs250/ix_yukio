module universal_switch_box_tb;
   localparam WS = 7;
   localparam WD = 6;
   localparam WG = 3;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [WS-1:0] ns, es, ss, ws, nse, ese, sse, wse;
   reg [WD-1:0] nd, ed, sd, wd, nde, ede, sde, wde;
   reg [WG-1:0] ng, eg, sg, wg, nge, ege, sge, wge;
   reg [WS*6+WD/2*6-1:0] c;
   wire [WS-1:0] 	 north_single, east_single, south_single, west_single;
   wire [WD-1:0] 	 north_double, east_double, south_double, west_double;
   wire [WG-1:0] 	 north_global, east_global, south_global, west_global;

   genvar 		 k;
   generate
      for(k = 0; k < WS; k = k + 1) begin
	 assign north_single[k] = nse[k]? ns[k]: 1'bz;
	 assign east_single[k] = ese[k]? es[k]: 1'bz;
	 assign south_single[k] = sse[k]? ss[k]: 1'bz;
	 assign west_single[k] = wse[k]? ws[k]: 1'bz;
      end
      for(k = 0; k < WD; k = k + 1) begin
	 assign north_double[k] = nde[k]? nd[k]: 1'bz;
	 assign east_double[k] = ede[k]? ed[k]: 1'bz;
	 assign south_double[k] = sde[k]? sd[k]: 1'bz;
	 assign west_double[k] = wde[k]? wd[k]: 1'bz;
      end
      for(k = 0; k < WG; k = k + 1) begin
	 assign north_global[k] = nge[k]? ng[k]: 1'bz;
	 assign east_global[k] = ege[k]? eg[k]: 1'bz;
	 assign south_global[k] = sge[k]? sg[k]: 1'bz;
	 assign west_global[k] = wge[k]? wg[k]: 1'bz;
      end
   endgenerate
   
   universal_switch_box
     #(.WS(WS),
       .WD(WD),
       .WG(WG)
       )
   dut
     (
      .north_single(north_single),
      .east_single(east_single),
      .south_single(south_single),
      .west_single(west_single),
      .north_double(north_double),
      .east_double(east_double),
      .south_double(south_double),
      .west_double(west_double),
      .north_global(north_global),
      .east_global(east_global),
      .south_global(south_global),
      .west_global(west_global),
      .c(c)
      );

   wire [WS*6-1:0] single_valid;
   generate 
      for(k = 0; k < WS/2; k = k + 1) begin
	 assign single_valid[k*12] = !c[k*12] || north_single[k*2] == east_single[k*2];
	 assign single_valid[k*12+1] = !c[k*12+1] || east_single[k*2+1] == south_single[k*2];
	 assign single_valid[k*12+2] = !c[k*12+2] || south_single[k*2+1] == west_single[k*2+1];
	 assign single_valid[k*12+3] = !c[k*12+3] || west_single[k*2] == north_single[k*2+1];
	 assign single_valid[k*12+4] = !c[k*12+4] || north_single[k*2] == south_single[k*2];
	 assign single_valid[k*12+5] = !c[k*12+5] || east_single[k*2+1] == west_single[k*2+1];
	 assign single_valid[k*12+6] = !c[k*12+6] || south_single[k*2+1] == north_single[k*2+1];
	 assign single_valid[k*12+7] = !c[k*12+7] || west_single[k*2] == east_single[k*2];
	 assign single_valid[k*12+8] = !c[k*12+8] || north_single[k*2+1] == east_single[k*2+1];
	 assign single_valid[k*12+9] = !c[k*12+9] || east_single[k*2] == south_single[k*2+1];
	 assign single_valid[k*12+10] = !c[k*12+10] || south_single[k*2] == west_single[k*2];
	 assign single_valid[k*12+11] = !c[k*12+11] || west_single[k*2+1] == north_single[k*2];
      end
      if(WS%2) begin
	 assign single_valid[(WS-1)*6] = !c[(WS-1)*6] || north_single[WS-1] == east_single[WS-1];
	 assign single_valid[(WS-1)*6+1] = !c[(WS-1)*6+1] || east_single[WS-1] == south_single[WS-1];
	 assign single_valid[(WS-1)*6+2] = !c[(WS-1)*6+2] || south_single[WS-1] == west_single[WS-1];
	 assign single_valid[(WS-1)*6+3] = !c[(WS-1)*6+3] || west_single[WS-1] == north_single[WS-1];
	 assign single_valid[(WS-1)*6+4] = !c[(WS-1)*6+4] || north_single[WS-1] == south_single[WS-1];
	 assign single_valid[(WS-1)*6+5] = !c[(WS-1)*6+5] || east_single[WS-1] == west_single[WS-1];
      end
   endgenerate

   localparam BASE = WS*6;

   wire [WD/2*6-1:0] double_valid;
   generate
      for(k = 0; k < WD/4; k = k + 1) begin
	 assign double_valid[k*12] = !c[BASE+k*12] || north_double[k*2] == east_double[WD/2+k*2];
	 assign double_valid[k*12+1] = !c[BASE+k*12+1] || east_double[WD/2+k*2+1] == south_double[WD/2+k*2];
	 assign double_valid[k*12+2] = !c[BASE+k*12+2] || south_double[WD/2+k*2+1] == west_double[k*2+1];
	 assign double_valid[k*12+3] = !c[BASE+k*12+3] || west_double[k*2] == north_double[k*2+1];
	 assign double_valid[k*12+4] = !c[BASE+k*12+4] || north_double[k*2] == south_double[WD/2+k*2];
	 assign double_valid[k*12+5] = !c[BASE+k*12+5] || east_double[WD/2+k*2+1] == west_double[k*2+1];
	 assign double_valid[k*12+6] = !c[BASE+k*12+6] || south_double[WD/2+k*2+1] == north_double[k*2+1];
	 assign double_valid[k*12+7] = !c[BASE+k*12+7] || west_double[k*2] == east_double[WD/2+k*2];
	 assign double_valid[k*12+8] = !c[BASE+k*12+8] || north_double[k*2+1] == east_double[WD/2+k*2+1];
	 assign double_valid[k*12+9] = !c[BASE+k*12+9] || east_double[WD/2+k*2] == south_double[WD/2+k*2+1];
	 assign double_valid[k*12+10] = !c[BASE+k*12+10] || south_double[WD/2+k*2] == west_double[k*2];
	 assign double_valid[k*12+11] = !c[BASE+k*12+11] || west_double[k*2+1] == north_double[k*2];
      end
      if(WD/2%2) begin
	 assign double_valid[(WD/2-1)*6] = !c[BASE+(WD/2-1)*6] || north_double[WD/2-1] == east_double[WD-1];
	 assign double_valid[(WD/2-1)*6+1] = !c[BASE+(WD/2-1)*6+1] || east_double[WD-1] == south_double[WD-1];
	 assign double_valid[(WD/2-1)*6+2] = !c[BASE+(WD/2-1)*6+2] || south_double[WD-1] == west_double[WD/2-1];
	 assign double_valid[(WD/2-1)*6+3] = !c[BASE+(WD/2-1)*6+3] || west_double[WD/2-1] == north_double[WD/2-1];
	 assign double_valid[(WD/2-1)*6+4] = !c[BASE+(WD/2-1)*6+4] || north_double[WD/2-1] == south_double[WD-1];
	 assign double_valid[(WD/2-1)*6+5] = !c[BASE+(WD/2-1)*6+5] || east_double[WD-1] == west_double[WD/2-1];
      end
   endgenerate
   
   integer   count = 0;
   always @(posedge clk) begin
      if(north_global != south_global) count = count + 1;
      else if(east_global != west_global) count = count + 1;
      else if(!(&single_valid)) count = count + 1;
      else if(north_double[WD-1:WD/2] != south_double[WD/2-1:0]) count = count + 1;
      else if(east_double[WD/2-1:0] != west_double[WD-1:WD/2]) count = count + 1;
      else if(!(&double_valid)) count = count + 1;
   end

   integer   i, j;
   initial begin
      nse = 0;
      ese = 0;
      sse = 0;
      wse = 0;
      nde = 0;
      ede = 0;
      sde = 0;
      wde = 0;
      nge = 0;
      ege = 0;
      sge = 0;
      wge = 0;
      c = 0;
      @(posedge clk);
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 for(j = 0; j < WS*6+WD/2*6; j = j + 1) begin
	    ns = $random;
	    es = $random;
	    ss = $random;
	    ws = $random;
	    nd = $random;
	    ed = $random;
	    sd = $random;
	    wd = $random;
	    ng = $random;
	    eg = $random;
	    sg = $random;
	    wg = $random;
	    nse = $random;
	    ese = $random;
	    sse = $random;
	    wse = $random;
	    nde = $random;
	    ede = $random;
	    sde = $random;
	    wde = $random;
	    nge = $random;
	    ege = $random;
	    sge = $random;
	    wge = $random;
	    c[j] = $random;
	 end

      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
