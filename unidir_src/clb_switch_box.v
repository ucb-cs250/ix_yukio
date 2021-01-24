module clb_switch_box #(
  // the number of pairs of in and out for single wires each side
  parameter WS = 8,
  // the number of pairs of in and out for double wires each side, must be multiple of 2.
  parameter WD = 8,
  parameter CONF_WIDTH = (WS+WD/2)*8
) (
  input  [WS-1:0] 	       north_single_in, east_single_in, south_single_in, west_single_in,
  output [WS-1:0] 	       north_single_out, east_single_out, south_single_out, west_single_out,
  input  [WD-1:0] 	       north_double_in, east_double_in, south_double_in, west_double_in,
  output [WD-1:0] 	       north_double_out, east_double_out, south_double_out, west_double_out,
  input  [(WS+WD/2)*8-1:0] c
);

  universal_switch_box #(
    .W(WS)
  ) susb (
    .north_in(north_single_in),
    .east_in(east_single_in),
    .south_in(south_single_in),
    .west_in(west_single_in),
    .north_out(north_single_out),
    .east_out(east_single_out),
    .south_out(south_single_out),
    .west_out(west_single_out),
    .c(c[WS*8-1:0]));

  universal_switch_box #(
    .W(WD/2)
  ) dusb (
    .north_in(north_double_in[WD/2-1:0]),
    .east_in(east_double_in[WD-1:WD/2]),
    .south_in(south_double_in[WD-1:WD/2]),
    .west_in(west_double_in[WD/2-1:0]),
    .north_out(north_double_out[WD/2-1:0]),
    .east_out(east_double_out[WD-1:WD/2]),
    .south_out(south_double_out[WD-1:WD/2]),
    .west_out(west_double_out[WD/2-1:0]),
    .c(c[(WS+WD/2)*8-1:WS*8]));

  genvar i;
  generate
    for(i = 0; i < WD / 2; i = i + 1) begin : double_direct_connection
      assign north_double_out[i+WD/2] = south_double_in[i];
      assign east_double_out[i] = west_double_in[i+WD/2];
      assign south_double_out[i] = north_double_in[i+WD/2];
      assign west_double_out[i+WD/2] = east_double_in[i];
    end
  endgenerate

endmodule
