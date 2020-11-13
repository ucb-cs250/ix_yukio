module vertical_disjoint_switch_box_tb;
   localparam W = 8;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] ni, si;
   wire [W-1:0] no, so;
   
   genvar 	k;
   
   vertical_disjoint_switch_box
     #(.W(W))
   dut
     (
      .north_in(ni),
      .south_in(si),
      .north_out(no),
      .south_out(so)
      );
   
   integer   count = 0;
   always @(posedge clk) begin
      if(ni != so) count = count + 1;
      if(si != no) count = count + 1;
   end

   integer   i, j;
   initial begin
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 ni = $random;
	 si = $random;
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
