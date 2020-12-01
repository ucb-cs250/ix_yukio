(* blackbox *)
module disjoint_switch_box 
  #(
    // The number of fabric wires out each side.
    parameter W = 8,
    // There are 6 switches in each of the switch_box_element_ones.
    parameter CONF_WIDTH = 6*W
    ) 
   (
    input clk,
    input rst,
    input cset,
    input [CONF_WIDTH-1:0] c,

    inout [W-1:0]   north, east, south, west
    );
endmodule
