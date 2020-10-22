module mux2(output reg  out, input in0, in1, input sel);
   
   always @(*) begin
      case(sel)
	2'd0: out = in0;
	2'd1: out = in1;
      endcase
   end

endmodule
