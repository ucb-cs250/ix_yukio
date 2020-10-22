module mac
  #(
    parameter WW = 4,
    parameter MACDATAIN = 2,
    parameter MACDATAOUT = 1,
    parameter MACCONTROLIN = 2
    )
   (
    input [WW*MACDATAIN-1:0] inputs,
    output [WW*MACDATAOUT-1:0] outputs,
    input [MACCONTROLIN-1:0] control_inputs
    );

endmodule
