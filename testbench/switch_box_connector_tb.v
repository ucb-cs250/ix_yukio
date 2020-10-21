module switch_box_connector_tb;
   localparam W0 = 3;
   localparam W1 = 10;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W0-1:0] d0, d0e;
   reg [W1-1:0] d1, d1e;
   wire [W0-1:0] data0;
   wire [W1-1:0] data1;
   
   genvar 	 k;
   generate
      for(k = 0; k < W0; k = k + 1) begin
	 assign data0[k] = d0e[k]? d0[k]: 1'bz;
      end
      for(k = 0; k < W1; k = k + 1) begin
	 assign data1[k] = d1e[k]? d1[k]: 1'bz;
      end
   endgenerate
   
   switch_box_connector
     #(
       .W0(W0),
       .W1(W1)
       )
   dut
     (
      .data0(data0),
      .data1(data1)
      );
   
   integer   count = 0;
   
   generate
      if(W0 < W1) begin
	 wire [W1-1:0] valid;
	 for(k = 0; k < W1; k = k + 1) begin
	    assign valid[k] = data1[k] === data0[k%W0];
	 end
	 always @(posedge clk) begin
	    if(!(&valid)) count = count + 1;
	 end
      end else begin
	 wire [W0-1:0] valid;
	 for(k = 0; k < W0; k = k + 1) begin
	    assign valid[k] = data0[k] === data1[k%W1];
	 end
	 always @(posedge clk) begin
	    if(!(&valid)) count = count + 1;
	 end
      end
   endgenerate
   
   integer   i;
   initial begin
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 d0 = $random;
	 d0e = $random;
	 d1 = $random;
	 d1e = $random;
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
