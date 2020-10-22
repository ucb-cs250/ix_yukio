module mux4(output reg  out, input in0, in1, in2, in3, input [1:0] sel);
   
   always @(*) begin
      case(sel)
	2'd0: out = in0;
	2'd1: out = in1;
	2'd2: out = in2;
	2'd3: out = in3;
      endcase
   end

endmodule
