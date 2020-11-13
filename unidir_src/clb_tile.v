module clb_tile
  #(
    // parameters from top module
    parameter WS = 4,
    parameter WD = 4, // WD must be multiple of 2
    parameter WG = 3,
    parameter CLBOS = 2, // CLBOS must be less than or equal to WS
    parameter CLBOD = 2, // CLBOD must be less than or equal to WD
    parameter CLBIOTYPE = 0, // 0 ... anyside with MUX, 1 ... left to right or right to left with MUX, 2 ... divided (CLBIN and CLBOUT must be multiple of 4)
    parameter CLBX = 1, // 0 or 1 to toggle using direct connection between adjacent CLBs
    parameter CARRYTYPE = 2, // 0 ... anyside with MUX, 1 ... vertical two-way and horizontal one-way only at the top and bottom with MUX, 2 ... one-way meandering (top to bottom -> left to right -> bottom to top -> left to right -> ...)
    parameter NORTHMOST = 0, // boolean
    parameter EASTMOST = 0, // boolean
    parameter SOUTHMOST = 0, // boolean
    parameter WESTMOST = 0, // boolean
    parameter ROW = 5, // the row index of the tile (this affects which switches CLB outputs are connected)
    parameter COLUMN = 3, // the column index of the tile (this affects which switches CLB outputs are connected)
    // parameters for sub modules
    parameter CLBIN = 4,
    parameter CLBOUT = 4,
    parameter CARRY = 1, // bit-width of carry
    // useful parameters
    parameter CONF_SB = (WS+WD/2)*8,
    parameter CLBIN0H = (NORTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
    parameter CLBIN1H = (CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
    parameter CLBOUT0H = (NORTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
    parameter CLBOUT1H = (CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
    parameter SEL_PER_IN0H = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT1H),
    parameter SEL_PER_IN1H = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT0H),
    parameter SEL_PER_OUTH = $clog2(CLBOUT0H+CLBOUT1H+1),
    parameter CONF_HCB = SEL_PER_OUTH*2*(CLBOS+CLBOD)+SEL_PER_IN0H*CLBIN0H+SEL_PER_IN1H*CLBIN1H,
    parameter CLBIN0V = (EASTMOST? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
    parameter CLBIN1V = (CLBIOTYPE == 2? CLBIN/4: CLBIN),
    parameter CLBOUT0V = (EASTMOST? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
    parameter CLBOUT1V = (CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
    parameter SEL_PER_IN0V = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT1V),
    parameter SEL_PER_IN1V = $clog2((WS + WD) * 2 + WG + CLBX * CLBOUT0V),
    parameter SEL_PER_OUTV = $clog2(CLBOUT0V+CLBOUT1V+1),
    parameter CONF_VCB = SEL_PER_OUTV*2*(CLBOS+CLBOD)+SEL_PER_IN0V*CLBIN0V+SEL_PER_IN1V*CLBIN1V
    )
   (
    input [WS-1:0] 	 north_single_in,
    input [WD-1:0] 	 north_double_in,
    input [CLBOUT-1:0] 	 north_clb_output,
    input [CARRY-1:0] 	 north_clb_cout, 
    output [WS-1:0] 	 north_single_out,
    output [WD-1:0] 	 north_double_out,
    output [CLBIN-1:0] 	 north_clb_input,
    output [CARRY-1:0] 	 north_clb_cin,

    input [WS-1:0] 	 east_single_in,
    input [WD-1:0] 	 east_double_in,
    input [CLBOUT-1:0] 	 east_clb_output,
    input [CARRY-1:0] 	 east_clb_cout, 
    output [WS-1:0] 	 east_single_out,
    output [WD-1:0] 	 east_double_out,
    output [CLBIN-1:0] 	 east_clb_input,
    output [CARRY-1:0] 	 east_clb_cin,

    input [WS-1:0] 	 south_single_in,
    input [WD-1:0] 	 south_double_in,
    input [CLBOUT-1:0] 	 south_clb_output,
    input [CARRY-1:0] 	 south_clb_cout, 
    output [WS-1:0] 	 south_single_out,
    output [WD-1:0] 	 south_double_out,
    output [CLBIN-1:0] 	 south_clb_input,
    output [CARRY-1:0] 	 south_clb_cin,

    input [WS-1:0] 	 west_single_in,
    input [WD-1:0] 	 west_double_in,
    input [CLBOUT-1:0] 	 west_clb_output,
    input [CARRY-1:0] 	 west_clb_cout, 
    output [WS-1:0] 	 west_single_out,
    output [WD-1:0] 	 west_double_out,
    output [CLBIN-1:0] 	 west_clb_input,
    output [CARRY-1:0] 	 west_clb_cin,
   
    input [WG-1:0] 	 horizontal_global,
    input [WG-1:0] 	 vertical_global,

    input [CONF_SB-1:0]  conf_sb,
    input [CONF_HCB-1:0] conf_hcb,
    input [CONF_VCB-1:0] conf_vcb,

    input [2*CLBIN-1:0]  conf_io_type0,
    input [CLBIN-1:0] 	 conf_io_type1,
    input [2*CARRY-1:0]  conf_cin_type0,
    input [CARRY-1:0]  conf_cin_type1
    );
      
   // wires for switch box
   wire [WS-1:0]       switch_box_south_single_in;
   wire [WD-1:0]       switch_box_south_double_in;
   wire [WS-1:0]       switch_box_west_single_in;
   wire [WD-1:0]       switch_box_west_double_in;
   wire [WS-1:0]       switch_box_south_single_out;
   wire [WD-1:0]       switch_box_south_double_out;
   wire [WS-1:0]       switch_box_west_single_out;
   wire [WD-1:0]       switch_box_west_double_out;
   
   // wires for clbs   
   wire [CLBIN-1:0]    clb_input;
   wire [CLBIN-1:0]    clb_input_north;
   wire [CLBIN-1:0]    clb_input_east;
   wire [CLBIN-1:0]    clb_input_south;
   wire [CLBIN-1:0]    clb_input_west;
   wire [CLBOUT-1:0]   clb_output;
   wire [CLBOUT-1:0]   clb_output_north;
   wire [CLBOUT-1:0]   clb_output_east;
   wire [CLBOUT-1:0]   clb_output_south;
   wire [CLBOUT-1:0]   clb_output_west;
   wire [CARRY-1:0]    clb_cin;
   wire [CARRY-1:0]    clb_cin_north;
   wire [CARRY-1:0]    clb_cin_east;
   wire [CARRY-1:0]    clb_cin_south;
   wire [CARRY-1:0]    clb_cin_west;
   wire [CARRY-1:0]    clb_cout;

   genvar 	       l;
   
   // switch box
   clb_switch_box 
     #(
       .WS(WS),
       .WD(WD)
       )
   sb
     (
      .north_single_in(north_single_in),
      .east_single_in(east_single_in),
      .south_single_in(switch_box_south_single_in),
      .west_single_in(switch_box_west_single_in),
      .north_double_in(north_double_in),
      .east_double_in(east_double_in),
      .south_double_in(switch_box_south_double_in),
      .west_double_in(switch_box_west_double_in),
      .north_single_out(north_single_out),
      .east_single_out(east_single_out),
      .south_single_out(switch_box_south_single_out),
      .west_single_out(switch_box_west_single_out),
      .north_double_out(north_double_out),
      .east_double_out(east_double_out),
      .south_double_out(switch_box_south_double_out),
      .west_double_out(switch_box_west_double_out),
      .c(conf_sb)
      );

   // clb
   clb
     #(
       .CLBIN(CLBIN),
       .CLBOUT(CLBOUT),
       .CARRY(CARRY)
       )
   clb0
     (
      .inputs(clb_input),
      .outputs(clb_output),
      .cin(clb_cin),
      .cout(clb_cout)
      );
   
   // clb io
   generate
      if(CLBIOTYPE == 0) begin : clb_io_type0
	 assign clb_output_north = clb_output;
	 assign clb_output_east = clb_output;
	 assign clb_output_south = clb_output;
	 assign clb_output_west = clb_output;
	 for(l = 0; l < CLBIN; l = l + 1) begin
	    mux4 m (
		    clb_input[l],
		    clb_input_north[l],
		    clb_input_east[l],
		    clb_input_south[l],
		    clb_input_west[l],
		    conf_io_type0[2*l+1:2*l]
		    );
	 end
      end else if(CLBIOTYPE == 1) begin : clb_io_type1
	 assign clb_output_east = clb_output;
	 assign clb_output_west = clb_output;
	 for(l = 0; l < CLBIN; l = l + 1) begin
	    mux2 m (
		    clb_input[l],
		    clb_input_east[l],
		    clb_input_west[l],
		    conf_io_type1[l]
		    );
	 end
      end else if(CLBIOTYPE == 2) begin : clb_io_type2
	 assign clb_output_north[CLBOUT/4-1:0] = clb_output[CLBOUT/4-1:0];
	 assign clb_output_east[CLBOUT/4-1:0] = clb_output[CLBOUT/2-1:CLBOUT/4];
	 assign clb_output_south[CLBOUT/4-1:0] = clb_output[CLBOUT/4*3-1:CLBOUT/2];
	 assign clb_output_west[CLBOUT/4-1:0] = clb_output[CLBOUT-1:CLBOUT/4*3];
	 assign clb_input = {clb_input_west[CLBIN/4-1:0],
			     clb_input_south[CLBIN/4-1:0],
			     clb_input_east[CLBIN/4-1:0],
			     clb_input_north[CLBIN/4-1:0]};
      end      
   endgenerate

   // carry
   generate
      if(CARRYTYPE == 0) begin : clb_cin_type0
	 for(l = 0; l < CARRY; l = l + 1) begin
	    mux4 m (
		    clb_cin[l],
		    clb_cin_north[l],
		    clb_cin_east[l],
		    clb_cin_south[l],
		    clb_cin_west[l],
		    conf_cin_type0[2*l+1:2*l]
		    );
	 end
      end else if(CARRYTYPE == 1) begin : clb_cin_type1
	 if(NORTHMOST) begin
	    for(l = 0; l < CARRY; l = l + 1) begin
	       mux2 m (
		       clb_cin[l],
		       clb_cin_east[l],
		       clb_cin_south[l],
		       conf_cin_type1[l]
		       );
	    end
	 end else if(SOUTHMOST) begin
	    for(l = 0; l < CARRY; l = l + 1) begin
	       mux2 m (
		       clb_cin[l],
		       clb_cin_north[l],
		       clb_cin_east[l],
		       conf_cin_type1[l]
		       );
	    end
	 end else begin
	    for(l = 0; l < CARRY; l = l + 1) begin
	       mux2 m (
		       clb_cin[l],
		       clb_cin_north[l],
		       clb_cin_south[l],
		       conf_cin_type1[l]
		       );
	    end
	 end
      end else if(CARRYTYPE == 2) begin : clb_cin_type2
	 if(NORTHMOST || SOUTHMOST) begin
	    assign clb_cin = clb_cin_east;
	 end else if (COLUMN%2 == 0) begin
	    assign clb_cin = clb_cin_north;
	 end else begin
	    assign clb_cin = clb_cin_south;
	 end
      end   
   endgenerate

   // horizontal connection block
   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIN0H),
       .CLBIN1(CLBIN1H),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBOUT0H),
       .CLBOUT1(CLBOUT1H),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(COLUMN),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(COLUMN/2),
       .CLBX(CLBX)
       )
   hcb (
	.single0_in(switch_box_west_single_out),
	.single0_out(switch_box_west_single_in),
	.single1_in(west_single_in),
	.single1_out(west_single_out),
	.double0_in(switch_box_west_double_out),
	.double0_out(switch_box_west_double_in),
	.double1_in(west_double_in),
	.double1_out(west_double_out),
	.global(horizontal_global),
	.clb0_output(north_clb_output),
	.clb1_output(clb_output_north),
	.clb0_cout(north_clb_cout),
	.clb1_cout(clb_cout),
	.clb0_input(north_clb_input),
	.clb1_input(clb_input_north),
	.clb0_cin(north_clb_cin),
	.clb1_cin(clb_cin_north),
	.c(conf_hcb)
	);
   

   // vertical connection block
   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIN0V),
       .CLBIN1(CLBIN1V),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBOUT0V),
       .CLBOUT1(CLBOUT1V),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(ROW),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(ROW/2),
       .CLBX(CLBX)
       )
   vcb (
	.single0_in(switch_box_south_single_out),
	.single0_out(switch_box_south_single_in),
	.single1_in(south_single_in),
	.single1_out(south_single_out),
	.double0_in(switch_box_south_double_out),
	.double0_out(switch_box_south_double_in),
	.double1_in(south_double_in),
	.double1_out(south_double_out),
	.global(vertical_global),
	.clb0_output(east_clb_output),
	.clb1_output(clb_output_east),
	.clb0_cout(east_clb_cout),
	.clb1_cout(clb_cout),
	.clb0_input(east_clb_input),
	.clb1_input(clb_input_east),
	.clb0_cin(east_clb_cin),
	.clb1_cin(clb_cin_east),
	.c(conf_vcb)
	);
endmodule

