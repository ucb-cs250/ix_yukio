module data_connection_block
  #(
    // The number of fabric wires connecting to the MAC inputs.
    // The number of fabric wires connecting to the MAC outputs.
    parameter W = 16, // W must be multiple of WW
    // WW = WORD_WIDTH.
    parameter WW = 8,
    // 8: Four pairs of WW-bits coming in.
    parameter DATAIN = 8,
    // 4: Four big chungus (4*WW) outputs.
    parameter DATAOUT = 16,
    parameter CONF_WIDTH = W*(DATAIN+DATAOUT)
    ) 
   (
    input clk,
    input rst,
    input cset,
    input [CONF_WIDTH-1:0] c,

    inout [W-1:0] 	       north, south,
    // To MAC block.
    output [WW*DATAIN-1:0]     data_input,
    // From MAC block.
    input [WW*DATAOUT-1:0]     data_output
    );

   reg [CONF_WIDTH-1:0] c_reg;
   always @(posedge clk) begin
     if (rst)
       c_reg <= {CONF_WIDTH{1'b0}};
     else if (cset)
       c_reg <= c;
   end
   
   genvar 		       i, j;
   
   generate
      for(i = 0; i < W; i = i + 1) begin : wires
	 tran(north[i], south[i]);
      end
      
      for(i = 0; i < DATAIN; i = i + 1) begin : inputs
	 for(j = 0; j < W; j = j + 1) begin : switches
	    transmission_gate_oneway s(data_input[j%WW+i*WW], north[j], c_reg[j+i*W]);
	 end
      end
      
      for(i = 0; i < DATAOUT; i = i + 1) begin : outputs
	 for(j = 0; j < W; j = j + 1) begin : switches
	    transmission_gate_oneway s(north[j], data_output[j%WW+i*WW], c_reg[j+i*W+DATAIN*W]);
	 end
      end
   endgenerate
   
endmodule
