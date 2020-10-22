module connection_block_tb;
   localparam WS = 7;
   localparam WD = 6;
   localparam WG = 3;
   localparam CLBIN = 6;
   localparam CLBIN0 = 2;
   localparam CLBIN1 = 2;
   localparam CLBOUT = 2;
   localparam CLBOUT0 = 2;
   localparam CLBOUT1 = 2;
   localparam CARRY = 1;
   localparam CLBOS = 2;
   localparam CLBOS_BIAS = 1;
   localparam CLBOD = 2;
   localparam CLBOD_BIAS = 1;
   localparam CLBX = 1;
   
   reg 				     clk = 0;
   always #10 clk = ~clk;
   
   wire [WS-1:0] 		     single0, single1;
   wire [WD-1:0] 		     double0, double1;
   reg [WG-1:0] 		     global0;
   reg [CLBOUT-1:0] 		     clb0_output;
   reg [CLBOUT-1:0] 		     clb1_output;
   reg [CARRY-1:0] 		     clb0_cout;
   reg [CARRY-1:0] 		     clb1_cout;
   wire [CLBIN-1:0] 		     clb0_input;
   wire [CLBIN-1:0] 		     clb1_input;
   wire [CARRY-1:0] 		     clb0_cin;
   wire [CARRY-1:0] 		     clb1_cin;
   reg [CLBOUT0*(CLBOS+CLBOD)
	+CLBIN0*(WS+WD+WG+CLBX*CLBOUT1)
	+CLBOUT1*(CLBOS+CLBOD)
	+CLBIN1*(WS+WD+WG+CLBX*CLBOUT0)-1:0] c;
   
   reg [WS-1:0] 			     s0, s1, s0e, s1e;
   reg [WD-1:0] 			     d0, d1, d0e, d1e;
   
   genvar 				     k;
   generate
      for(k = 0; k < WS; k = k + 1) begin
	 assign single0[k] = s0e[k]? s0[k]: 1'bz;
	 assign single1[k] = s1e[k]? s1[k]: 1'bz;
      end
      for(k = 0; k < WD; k = k + 1) begin
	 assign double0[k] = d0e[k]? d0[k]: 1'bz;
	 assign double1[k] = d1e[k]? d1[k]: 1'bz;
      end
   endgenerate

   connection_block 
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIN0),
       .CLBIN1(CLBIN1),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBOUT0),
       .CLBOUT1(CLBOUT1),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(CLBOS_BIAS),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(CLBOD_BIAS),
       .CLBX(CLBX)
       )
   dut
     (
      .single0(single0),
      .single1(single1),
      .double0(double0),
      .double1(double1),
      .global0(global0),
      .clb0_output(clb0_output),
      .clb1_output(clb1_output),
      .clb0_cout(clb0_cout),
      .clb1_cout(clb1_cout),
      .clb0_input(clb0_input),
      .clb1_input(clb1_input),
      .clb0_cin(clb0_cin),
      .clb1_cin(clb1_cin),
      .c(c)
      );
   
   integer   count = 0;
   always @(posedge clk) begin
      if(single0 !== single1) count = count + 1;
      else if(double0 !== double1) count = count + 1;
      else if(clb0_cout !== clb1_cin) count = count + 1;
      else if(clb1_cout !== clb0_cin) count = count + 1;
   end
   
   integer   i, j, BASE, t;
   initial begin
      s0e = 0;
      d0e = 0;
      s1e = 0;
      d1e = 0;
      for(j = 0; j < CLBOUT0*(CLBOS+CLBOD)+CLBIN0*(WS+WD+WG+CLBX*CLBOUT1)+CLBOUT1*(CLBOS+CLBOD)+CLBIN1*(WS+WD+WG+CLBX*CLBOUT0); j = j + 1) begin
	 c[j] = 0;
      end

      for(t = 0; t < 10; t = t + 1)  begin
	 clb0_output = $random;
	 clb1_output = $random;
	 s0 = $random;
	 d0 = $random;
	 global0 = $random;
	 BASE = 0;
	 for(j = 0; j < WS; j = j + 1) s0e[j] = 1;
	 for(j = 0; j < WD; j = j + 1) d0e[j] = 1;
	 for(i = 0; i < CLBIN0; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % WS;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb0_input[i] !== single0[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WS;
	    j = $urandom % WD;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb0_input[i] !== double0[j]) count = count + 1;
	    c[BASE+j] = 0;
	    BASE = BASE + WD;
	    j = $urandom % WG;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb0_input[i] !== global0[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WG;
	    if(CLBX) begin
	       j = $urandom % CLBOUT1;
	       c[BASE+j] = 1;
	       @(posedge clk);
	       if(clb0_input[i] !== clb1_output[j]) count = count + 1;
	       @(negedge clk);
	       c[BASE+j] = 0;
	       BASE = BASE + CLBOUT1;
	    end
	 end
	 
	 s0e = 0;
	 d0e = 0;
	 for(i = 0; i < CLBOUT0; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % CLBOS;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb0_output[i] !== single0[(j+i*CLBOS+CLBOS_BIAS*CLBOS*(CLBOUT0+CLBOUT1))%WS]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + CLBOS;
	    j = $urandom % CLBOD;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb0_output[i] !== double0[(j+i*CLBOD+CLBOD_BIAS*CLBOD*(CLBOUT0+CLBOUT1))%(WD/2)]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + CLBOD;
	 end
	 
	 for(j = 0; j < WS; j = j + 1) s0e[j] = 1;
	 for(j = 0; j < WD; j = j + 1) d0e[j] = 1;
	 for(i = 0; i < CLBIN1; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % WS;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb1_input[i] !== single0[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WS;
	    j = $urandom % WD;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb1_input[i] !== double0[j]) count = count + 1;
	    c[BASE+j] = 0;
	    BASE = BASE + WD;
	    j = $urandom % WG;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb1_input[i] !== global0[j]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + WG;
	    if(CLBX) begin
	       j = $urandom % CLBOUT0;
	       c[BASE+j] = 1;
	       @(posedge clk);
	       if(clb1_input[i] !== clb0_output[j]) count = count + 1;
	       @(negedge clk);
	       c[BASE+j] = 0;
	       BASE = BASE + CLBOUT0;
	    end
	 end
	 
	 s0e = 0;
	 d0e = 0;
	 for(i = 0; i < CLBOUT1; i = i + 1) begin
	    @(negedge clk);
	    j = $urandom % CLBOS;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb1_output[i] !== single0[(j+(CLBOUT0+i)*CLBOS+CLBOS_BIAS*CLBOS*(CLBOUT0+CLBOUT1))%WS]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + CLBOS;
	    j = $urandom % CLBOD;
	    c[BASE+j] = 1;
	    @(posedge clk);
	    if(clb1_output[i] !== double0[(j+(CLBOUT0+i)*CLBOD+CLBOD_BIAS*CLBOD*(CLBOUT0+CLBOUT1))%(WD/2)]) count = count + 1;
	    @(negedge clk);
	    c[BASE+j] = 0;
	    BASE = BASE + CLBOD;
	 end
      end
      
      for(t = 0; t < 100; t = t + 1)  begin
	 @(negedge clk);
	 s0e = $random;
	 s1e = $random;
	 d0e = $random;
	 d1e = $random;
	 clb0_output = $random;
	 clb1_output = $random;
	 clb0_cout = $random;
	 clb1_cout = $random;
	 s0 = $random;
	 s1 = $random;
	 d0 = $random;
	 d1 = $random;
	 global0 = $random;
      end

   
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end
     
endmodule
