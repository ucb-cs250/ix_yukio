module data_connection_block_tb;
   localparam W = 16;
   localparam WW = 4;
   localparam DATAIN = 4;
   localparam DATAOUT = 3;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W-1:0] n, s, ne, se;
   reg [W*(DATAIN+DATAOUT)-1:0] c;
   wire [W-1:0] 		north, south;
   
   wire [WW*DATAIN-1:0] 	data_input;
   reg [WW*DATAOUT-1:0] 	data_output;
   
   genvar 			k;
   generate
      for(k = 0; k < W; k = k + 1) begin
	 assign north[k] = ne[k]? n[k]: 1'bz;
	 assign south[k] = se[k]? s[k]: 1'bz;
      end
   endgenerate
   
   data_connection_block 
     #(
       .W(W),
       .WW(WW),
       .DATAIN(DATAIN),
       .DATAOUT(DATAOUT)
       )
   dut
     (
      .north(north),
      .south(south),
      .data_input(data_input),
      .data_output(data_output),
      .c(c)
      );
   
   integer   count = 0;
   always @(posedge clk) begin
      if(north !== south) count = count + 1;
   end
   
   integer   i, j, t;
   initial begin
      ne = 0;
      se = 0;
      for(j = 0; j < W*(DATAIN+DATAOUT); j = j + 1) begin
	 c[j] = 0;
      end
      
      for(t = 0; t < 10; t = t + 1) begin
	 for(i = 0; i < W; i = i + 1) ne[i] = 1;
	 n = $random;
	 for(i = 0; i < DATAIN; i = i + 1) begin
	    for(j = 0; j < W; j = j + 1) begin
	       @(negedge clk);
	       c[j+i*W] = 1;
	       @(posedge clk);
	       if(data_input[j%WW+i*WW] !== north[j]) count = count + 1;
	       @(negedge clk);
	       c[j+i*W] = 0;
	    end
	 end
	 
	 ne = 0;
	 data_output = $random;
	 for(i = 0; i < DATAOUT; i = i + 1) begin
	    for(j = 0; j < W; j = j + 1) begin
	       @(negedge clk);
	       c[j+i*W+DATAIN*W] = 1;
	       @(posedge clk);
	       if(data_output[j%WW+i*WW] !== north[j]) count = count + 1;
	       @(negedge clk);
	       c[j+i*W+DATAIN*W] = 0;
	    end
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
   
endmodule
