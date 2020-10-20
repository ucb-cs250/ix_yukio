module switch_box_element_two_tb;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [1:0] n, e, s, w;
   reg [1:0] ne, ee, se, we;
   reg [11:0] c;
   wire [1:0] north, east, south, west;
   
   assign north[0] = ne[0]? n[0]: 1'bz;
   assign north[1] = ne[1]? n[1]: 1'bz;
   assign east[0] = ee[0]? e[0]: 1'bz;
   assign east[1] = ee[1]? e[1]: 1'bz;
   assign south[0] = se[0]? s[0]: 1'bz;
   assign south[1] = se[1]? s[1]: 1'bz;
   assign west[0] = we[0]? w[0]: 1'bz;
   assign west[1] = we[1]? w[1]: 1'bz;
   
   switch_box_element_two dut(.north(north), .east(east), .south(south), .west(west), .c(c));

   integer    count = 0;
   
   
   always @(posedge clk) begin
     $display("%b %b %b %b %b", c, north, east, south, west);
      if(c[0] && north[0] != east[0]) count = count + 1;
      else if(c[1] && east[1] != south[0]) count = count + 1;
      else if(c[2] && south[1] != west[1]) count = count + 1;
      else if(c[3] && west[0] != north[1]) count = count + 1;
      else if(c[4] && north[0] != south[0]) count = count + 1;
      else if(c[5] && east[1] != west[1]) count = count + 1;
      else if(c[6] && south[1] != north[1]) count = count + 1;
      else if(c[7] && west[0] != east[0]) count = count + 1;
      else if(c[8] && north[1] != east[1]) count = count + 1;
      else if(c[9] && east[0] != south[1]) count = count + 1;
      else if(c[10] && south[0] != west[0]) count = count + 1;
      else if(c[11] && west[1] != north[0]) count = count + 1;
   end

   integer   i;
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
