module clb_switch_box_tb;
   localparam WS = 7;
   localparam WD = 6;
   
   reg clk = 0;
   always #10 clk = ~clk;
   
   reg [WS-1:0] nsi, esi, ssi, wsi;
   wire [WS-1:0] nso, eso, sso, wso;
   reg [WD-1:0]  ndi, edi, sdi, wdi;
   wire [WD-1:0] ndo, edo, sdo, wdo;
   reg [WS*8+WD/2*8-1:0] c;

   clb_switch_box
     #(
       .WS(WS),
       .WD(WD)
       )
   dut
     (
      .north_single_in(nsi),
      .east_single_in(esi),
      .south_single_in(ssi),
      .west_single_in(wsi),
      .north_double_in(ndi),
      .east_double_in(edi),
      .south_double_in(sdi),
      .west_double_in(wdi),
      .north_single_out(nso),
      .east_single_out(eso),
      .south_single_out(sso),
      .west_single_out(wso),
      .north_double_out(ndo),
      .east_double_out(edo),
      .south_double_out(sdo),
      .west_double_out(wdo),
      .c(c)
      );

   genvar 		 k;
   integer 		 count = 0;   
   generate 
      for(k = 0; k < WS/2; k = k + 1) begin
	 always @(posedge clk) begin
	    case(c[k*16+1:k*16+0])
	      2'd0: if(nso[k*2+0] != esi[k*2+0]) count = count + 1;
	      2'd1: if(nso[k*2+0] != ssi[k*2+0]) count = count + 1;
	      2'd2: if(nso[k*2+0] != wsi[k*2+1]) count = count + 1;
	    endcase
	    case(c[k*16+3:k*16+2])
	      2'd0: if(eso[k*2+1] != ssi[k*2+0]) count = count + 1;
	      2'd1: if(eso[k*2+1] != wsi[k*2+1]) count = count + 1;
	      2'd2: if(eso[k*2+1] != nsi[k*2+1]) count = count + 1;
	    endcase
	    case(c[k*16+5:k*16+4])
	      2'd0: if(sso[k*2+1] != wsi[k*2+1]) count = count + 1;
	      2'd1: if(sso[k*2+1] != nsi[k*2+1]) count = count + 1;
	      2'd2: if(sso[k*2+1] != esi[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+7:k*16+6])
	      2'd0: if(wso[k*2+0] != nsi[k*2+1]) count = count + 1;
	      2'd1: if(wso[k*2+0] != esi[k*2+0]) count = count + 1;
	      2'd2: if(wso[k*2+0] != ssi[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+9:k*16+8])
	      2'd0: if(nso[k*2+1] != esi[k*2+1]) count = count + 1;
	      2'd1: if(nso[k*2+1] != ssi[k*2+1]) count = count + 1;
	      2'd2: if(nso[k*2+1] != wsi[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+11:k*16+10])
	      2'd0: if(eso[k*2+0] != ssi[k*2+1]) count = count + 1;
	      2'd1: if(eso[k*2+0] != wsi[k*2+0]) count = count + 1;
	      2'd2: if(eso[k*2+0] != nsi[k*2+0]) count = count + 1;
	    endcase
	    case(c[k*16+13:k*16+12])
	      2'd0: if(sso[k*2+0] != wsi[k*2+0]) count = count + 1;
	      2'd1: if(sso[k*2+0] != nsi[k*2+0]) count = count + 1;
	      2'd2: if(sso[k*2+0] != esi[k*2+1]) count = count + 1;
	    endcase
	    case(c[k*16+15:k*16+14])
	      2'd0: if(wso[k*2+1] != nsi[k*2+0]) count = count + 1;
	      2'd1: if(wso[k*2+1] != esi[k*2+1]) count = count + 1;
	      2'd2: if(wso[k*2+1] != ssi[k*2+1]) count = count + 1;
	    endcase
	 end
      end
      if(WS%2) begin
	 always @ (posedge clk) begin
	    case(c[1+8*(WS-1):8*(WS-1)])
	      2'd0: if(nso[(WS-1)] != esi[(WS-1)]) count = count + 1;
	      2'd1: if(nso[(WS-1)] != ssi[(WS-1)]) count = count + 1;
	      2'd2: if(nso[(WS-1)] != wsi[(WS-1)]) count = count + 1;
	    endcase
	    case(c[3+8*(WS-1):2+8*(WS-1)])
	      2'd0: if(eso[(WS-1)] != ssi[(WS-1)]) count = count + 1;
	      2'd1: if(eso[(WS-1)] != wsi[(WS-1)]) count = count + 1;
	      2'd2: if(eso[(WS-1)] != nsi[(WS-1)]) count = count + 1;
	    endcase
	    case(c[5+8*(WS-1):4+8*(WS-1)])
	      2'd0: if(sso[(WS-1)] != wsi[(WS-1)]) count = count + 1;
	      2'd1: if(sso[(WS-1)] != nsi[(WS-1)]) count = count + 1;
	      2'd2: if(sso[(WS-1)] != esi[(WS-1)]) count = count + 1;
	    endcase
	    case(c[7+8*(WS-1):6+8*(WS-1)])
	      2'd0: if(wso[(WS-1)] != nsi[(WS-1)]) count = count + 1;
	      2'd1: if(wso[(WS-1)] != esi[(WS-1)]) count = count + 1;
	      2'd2: if(wso[(WS-1)] != ssi[(WS-1)]) count = count + 1;
	    endcase
	 end
      end
   endgenerate

   localparam BASE = WS*8;
   generate
      for(k = 0; k < WD/4; k = k + 1) begin
	 always @(posedge clk) begin
	    case(c[BASE+k*16+1:BASE+k*16+0])
	      2'd0: if(ndo[k*2+0] != edi[WD/2+k*2+0]) count = count + 1;
	      2'd1: if(ndo[k*2+0] != sdi[WD/2+k*2+0]) count = count + 1;
	      2'd2: if(ndo[k*2+0] != wdi[k*2+1]) count = count + 1;
	    endcase
	    case(c[BASE+k*16+3:BASE+k*16+2])
	      2'd0: if(edo[WD/2+k*2+1] != sdi[WD/2+k*2+0]) count = count + 1;
	      2'd1: if(edo[WD/2+k*2+1] != wdi[k*2+1]) count = count + 1;
	      2'd2: if(edo[WD/2+k*2+1] != ndi[k*2+1]) count = count + 1;
	    endcase
	    case(c[BASE+k*16+5:BASE+k*16+4])
	      2'd0: if(sdo[WD/2+k*2+1] != wdi[k*2+1]) count = count + 1;
	      2'd1: if(sdo[WD/2+k*2+1] != ndi[k*2+1]) count = count + 1;
	      2'd2: if(sdo[WD/2+k*2+1] != edi[WD/2+k*2+0]) count = count + 1;
	    endcase
	    case(c[BASE+k*16+7:BASE+k*16+6])
	      2'd0: if(wdo[k*2+0] != ndi[k*2+1]) count = count + 1;
	      2'd1: if(wdo[k*2+0] != edi[WD/2+k*2+0]) count = count + 1;
	      2'd2: if(wdo[k*2+0] != sdi[WD/2+k*2+0]) count = count + 1;
	    endcase
	    case(c[BASE+k*16+9:BASE+k*16+8])
	      2'd0: if(ndo[k*2+1] != edi[WD/2+k*2+1]) count = count + 1;
	      2'd1: if(ndo[k*2+1] != sdi[WD/2+k*2+1]) count = count + 1;
	      2'd2: if(ndo[k*2+1] != wdi[k*2+0]) count = count + 1;
	    endcase
	    case(c[BASE+k*16+11:BASE+k*16+10])
	      2'd0: if(edo[WD/2+k*2+0] != sdi[WD/2+k*2+1]) count = count + 1;
	      2'd1: if(edo[WD/2+k*2+0] != wdi[k*2+0]) count = count + 1;
	      2'd2: if(edo[WD/2+k*2+0] != ndi[k*2+0]) count = count + 1;
	    endcase
	    case(c[BASE+k*16+13:BASE+k*16+12])
	      2'd0: if(sdo[WD/2+k*2+0] != wdi[k*2+0]) count = count + 1;
	      2'd1: if(sdo[WD/2+k*2+0] != ndi[k*2+0]) count = count + 1;
	      2'd2: if(sdo[WD/2+k*2+0] != edi[WD/2+k*2+1]) count = count + 1;
	    endcase
	    case(c[BASE+k*16+15:BASE+k*16+14])
	      2'd0: if(wdo[k*2+1] != ndi[k*2+0]) count = count + 1;
	      2'd1: if(wdo[k*2+1] != edi[WD/2+k*2+1]) count = count + 1;
	      2'd2: if(wdo[k*2+1] != sdi[WD/2+k*2+1]) count = count + 1;
	    endcase
	 end
      end
      if(WD/2%2) begin
	 always @ (posedge clk) begin
	    case(c[BASE+1+8*(WD/2-1):BASE+8*(WD/2-1)])
	      2'd0: if(ndo[(WD/2-1)] != edi[(WD-1)]) count = count + 1;
	      2'd1: if(ndo[(WD/2-1)] != sdi[(WD-1)]) count = count + 1;
	      2'd2: if(ndo[(WD/2-1)] != wdi[(WD/2-1)]) count = count + 1;
	    endcase
	    case(c[BASE+3+8*(WD/2-1):BASE+2+8*(WD/2-1)])
	      2'd0: if(edo[(WD-1)] != sdi[(WD-1)]) count = count + 1;
	      2'd1: if(edo[(WD-1)] != wdi[(WD/2-1)]) count = count + 1;
	      2'd2: if(edo[(WD-1)] != ndi[(WD/2-1)]) count = count + 1;
	    endcase
	    case(c[BASE+5+8*(WD/2-1):BASE+4+8*(WD/2-1)])
	      2'd0: if(sdo[(WD-1)] != wdi[(WD/2-1)]) count = count + 1;
	      2'd1: if(sdo[(WD-1)] != ndi[(WD/2-1)]) count = count + 1;
	      2'd2: if(sdo[(WD-1)] != edi[(WD-1)]) count = count + 1;
	    endcase
	    case(c[BASE+7+8*(WD/2-1):BASE+6+8*(WD/2-1)])
	      2'd0: if(wdo[(WD/2-1)] != ndi[(WD/2-1)]) count = count + 1;
	      2'd1: if(wdo[(WD/2-1)] != edi[(WD-1)]) count = count + 1;
	      2'd2: if(wdo[(WD/2-1)] != sdi[(WD-1)]) count = count + 1;
	    endcase
	 end
      end
   endgenerate

   always @(posedge clk) begin
      if(ndo[WD-1:WD/2] != sdi[WD/2-1:0]) count = count + 1;
      if(edo[WD/2-1:0] != wdi[WD-1:WD/2]) count = count + 1;
      if(sdo[WD/2-1:0] != ndi[WD-1:WD/2]) count = count + 1;
      if(wdo[WD-1:WD/2] != edi[WD/2-1:0]) count = count + 1;
   end

   integer   i, j;
   initial begin
      for(i = 0; i < 100; i = i + 1) begin
	 @(negedge clk);
	 nsi = $random;
	 esi = $random;
	 ssi = $random;
	 wsi = $random;
	 ndi = $random;
	 edi = $random;
	 sdi = $random;
	 wdi = $random;
	 for(j = 0; j < WS*8+WD/2*8; j = j + 1) begin
	    c[j] = $random;
	 end
      end
      
      @(negedge clk);
      if(count == 0) $display("PASS");
      else $display("FAIL %d", count);
      $finish;
   end

endmodule
