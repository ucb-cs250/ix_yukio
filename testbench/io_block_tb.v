module io_block_tb;
   localparam WS = 7;
   localparam WD = 6;
   localparam WG = 3;
   localparam EXTIN = 5;
   localparam EXTOUT = 2;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [EXTIN-1:0] external_input;
   wire [EXTOUT-1:0] external_output;
   
   reg [WS-1:0]      s, se;
   reg [WD-1:0]      d, de;
   reg [WG-1:0]      g, ge;
   reg [(EXTIN+EXTOUT)*(WS+WD+WG)-1:0] c;
   wire [WS-1:0] 		       single;
   wire [WD-1:0] 		       double;
   wire [WG-1:0] 		       global;
   
   genvar 			       k;
   generate
      for(k = 0; k < WS; k = k + 1) begin
	 assign single[k] = se[k]? s[k]: 1'bz;
      end
      for(k = 0; k < WD; k = k + 1) begin
	 assign double[k] = de[k]? d[k]: 1'bz;
      end
      for(k = 0; k < WG; k = k + 1) begin
	 assign global[k] = ge[k]? g[k]: 1'bz;
      end
   endgenerate
   
   io_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .EXTIN(EXTIN),
       .EXTOUT(EXTOUT)
       )
   dut
     (
      .single(single),
      .double(double),
      .global(global),
      .external_input(external_input),
      .external_output(external_output),
      .c(c)
      );

   integer   count = 0;

   integer   i, j, BASE, t;
   initial begin
      for(t = 0; t < 10; t = t + 1) begin
	 BASE = 0;
	 se = 0;
	 de = 0;
	 ge = 0;
	 for(j = 0; j < (EXTIN+EXTOUT)*(WS+WD+WG); j = j + 1) c[j] = 0;
	 s = $random;
	 d = $random;
	 g = $random;
	 external_input = $random;
	 for(i = 0; i < EXTIN; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % WS;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(external_input[i] !== single[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WS;
	    j = $urandom % WD;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(external_input[i] !== double[j]) count = count + 1;
	    c[BASE+j] = 0;
	    BASE = BASE + WD;
	    j = $urandom % WG;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(external_input[i] !== global[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WG;
	 end
	 
	 for(j = 0; j < WS; j = j + 1) se[j] = 1;
	 for(j = 0; j < WD; j = j + 1) de[j] = 1;
	 for(j = 0; j < WG; j = j + 1) ge[j] = 1;
	 for(i = 0; i < EXTOUT; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % WS;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(external_output[i] !== single[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WS;
	    j = $urandom % WD;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(external_output[i] !== double[j]) count = count + 1;
	    c[BASE+j] = 0;
	    BASE = BASE + WD;
	    j = $urandom % WG;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(external_output[i] !== global[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WG;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
