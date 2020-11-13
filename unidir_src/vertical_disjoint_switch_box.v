// We don't need to disjoint north and south when using unidirectional wires. So, this module just connects north and south.
module vertical_disjoint_switch_box 
  #(
    parameter W = 8
    ) 
   (
    input [W-1:0]  north_in, south_in,
    output [W-1:0] north_out, south_out
    );
   
   assign north_out = south_in;
   assign south_out = north_in;
   
endmodule
