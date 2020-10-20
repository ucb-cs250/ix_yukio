module switch_box_element_one
  (
   inout north, east, south, west,
   input [5:0] c
   );

   transmission_gate ne(east, north, c[0]);
   transmission_gate es(south, east, c[1]);
   transmission_gate sw(west, south, c[2]);
   transmission_gate wn(north, west, c[3]);
   transmission_gate ns(south, north, c[4]);
   transmission_gate ew(west, east, c[5]);
   
endmodule
