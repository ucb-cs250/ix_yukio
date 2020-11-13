module switch_box_connector
  #(
    parameter W0 = 5,
    parameter W1 = 7
    )
   (
    input [W0-1:0]  data0_in,
    output [W0-1:0] data0_out,
    input [W1-1:0]  data1_in,
    output [W1-1:0] data1_out
    );
   
   genvar 	   i, j;
   generate
      for(i = 0; i < W0; i = i + 1) begin
	 assign data0_out[i] = data1_in[i%W1];
      end
      for(i = 0; i < W1; i = i + 1) begin
	 assign data1_out[i] = data0_in[i%W0];
      end
   endgenerate
   
endmodule
