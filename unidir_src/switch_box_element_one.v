module switch_box_element_one
  (
   input       north_in, east_in, south_in, west_in,
   output      north_out, east_out, south_out, west_out,
   input [7:0] c
   );

   mux4 n(.out(north_out), .in0(east_in), .in1(south_in), .in2(west_in), .in3(1'b0), .sel(c[1:0]));
   mux4 e(.out(east_out), .in0(south_in), .in1(west_in), .in2(north_in), .in3(1'b0), .sel(c[3:2]));
   mux4 s(.out(south_out), .in0(west_in), .in1(north_in), .in2(east_in), .in3(1'b0), .sel(c[5:4]));
   mux4 w(.out(west_out), .in0(north_in), .in1(east_in), .in2(south_in), .in3(1'b0), .sel(c[7:6]));
   
endmodule
