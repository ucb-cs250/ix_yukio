module switch_box_element_one_tb;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg ni, ei, si, wi;
   wire no, eo, so, wo;
   reg [7:0] c;
   
   
   switch_box_element_one dut(.north_in(ni), .east_in(ei), .south_in(si), .west_in(wi), .north_out(no), .east_out(eo), .south_out(so), .west_out(wo), .c(c));
   
   integer   count = 0;
   
   always @(posedge clk) begin
     $display("%b %b %b %b %b %b %b %b %b", c, ni, ei, si, wi, no, eo, so, wo);
      case(c[1:0])
	2'd0: if(no != ei) count = count + 1;
	2'd1: if(no != si) count = count + 1;
	2'd2: if(no != wi) count = count + 1;
      endcase
      case(c[3:2])
	2'd0: if(eo != si) count = count + 1;
	2'd1: if(eo != wi) count = count + 1;
	2'd2: if(eo != ni) count = count + 1;
      endcase
      case(c[5:4])
	2'd0: if(so != wi) count = count + 1;
	2'd1: if(so != ni) count = count + 1;
	2'd2: if(so != ei) count = count + 1;
      endcase
      case(c[7:6])
	2'd0: if(wo != ni) count = count + 1;
	2'd1: if(wo != ei) count = count + 1;
	2'd2: if(wo != si) count = count + 1;
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
