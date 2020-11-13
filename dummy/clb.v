module clb
  #(
    parameter CLBIN = 3,
    parameter CLBOUT = 2,
    parameter CARRY = 1
    )
   (
    input [CLBIN-1:0] inputs,
    output [CLBOUT-1:0] outputs,
    input [CARRY-1:0] cin,
    output [CARRY-1:0] cout
    );

endmodule
