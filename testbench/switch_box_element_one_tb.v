module switch_box_element_one_tb;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg n, e, s, w;
   reg ne, ee, se, we;
   reg [5:0] c;
   wire      north, east, south, west;

   assign north = ne? n: 1'bz;
   assign east = ee? e: 1'bz;
   assign south = se? s: 1'bz;
   assign west = we? w: 1'bz;
   
   switch_box_element_one dut(.north(north), .east(east), .south(south), .west(west), .c(c));

   integer   count = 0;
   
   
   always @(posedge clk) begin
     $display("%b %b %b %b %b", c, north, east, south, west);
      if(c[0] && north != east) count = count + 1;
      else if(c[1] && east != south) count = count + 1;
      else if(c[2] && south != west) count = count + 1;
      else if(c[3] && west != north) count = count + 1;
      else if(c[4] && north != south) count = count + 1;
      else if(c[5] && east != west) count = count + 1;
   end

   integer   i;
   initial begin
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 n = $random;
	 e = $random;
	 s = $random;
	 w = $random;
	 c = $random;
	 ne = $random;
	 ee = $random;
	 se = $random;
	 we = $random;
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
