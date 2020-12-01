module data_connection_block
  #(
    // The number of fabric wires connecting to the MAC inputs.
    // The number of fabric wires connecting to the MAC outputs.
    parameter W = 192, // W must be multiple of WW
    // WW = WORD_WIDTH.
    parameter WW = 8,
    // 8: Four pairs of WW-bits coming in.
    parameter DATAIN = 8,
    // 4: Four big chungus (4*WW) outputs.
    parameter DATAOUT = 8,
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
endmodule
