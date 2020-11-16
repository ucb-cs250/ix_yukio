module muxn #(
	      parameter N = 4,
	      parameter LOG2N = $clog2(N))
   (
    output reg 	      out,
    input [N-1:0]     in,
    input [LOG2N-1:0] sel
    );

   integer 	      i;
   always @(*) begin
      out = 1'b0;
      for(i = 0; i < N; i = i + 1) begin
	 if(sel == i) out = in[i];
      end
   end

endmodule
