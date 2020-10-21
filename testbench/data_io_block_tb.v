module data_io_block_tb;
   localparam W = 12;
   localparam WW = 4;
   localparam EXTDATAIN = 3;
   localparam EXTDATAOUT = 2;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [WW*EXTDATAIN-1:0] external_input;
   wire [WW*EXTDATAOUT-1:0] external_output;
   
   reg [W-1:0] 		    d, de;
   reg [W*(EXTDATAIN+EXTDATAOUT)-1:0] c;
   wire [W-1:0] 		      data;
   
   genvar 			      k;
   generate
      for(k = 0; k < W; k = k + 1) begin
	 assign data[k] = de[k]? d[k]: 1'bz;
      end
   endgenerate
   
   data_io_block
     #(
       .W(W),
       .WW(WW),
       .EXTDATAIN(EXTDATAIN),
       .EXTDATAOUT(EXTDATAOUT)
       )
   dut
     (
      .data(data),
      .external_input(external_input),
      .external_output(external_output),
      .c(c)
      );
   
   integer   count = 0;
   
   integer   i, j, t;
   initial begin
      for(j = 0; j < W*(EXTDATAIN+EXTDATAOUT); j = j + 1) c[j] = 0;
      for(t = 0; t < 10; t = t + 1) begin
	 de = 0;
	 d = $random;
	 external_input = $random;
	 for(i = 0; i < EXTDATAIN; i = i + 1) begin
	    for(j = 0; j < W; j = j + 1) begin
	       @(negedge clk);
	       c[j+i*W] = 1;
	       @(posedge clk);
	       if(external_input[j%WW+i*WW] !== data[j]) count = count + 1;
	       @(negedge clk);
	       c[j+i*W] = 0;
	    end
	 end
	 
	 for(i = 0; i < W; i = i + 1) de[i] = 1;
	 for(i = 0; i < EXTDATAOUT; i = i + 1) begin
	    for(j = 0; j < W; j = j + 1) begin
	       @(negedge clk);
	       c[j+i*W+EXTDATAIN*W] = 1;
	       @(posedge clk);
	       if(external_output[j%WW+i*WW] !== data[j]) count = count + 1;
	       @(negedge clk);
	       c[j+i*W+EXTDATAIN*W] = 0;
	    end
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
   
endmodule
