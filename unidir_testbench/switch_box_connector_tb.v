module switch_box_connector_tb;
   localparam W0 = 3;
   localparam W1 = 10;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [W0-1:0] d0_in;
   wire [W0-1:0] d0_out;
   reg [W1-1:0]  d1_in;
   wire [W1-1:0] d1_out;
   
   switch_box_connector
     #(
       .W0(W0),
       .W1(W1)
       )
   dut
     (
      .data0_in(d0_in),
      .data1_in(d1_in),
      .data0_out(d0_out),
      .data1_out(d1_out)
      );
   
   integer   count = 0;
   
   wire [W0-1:0] valid0;
   wire [W1-1:0] valid1;
   genvar 	 k;
   generate
      for(k = 0; k < W0; k = k + 1) begin
	 assign valid0[k] = d0_out[k] == d1_in[k%W1];
      end
      for(k = 0; k < W1; k = k + 1) begin
	 assign valid1[k] = d1_out[k] == d0_in[k%W0];
      end
   endgenerate
   always @(posedge clk) begin
      if(!(&valid0)) count = count + 1;
      if(!(&valid1)) count = count + 1;
   end
   
   integer   i;
   initial begin
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 d0_in = $random;
	 d1_in = $random;
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
