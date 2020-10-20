module switch_box_element_one
  (
   inout north, east, south, west,
   input [5:0] c
   );

   tranif1(east, north, c[0]);
   tranif1(south, east, c[1]);
   tranif1(west, south, c[2]);
   tranif1(north, west, c[3]);
   tranif1(south, north, c[4]);
   tranif1(west, east, c[5]);
   
endmodule
