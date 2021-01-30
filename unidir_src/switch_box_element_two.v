module switch_box_element_two
  (
   input [1:0] north_in, east_in, south_in, west_in,
   output [1:0] north_out, east_out, south_out, west_out,
   input [15:0] c
   );

//   mux4 n0(.out(north_out[0]), .in0(east_in[0]), .in1(south_in[0]), .in2(west_in[1]), .in3(1'b0), .sel(c[1:0]));
//   mux4 e0(.out(east_out[1]), .in0(south_in[0]), .in1(west_in[1]), .in2(north_in[1]), .in3(1'b0), .sel(c[3:2]));
//   mux4 s0(.out(south_out[1]), .in0(west_in[1]), .in1(north_in[1]), .in2(east_in[0]), .in3(1'b0), .sel(c[5:4]));
//   mux4 w0(.out(west_out[0]), .in0(north_in[1]), .in1(east_in[0]), .in2(south_in[0]), .in3(1'b0), .sel(c[7:6]));
//   mux4 n1(.out(north_out[1]), .in0(east_in[1]), .in1(south_in[1]), .in2(west_in[0]), .in3(1'b0), .sel(c[9:8]));
//   mux4 e1(.out(east_out[0]), .in0(south_in[1]), .in1(west_in[0]), .in2(north_in[0]), .in3(1'b0), .sel(c[11:10]));
//   mux4 s1(.out(south_out[0]), .in0(west_in[0]), .in1(north_in[0]), .in2(east_in[1]), .in3(1'b0), .sel(c[13:12]));
//   mux4 w1(.out(west_out[1]), .in0(north_in[0]), .in1(east_in[1]), .in2(south_in[1]), .in3(1'b0), .sel(c[15:14]));

   mux4 n0(.out(north_out[0]), .in1(east_in[0]),  .in2(south_in[0]), .in3(west_in[1]),  .in0(1'bz), .sel(c[1:0]));
   mux4 e0(.out(east_out[1]),  .in1(south_in[0]), .in2(west_in[1]),  .in3(north_in[1]), .in0(1'bz), .sel(c[3:2]));
   mux4 s0(.out(south_out[1]), .in1(west_in[1]),  .in2(north_in[1]), .in3(east_in[0]),  .in0(1'bz), .sel(c[5:4]));
   mux4 w0(.out(west_out[0]),  .in1(north_in[1]), .in2(east_in[0]),  .in3(south_in[0]), .in0(1'bz), .sel(c[7:6]));
   mux4 n1(.out(north_out[1]), .in1(east_in[1]),  .in2(south_in[1]), .in3(west_in[0]),  .in0(1'bz), .sel(c[9:8]));
   mux4 e1(.out(east_out[0]),  .in1(south_in[1]), .in2(west_in[0]),  .in3(north_in[0]), .in0(1'bz), .sel(c[11:10]));
   mux4 s1(.out(south_out[0]), .in1(west_in[0]),  .in2(north_in[0]), .in3(east_in[1]),  .in0(1'bz), .sel(c[13:12]));
   mux4 w1(.out(west_out[1]),  .in1(north_in[0]), .in2(east_in[1]),  .in3(south_in[1]), .in0(1'bz), .sel(c[15:14]));

endmodule
