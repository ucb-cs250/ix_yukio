module switch_box_element_two
  (
   inout [1:0] north, east, south, west,
   input [11:0] c
   );

   tranif1(east[0], north[0], c[0]);
   tranif1(south[0], east[1], c[1]);
   tranif1(west[1], south[1], c[2]);
   tranif1(north[1], west[0], c[3]);
   
   tranif1(south[0], north[0], c[4]);
   tranif1(west[1], east[1], c[5]);
   tranif1(north[1], south[1], c[6]);
   tranif1(east[0], west[0], c[7]);
   
   tranif1(east[1], north[1], c[8]);
   tranif1(south[1], east[0], c[9]);
   tranif1(west[0], south[0], c[10]);
   tranif1(north[0], west[1], c[11]);
   
endmodule
