module switch_box_element_two_tb;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [1:0] ni, ei, si, wi;
   wire [1:0] no, eo, so, wo;
   reg [15:0] c;
   
   switch_box_element_two dut(.north_in(ni), .east_in(ei), .south_in(si), .west_in(wi), .north_out(no), .east_out(eo), .south_out(so), .west_out(wo), .c(c));

   integer    count = 0;
   
   always @(posedge clk) begin
        $display("%b %b %b %b %b %b %b %b %b", c, ni, ei, si, wi, no, eo, so, wo);
      case(c[1:0])
	2'd0: if(no[0] != ei[0]) count = count + 1;
	2'd1: if(no[0] != si[0]) count = count + 1;
	2'd2: if(no[0] != wi[1]) count = count + 1;
      endcase
      case(c[3:2])
	2'd0: if(eo[1] != si[0]) count = count + 1;
	2'd1: if(eo[1] != wi[1]) count = count + 1;
	2'd2: if(eo[1] != ni[1]) count = count + 1;
      endcase
      case(c[5:4])
	2'd0: if(so[1] != wi[1]) count = count + 1;
	2'd1: if(so[1] != ni[1]) count = count + 1;
	2'd2: if(so[1] != ei[0]) count = count + 1;
      endcase
      case(c[7:6])
	2'd0: if(wo[0] != ni[1]) count = count + 1;
	2'd1: if(wo[0] != ei[0]) count = count + 1;
	2'd2: if(wo[0] != si[0]) count = count + 1;
      endcase
      case(c[9:8])
	2'd0: if(no[1] != ei[1]) count = count + 1;
	2'd1: if(no[1] != si[1]) count = count + 1;
	2'd2: if(no[1] != wi[0]) count = count + 1;
      endcase
      case(c[11:10])
	2'd0: if(eo[0] != si[1]) count = count + 1;
	2'd1: if(eo[0] != wi[0]) count = count + 1;
	2'd2: if(eo[0] != ni[0]) count = count + 1;
      endcase
      case(c[13:12])
	2'd0: if(so[0] != wi[0]) count = count + 1;
	2'd1: if(so[0] != ni[0]) count = count + 1;
	2'd2: if(so[0] != ei[1]) count = count + 1;
      endcase
      case(c[15:14])
	2'd0: if(wo[1] != ni[0]) count = count + 1;
	2'd1: if(wo[1] != ei[1]) count = count + 1;
	2'd2: if(wo[1] != si[1]) count = count + 1;
      endcase
   end

   integer   i;
   initial begin
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 ni = $random;
	 ei = $random;
	 si = $random;
	 wi = $random;
	 c = $random;
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
