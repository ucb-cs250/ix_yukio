module switch_box_connector
  #(
    parameter W0 = 5,
    parameter W1 = 7
    )
   (
    inout [W0-1:0] data0,
    inout [W1-1:0] data1
    );

   genvar 	   i, j;
   generate
      if(W0 < W1) begin
	 for(i = 0; i < W1; i = i + 1) begin
	    tran(data1[i], data0[i%W0]);
	 end
      end else begin
	 for(i = 0; i < W0; i = i + 1) begin
	    tran(data1[i%W1], data0[i]);
	 end
      end
   endgenerate
   
endmodule
