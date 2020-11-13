module disjoint_switch_box_tb;
   localparam W = 8; // WW * WN
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] ni, ei, si, wi;
   wire [W-1:0] no, eo, so, wo;
   reg [W*8-1:0] c;

   reg 		 rst, cset;
   
   disjoint_switch_box
     #(.W(W))
   dut
     (
      .clk(clk),
      .rst(rst),
      .cset(cset),
      .north_in(ni),
      .east_in(ei),
      .south_in(si),
      .west_in(wi),
      .north_out(no),
      .east_out(eo),
      .south_out(so), 
      .west_out(wo),
      .c(c)
      );
   
   integer 	 count = 0;
   genvar 	 k;
   generate 
      for(k = 0; k < W; k = k + 1) begin
	 always @(posedge clk) begin
	    #1;
	    case(c[1+8*k:8*k])
	      2'd0: if(no[k] != ei[k]) count = count + 1;
	      2'd1: if(no[k] != si[k]) count = count + 1;
	      2'd2: if(no[k] != wi[k]) count = count + 1;
	    endcase
	    case(c[3+8*k:2+8*k])
	      2'd0: if(eo[k] != si[k]) count = count + 1;
	      2'd1: if(eo[k] != wi[k]) count = count + 1;
	      2'd2: if(eo[k] != ni[k]) count = count + 1;
	    endcase
	    case(c[5+8*k:4+8*k])
	      2'd0: if(so[k] != wi[k]) count = count + 1;
	      2'd1: if(so[k] != ni[k]) count = count + 1;
	      2'd2: if(so[k] != ei[k]) count = count + 1;
	    endcase
	    case(c[7+8*k:6+8*k])
	      2'd0: if(wo[k] != ni[k]) count = count + 1;
	      2'd1: if(wo[k] != ei[k]) count = count + 1;
	      2'd2: if(wo[k] != si[k]) count = count + 1;
	    endcase
	 end
      end
   endgenerate
   
   integer   i, j;
   initial begin
      rst = 0;
      cset  = 1;
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 ni = $random;
	 ei = $random;
	 si = $random;
	 wi = $random;
	 for(j = 0; j < W*8; j = j + 1) begin
	    c[j] = $random;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
