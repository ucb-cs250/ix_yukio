module mux2(output reg  out, input in0, in1, input sel);
   
   always @(*) begin
      case(sel)
	1'b0: out = in0;
	1'b1: out = in1;
      endcase
   end

endmodule
