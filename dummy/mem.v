module mem
  #(
    parameter WW = 4,
    parameter MEMDATAIN = 2,
    parameter MEMDATAOUT = 1,
    parameter MEMCONTROLIN = 2
    )
   (
    input [WW*MEMDATAIN-1:0] inputs,
    output [WW*MEMDATAOUT-1:0] outputs,
    input [MEMCONTROLIN-1:0] control_inputs
    );

endmodule
