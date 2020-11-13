module universal_switch_box_tb;
   localparam W = 7;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] ni, ei, si, wi;
   wire [W-1:0] no, eo, so, wo;
   reg [W*8-1:0] c;
   
   
   universal_switch_box
     #(
       .W(W)
       )
   dut
     (
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
      for(k = 0; k < W/2; k = k + 1) begin
	 always @(posedge clk) begin
	    case(c[k*16+1:k*16+0])
	      2'd0: if(no[k*2+0] != ei[k*2+0]) count = count + 1;
	      2'd1: if(no[k*2+0] != si[k*2+0]) count = count + 1;
	      2'd2: if(no[k*2+0] != wi[k*2+1]) count = count + 1;
	    endcase
	    case(c[k*16+3:k*16+2])
	      2'd0: if(eo[k*2+1] != si[k*2+0]) count = count + 1;
	      2'd1: if(eo[k*2+1] != wi[k*2+1]) count = count + 1;
	      2'd2: if(eo[k*2+1] != ni[k*2+1]) count = count + 1;
	    endcase
	    case(c[k*16+5:k*16+4])
	      2'd0: if(so[k*2+1] != wi[k*2+1]) count = count + 1;
	      2'd1: if(so[k*2+1] != ni[k*2+1]) count = count + 1;
	      2'd2: if(so[k*2+1] != ei[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+7:k*16+6])
	      2'd0: if(wo[k*2+0] != ni[k*2+1]) count = count + 1;
	      2'd1: if(wo[k*2+0] != ei[k*2+0]) count = count + 1;
	      2'd2: if(wo[k*2+0] != si[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+9:k*16+8])
	      2'd0: if(no[k*2+1] != ei[k*2+1]) count = count + 1;
	      2'd1: if(no[k*2+1] != si[k*2+1]) count = count + 1;
	      2'd2: if(no[k*2+1] != wi[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+11:k*16+10])
	      2'd0: if(eo[k*2+0] != si[k*2+1]) count = count + 1;
	      2'd1: if(eo[k*2+0] != wi[k*2+0]) count = count + 1;
	      2'd2: if(eo[k*2+0] != ni[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+13:k*16+12])
	      2'd0: if(so[k*2+0] != wi[k*2+0]) count = count + 1;
	      2'd1: if(so[k*2+0] != ni[k*2+0]) count = count + 1;
	      2'd2: if(so[k*2+0] != ei[k*2+1]) count = count + 1;
	    endcase
	    case(c[k*16+15:k*16+14])
	      2'd0: if(wo[k*2+1] != ni[k*2+0]) count = count + 1;
	      2'd1: if(wo[k*2+1] != ei[k*2+1]) count = count + 1;
	      2'd2: if(wo[k*2+1] != si[k*2+1]) count = count + 1;
	    endcase
	 end
      end
      if(W%2) begin
	 always @ (posedge clk) begin
	    case(c[1+8*(W-1):8*(W-1)])
	      2'd0: if(no[(W-1)] != ei[(W-1)]) count = count + 1;
	      2'd1: if(no[(W-1)] != si[(W-1)]) count = count + 1;
	      2'd2: if(no[(W-1)] != wi[(W-1)]) count = count + 1;
	    endcase
	    case(c[3+8*(W-1):2+8*(W-1)])
	      2'd0: if(eo[(W-1)] != si[(W-1)]) count = count + 1;
	      2'd1: if(eo[(W-1)] != wi[(W-1)]) count = count + 1;
	      2'd2: if(eo[(W-1)] != ni[(W-1)]) count = count + 1;
	    endcase
	    case(c[5+8*(W-1):4+8*(W-1)])
	      2'd0: if(so[(W-1)] != wi[(W-1)]) count = count + 1;
	      2'd1: if(so[(W-1)] != ni[(W-1)]) count = count + 1;
	      2'd2: if(so[(W-1)] != ei[(W-1)]) count = count + 1;
	    endcase
	    case(c[7+8*(W-1):6+8*(W-1)])
	      2'd0: if(wo[(W-1)] != ni[(W-1)]) count = count + 1;
	      2'd1: if(wo[(W-1)] != ei[(W-1)]) count = count + 1;
	      2'd2: if(wo[(W-1)] != si[(W-1)]) count = count + 1;
	    endcase
	 end
      end
   endgenerate
   
   integer   i, j;
   initial begin
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
