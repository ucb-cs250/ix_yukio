module fpga
  #(
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
    parameter COLUMN = 3 // the column index of the tile (this affects which switches CLB outputs are connected)
    )
   (

    );
   
   // parameters from modules
   localparam CLBIN = 4;
   localparam CLBOUT = 4;
   localparam CARRY = 1; // bit-width of carry

   // wires for switch boxes
   wire [WS-1:0] switch_box_00_north_single;
   wire [WD-1:0] switch_box_00_north_double;
   wire [WS-1:0] switch_box_00_east_single;
   wire [WD-1:0] switch_box_00_east_double;
   wire [WS-1:0] switch_box_00_south_single;
   wire [WD-1:0] switch_box_00_south_double;
   wire [WS-1:0] switch_box_00_west_single;
   wire [WD-1:0] switch_box_00_west_double;

   wire [WS-1:0] switch_box_01_north_single;
   wire [WD-1:0] switch_box_01_north_double;
   wire [WS-1:0] switch_box_01_east_single;
   wire [WD-1:0] switch_box_01_east_double;
   wire [WS-1:0] switch_box_01_south_single;
   wire [WD-1:0] switch_box_01_south_double;
   wire [WS-1:0] switch_box_01_west_single;
   wire [WD-1:0] switch_box_01_west_double;

   wire [WS-1:0] switch_box_02_north_single;
   wire [WD-1:0] switch_box_02_north_double;
   wire [WS-1:0] switch_box_02_east_single;
   wire [WD-1:0] switch_box_02_east_double;
   wire [WS-1:0] switch_box_02_south_single;
   wire [WD-1:0] switch_box_02_south_double;
   wire [WS-1:0] switch_box_02_west_single;
   wire [WD-1:0] switch_box_02_west_double;

   wire [WS-1:0] switch_box_10_north_single;
   wire [WD-1:0] switch_box_10_north_double;
   wire [WS-1:0] switch_box_10_east_single;
   wire [WD-1:0] switch_box_10_east_double;
   wire [WS-1:0] switch_box_10_south_single;
   wire [WD-1:0] switch_box_10_south_double;
   wire [WS-1:0] switch_box_10_west_single;
   wire [WD-1:0] switch_box_10_west_double;

   wire [WS-1:0] switch_box_11_north_single;
   wire [WD-1:0] switch_box_11_north_double;
   wire [WS-1:0] switch_box_11_east_single;
   wire [WD-1:0] switch_box_11_east_double;
   wire [WS-1:0] switch_box_11_south_single;
   wire [WD-1:0] switch_box_11_south_double;
   wire [WS-1:0] switch_box_11_west_single;
   wire [WD-1:0] switch_box_11_west_double;

   wire [WS-1:0] switch_box_12_north_single;
   wire [WD-1:0] switch_box_12_north_double;
   wire [WS-1:0] switch_box_12_east_single;
   wire [WD-1:0] switch_box_12_east_double;
   wire [WS-1:0] switch_box_12_south_single;
   wire [WD-1:0] switch_box_12_south_double;
   wire [WS-1:0] switch_box_12_west_single;
   wire [WD-1:0] switch_box_12_west_double;

   // wires for clbs   
   wire [CLBIN-1:0] clb_11_input;
   wire [CLBIN-1:0] clb_11_input_north;
   wire [CLBIN-1:0] clb_11_input_east;
   wire [CLBIN-1:0] clb_11_input_south;
   wire [CLBIN-1:0] clb_11_input_west;
   wire [CLBOUT-1:0] clb_11_output;
   wire [CLBOUT-1:0] clb_11_output_north;
   wire [CLBOUT-1:0] clb_11_output_east;
   wire [CLBOUT-1:0] clb_11_output_south;
   wire [CLBOUT-1:0] clb_11_output_west;
   wire [CARRY-1:0] clb_11_cin;
   wire [CARRY-1:0] clb_11_cin_north;
   wire [CARRY-1:0] clb_11_cin_east;
   wire [CARRY-1:0] clb_11_cin_south;
   wire [CARRY-1:0] clb_11_cin_west;
   wire [CARRY-1:0] clb_11_cout;

   wire [CLBIN-1:0] clb_12_input;
   wire [CLBIN-1:0] clb_12_input_north;
   wire [CLBIN-1:0] clb_12_input_east;
   wire [CLBIN-1:0] clb_12_input_south;
   wire [CLBIN-1:0] clb_12_input_west;
   wire [CLBOUT-1:0] clb_12_output;
   wire [CLBOUT-1:0] clb_12_output_north;
   wire [CLBOUT-1:0] clb_12_output_east;
   wire [CLBOUT-1:0] clb_12_output_south;
   wire [CLBOUT-1:0] clb_12_output_west;
   wire [CARRY-1:0] clb_12_cin;
   wire [CARRY-1:0] clb_12_cin_north;
   wire [CARRY-1:0] clb_12_cin_east;
   wire [CARRY-1:0] clb_12_cin_south;
   wire [CARRY-1:0] clb_12_cin_west;
   wire [CARRY-1:0] clb_12_cout;

   // dummy wires for adjacent clbs outside of the tile
   wire [CLBIN-1:0] clb_01_input;
   wire [CLBIN-1:0] clb_01_input_north;
   wire [CLBIN-1:0] clb_01_input_east;
   wire [CLBIN-1:0] clb_01_input_south;
   wire [CLBIN-1:0] clb_01_input_west;
   wire [CLBOUT-1:0] clb_01_output;
   wire [CLBOUT-1:0] clb_01_output_north;
   wire [CLBOUT-1:0] clb_01_output_east;
   wire [CLBOUT-1:0] clb_01_output_south;
   wire [CLBOUT-1:0] clb_01_output_west;
   wire [CARRY-1:0] clb_01_cin;
   wire [CARRY-1:0] clb_01_cin_north;
   wire [CARRY-1:0] clb_01_cin_east;
   wire [CARRY-1:0] clb_01_cin_south;
   wire [CARRY-1:0] clb_01_cin_west;
   wire [CARRY-1:0] clb_01_cout;

   wire [CLBIN-1:0] clb_02_input;
   wire [CLBIN-1:0] clb_02_input_north;
   wire [CLBIN-1:0] clb_02_input_east;
   wire [CLBIN-1:0] clb_02_input_south;
   wire [CLBIN-1:0] clb_02_input_west;
   wire [CLBOUT-1:0] clb_02_output;
   wire [CLBOUT-1:0] clb_02_output_north;
   wire [CLBOUT-1:0] clb_02_output_east;
   wire [CLBOUT-1:0] clb_02_output_south;
   wire [CLBOUT-1:0] clb_02_output_west;
   wire [CARRY-1:0] clb_02_cin;
   wire [CARRY-1:0] clb_02_cin_north;
   wire [CARRY-1:0] clb_02_cin_east;
   wire [CARRY-1:0] clb_02_cin_south;
   wire [CARRY-1:0] clb_02_cin_west;
   wire [CARRY-1:0] clb_02_cout;

   wire [CLBIN-1:0] clb_10_input;
   wire [CLBIN-1:0] clb_10_input_north;
   wire [CLBIN-1:0] clb_10_input_east;
   wire [CLBIN-1:0] clb_10_input_south;
   wire [CLBIN-1:0] clb_10_input_west;
   wire [CLBOUT-1:0] clb_10_output;
   wire [CLBOUT-1:0] clb_10_output_north;
   wire [CLBOUT-1:0] clb_10_output_east;
   wire [CLBOUT-1:0] clb_10_output_south;
   wire [CLBOUT-1:0] clb_10_output_west;
   wire [CARRY-1:0] clb_10_cin;
   wire [CARRY-1:0] clb_10_cin_north;
   wire [CARRY-1:0] clb_10_cin_east;
   wire [CARRY-1:0] clb_10_cin_south;
   wire [CARRY-1:0] clb_10_cin_west;
   wire [CARRY-1:0] clb_10_cout;

   wire [CLBIN-1:0] clb_13_input;
   wire [CLBIN-1:0] clb_13_input_north;
   wire [CLBIN-1:0] clb_13_input_east;
   wire [CLBIN-1:0] clb_13_input_south;
   wire [CLBIN-1:0] clb_13_input_west;
   wire [CLBOUT-1:0] clb_13_output;
   wire [CLBOUT-1:0] clb_13_output_north;
   wire [CLBOUT-1:0] clb_13_output_east;
   wire [CLBOUT-1:0] clb_13_output_south;
   wire [CLBOUT-1:0] clb_13_output_west;
   wire [CARRY-1:0] clb_13_cin;
   wire [CARRY-1:0] clb_13_cin_north;
   wire [CARRY-1:0] clb_13_cin_east;
   wire [CARRY-1:0] clb_13_cin_south;
   wire [CARRY-1:0] clb_13_cin_west;
   wire [CARRY-1:0] clb_13_cout;
   
   wire [CLBIN-1:0] clb_21_input;
   wire [CLBIN-1:0] clb_21_input_north;
   wire [CLBIN-1:0] clb_21_input_east;
   wire [CLBIN-1:0] clb_21_input_south;
   wire [CLBIN-1:0] clb_21_input_west;
   wire [CLBOUT-1:0] clb_21_output;
   wire [CLBOUT-1:0] clb_21_output_north;
   wire [CLBOUT-1:0] clb_21_output_east;
   wire [CLBOUT-1:0] clb_21_output_south;
   wire [CLBOUT-1:0] clb_21_output_west;
   wire [CARRY-1:0] clb_21_cin;
   wire [CARRY-1:0] clb_21_cin_north;
   wire [CARRY-1:0] clb_21_cin_east;
   wire [CARRY-1:0] clb_21_cin_south;
   wire [CARRY-1:0] clb_21_cin_west;
   wire [CARRY-1:0] clb_21_cout;

   wire [CLBIN-1:0] clb_22_input;
   wire [CLBIN-1:0] clb_22_input_north;
   wire [CLBIN-1:0] clb_22_input_east;
   wire [CLBIN-1:0] clb_22_input_south;
   wire [CLBIN-1:0] clb_22_input_west;
   wire [CLBOUT-1:0] clb_22_output;
   wire [CLBOUT-1:0] clb_22_output_north;
   wire [CLBOUT-1:0] clb_22_output_east;
   wire [CLBOUT-1:0] clb_22_output_south;
   wire [CLBOUT-1:0] clb_22_output_west;
   wire [CARRY-1:0] clb_22_cin;
   wire [CARRY-1:0] clb_22_cin_north;
   wire [CARRY-1:0] clb_22_cin_east;
   wire [CARRY-1:0] clb_22_cin_south;
   wire [CARRY-1:0] clb_22_cin_west;
   wire [CARRY-1:0] clb_22_cout;

   // global wires
   wire [WG-1:0]    horizontal_global_0;
   wire [WG-1:0]    horizontal_global_1;
   
   wire [WG-1:0]    vertical_global_0;
   wire [WG-1:0]    vertical_global_1;
   wire [WG-1:0]    vertical_global_2;
   
   genvar 	    l;
   
   // switch box
   clb_switch_box 
     #(
       .WS(WS),
       .WD(WD)
       )
   sbox_00
     (
      .north_single(switch_box_00_north_single),
      .east_single(switch_box_00_east_single),
      .south_single(switch_box_00_south_single),
      .west_single(switch_box_00_west_single),
      .north_double(switch_box_00_north_double),
      .east_double(switch_box_00_east_double),
      .south_double(switch_box_00_south_double),
      .west_double(switch_box_00_west_double),
      .c()
      );
   clb_switch_box 
     #(
       .WS(WS),
       .WD(WD)
       )
   sbox_01
     (
      .north_single(switch_box_01_north_single),
      .east_single(switch_box_01_east_single),
      .south_single(switch_box_01_south_single),
      .west_single(switch_box_01_west_single),
      .north_double(switch_box_01_north_double),
      .east_double(switch_box_01_east_double),
      .south_double(switch_box_01_south_double),
      .west_double(switch_box_01_west_double),
      .c()
      );
   clb_switch_box 
     #(
       .WS(WS),
       .WD(WD)
       )
   sbox_02
     (
      .north_single(switch_box_02_north_single),
      .east_single(switch_box_02_east_single),
      .south_single(switch_box_02_south_single),
      .west_single(switch_box_02_west_single),
      .north_double(switch_box_02_north_double),
      .east_double(switch_box_02_east_double),
      .south_double(switch_box_02_south_double),
      .west_double(switch_box_02_west_double),
      .c()
      );
   clb_switch_box 
     #(
       .WS(WS),
       .WD(WD)
       )
   sbox_10
     (
      .north_single(switch_box_10_north_single),
      .east_single(switch_box_10_east_single),
      .south_single(switch_box_10_south_single),
      .west_single(switch_box_10_west_single),
      .north_double(switch_box_10_north_double),
      .east_double(switch_box_10_east_double),
      .south_double(switch_box_10_south_double),
      .west_double(switch_box_10_west_double),
      .c()
      );
   clb_switch_box 
     #(
       .WS(WS),
       .WD(WD)
       )
   sbox_11
     (
      .north_single(switch_box_11_north_single),
      .east_single(switch_box_11_east_single),
      .south_single(switch_box_11_south_single),
      .west_single(switch_box_11_west_single),
      .north_double(switch_box_11_north_double),
      .east_double(switch_box_11_east_double),
      .south_double(switch_box_11_south_double),
      .west_double(switch_box_11_west_double),
      .c()
      );
   clb_switch_box 
     #(
       .WS(WS),
       .WD(WD)
       )
   sbox_12
     (
      .north_single(switch_box_12_north_single),
      .east_single(switch_box_12_east_single),
      .south_single(switch_box_12_south_single),
      .west_single(switch_box_12_west_single),
      .north_double(switch_box_12_north_double),
      .east_double(switch_box_12_east_double),
      .south_double(switch_box_12_south_double),
      .west_double(switch_box_12_west_double),
      .c()
      );
   
   // clb
   clb
     #(
       .CLBIN(CLBIN),
       .CLBOUT(CLBOUT),
       .CARRY(CARRY)
       )
   clb_11
     (
      .inputs(clb_11_input),
      .outputs(clb_11_output),
      .cin(clb_11_cin),
      .cout(clb_11_cout)
      );
   clb
     #(
       .CLBIN(CLBIN),
       .CLBOUT(CLBOUT),
       .CARRY(CARRY)
       )
   clb_12
     (
      .inputs(clb_12_input),
      .outputs(clb_12_output),
      .cin(clb_12_cin),
      .cout(clb_12_cout)
      );

   
   // clb io
   generate
      if(CLBIOTYPE == 0) begin : clb_io_type0
	 assign clb_11_output_north = clb_11_output;
	 assign clb_11_output_east = clb_11_output;
	 assign clb_11_output_south = clb_11_output;
	 assign clb_11_output_west = clb_11_output;
	 assign clb_12_output_north = clb_12_output;
	 assign clb_12_output_east = clb_12_output;
	 assign clb_12_output_south = clb_12_output;
	 assign clb_12_output_west = clb_12_output;
	 for(l = 0; l < CLBIN; l = l + 1) begin : clb_io_mux
	    reg [1:0] c_11, c_12; // configuration register for mux
	    mux4 m_11 (
		       clb_11_input[l],
		       clb_11_input_north[l],
		       clb_11_input_east[l],
		       clb_11_input_south[l],
		       clb_11_input_west[l],
		       c_11
		       );
	    mux4 m_12 (
		       clb_12_input[l],
		       clb_12_input_north[l],
		       clb_12_input_east[l],
		       clb_12_input_south[l],
		       clb_12_input_west[l],
		       c_12
		       );
	 end
      end else if(CLBIOTYPE == 1) begin : clb_io_type1
	 assign clb_11_output_east = clb_11_output;
	 assign clb_11_output_west = clb_11_output;
	 assign clb_12_output_east = clb_12_output;
	 assign clb_12_output_west = clb_12_output;
	 for(l = 0; l < CLBIN; l = l + 1) begin : clb_input_mux
	    reg c00, c01;
	    mux2 m_11 (
		    clb_11_input[l],
		    clb_11_input_east[l],
		    clb_11_input_west[l],
		    c_11
		    );
	    mux2 m_12 (
		    clb_12_input[l],
		    clb_12_input_east[l],
		    clb_12_input_west[l],
		    c_12
		    );
	 end
      end else if(CLBIOTYPE == 2) begin : clb_io_type2
	 assign clb_11_output_north[CLBOUT/4-1:0] = clb_11_output[CLBOUT/4-1:0];
	 assign clb_11_output_east[CLBOUT/4-1:0] = clb_11_output[CLBOUT/2-1:CLBOUT/4];
	 assign clb_11_output_south[CLBOUT/4-1:0] = clb_11_output[CLBOUT/4*3-1:CLBOUT/2];
	 assign clb_11_output_west[CLBOUT/4-1:0] = clb_11_output[CLBOUT-1:CLBOUT/4*3];
	 assign clb_11_input = {clb_11_input_west[CLBIN/4-1:0],
				clb_11_input_south[CLBIN/4-1:0],
				clb_11_input_east[CLBIN/4-1:0],
				clb_11_input_north[CLBIN/4-1:0]};
	 assign clb_12_output_north[CLBOUT/4-1:0] = clb_12_output[CLBOUT/4-1:0];
	 assign clb_12_output_east[CLBOUT/4-1:0] = clb_12_output[CLBOUT/2-1:CLBOUT/4];
	 assign clb_12_output_south[CLBOUT/4-1:0] = clb_12_output[CLBOUT/4*3-1:CLBOUT/2];
	 assign clb_12_output_west[CLBOUT/4-1:0] = clb_12_output[CLBOUT-1:CLBOUT/4*3];
	 assign clb_12_input = {clb_12_input_west[CLBIN/4-1:0],
				clb_12_input_south[CLBIN/4-1:0],
				clb_12_input_east[CLBIN/4-1:0],
				clb_12_input_north[CLBIN/4-1:0]};
      end      
   endgenerate

   // cin
   generate
      if(CARRYTYPE == 0) begin : clb_cin_type0
	 for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux
	    reg [1:0] c_11, c_12;
	    mux4 m_11 (
		       clb_11_cin[l],
		       clb_11_cin_north[l],
		       clb_11_cin_east[l],
		       clb_11_cin_south[l],
		       clb_11_cin_west[l],
		       c_11
		       );
	    mux4 m_12 (
		       clb_12_cin[l],
		       clb_12_cin_north[l],
		       clb_12_cin_east[l],
		       clb_12_cin_south[l],
		       clb_12_cin_west[l],
		       c_12
		       );
	 end
      end else if(CARRYTYPE == 1) begin : clb_cin_type1
	 if(NORTHMOST) begin
	    for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux_north
	       reg c_11, c_12;
	       mux2 m_11 (
		       clb_11_cin[l],
		       clb_11_cin_east[l],
		       clb_11_cin_south[l],
		       c_11
		       );
	       mux2 m_12 (
		       clb_12_cin[l],
		       clb_12_cin_east[l],
		       clb_12_cin_south[l],
		       c_12
		       );
	    end
	 end else if(SOUTHMOST) begin
	    for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux_south
	       reg c_11, c_12;
	       mux2 m_11 (
		       clb_11_cin[l],
		       clb_11_cin_north[l],
		       clb_11_cin_east[l],
		       c_11
		       );
	       mux2 m_12 (
		       clb_12_cin[l],
		       clb_12_cin_north[l],
		       clb_12_cin_east[l],
		       c_12
		       );
	    end
	 end else begin
	    for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux
	       reg c_11, c_12;
	       mux2 m_11 (
			  clb_11_cin[l],
			  clb_11_cin_north[l],
			  clb_11_cin_south[l],
			  c_11
			  );
	       mux2 m_12 (
			  clb_12_cin[l],
			  clb_12_cin_north[l],
			  clb_12_cin_south[l],
			  c_12
			  );
	       
	    end
	 end
      end else if(CARRYTYPE == 2) begin : clb_cin_type2
	 if(NORTHMOST) begin
	    assign clb_11_cin = clb_11_cin_east;
	 end else begin
	    assign clb_11_cin = clb_11_cin_north;
	 end
	 if(SOUTHMOST) begin
	    assign clb_12_cin = clb_12_cin_east;
	 end else begin
	    assign clb_12_cin = clb_12_cin_south;
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
       .CLBIN0(NORTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBIN1(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBOUT(CLBOUT),
       .CLBOUT0(NORTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CLBOUT1(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(2*COLUMN),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(2*COLUMN),
       .CLBX(CLBX)
       )
   hcb_00
				       (
					.single0(switch_box_00_west_single),
					.single1(switch_box_01_east_single),
					.double0(switch_box_00_west_double),
					.double1(switch_box_01_east_double),
					.global(horizontal_global_0),
					.clb0_output(clb_01_output_south),
					.clb1_output(clb_11_output_north),
					.clb0_cout(clb_01_cout),
					.clb1_cout(clb_11_cout),
					.clb0_input(clb_01_input_south),
					.clb1_input(clb_11_input_north),
					.clb0_cin(clb_01_cin_south),
					.clb1_cin(clb_11_cin_north),
					.c()
					);

   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(NORTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBIN1(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBOUT(CLBOUT),
       .CLBOUT0(NORTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CLBOUT1(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(2*COLUMN+1),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(2*COLUMN+1),
       .CLBX(CLBX)
       )
   hcb_01
				       (
					.single0(switch_box_01_west_single),
					.single1(switch_box_02_east_single),
					.double0(switch_box_01_west_double),
					.double1(switch_box_02_east_double),
					.global(horizontal_global_0),
					.clb0_output(clb_02_output_south),
					.clb1_output(clb_12_output_north),
					.clb0_cout(clb_02_cout),
					.clb1_cout(clb_12_cout),
					.clb0_input(clb_02_input_south),
					.clb1_input(clb_12_input_north),
					.clb0_cin(clb_02_cin_south),
					.clb1_cin(clb_12_cin_north),
					.c()
					);
   
   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBIN1(SOUTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CLBOUT1(SOUTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(2*COLUMN),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(2*COLUMN),
       .CLBX(CLBX)
       )
   hcb_10
			  (
			   .single0(switch_box_10_west_single),
			   .single1(switch_box_11_east_single),
			   .double0(switch_box_10_west_double),
			   .double1(switch_box_11_east_double),
			   .global(horizontal_global_1),
			   .clb0_output(clb_11_output_south),
			   .clb1_output(clb_21_output_north),
			   .clb0_cout(clb_11_cout),
			   .clb1_cout(clb_21_cout),
			   .clb0_input(clb_11_input_south),
			   .clb1_input(clb_21_input_north),
			   .clb0_cin(clb_11_cin_south),
			   .clb1_cin(clb_21_cin_north),
			   .c()
			   );

   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBIN1(SOUTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CLBOUT1(SOUTHMOST || CLBIOTYPE == 1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(2*COLUMN+1),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(2*COLUMN+1),
       .CLBX(CLBX)
       )
   hcb_11
			  (
			   .single0(switch_box_11_west_single),
			   .single1(switch_box_12_east_single),
			   .double0(switch_box_11_west_double),
			   .double1(switch_box_12_east_double),
			   .global(horizontal_global_1),
			   .clb0_output(clb_12_output_south),
			   .clb1_output(clb_22_output_north),
			   .clb0_cout(clb_12_cout),
			   .clb1_cout(clb_22_cout),
			   .clb0_input(clb_12_input_south),
			   .clb1_input(clb_22_input_north),
			   .clb0_cin(clb_12_cin_south),
			   .clb1_cin(clb_22_cin_north),
			   .c()
			   );

   // vertical connection block
   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(EASTMOST? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBIN1(CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBOUT(CLBOUT),
       .CLBOUT0(EASTMOST? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CLBOUT1(CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(ROW),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(ROW),
       .CLBX(CLBX)
       )
   vcb_00
				       (
					.single0(switch_box_00_south_single),
					.single1(switch_box_10_north_single),
					.double0(switch_box_00_south_double),
					.double1(switch_box_10_north_double),
					.global(vertical_global_0),
					.clb0_output(clb_10_output_west),
					.clb1_output(clb_11_output_east),
					.clb0_cout(clb_10_cout),
					.clb1_cout(clb_11_cout),
					.clb0_input(clb_10_input_west),
					.clb1_input(clb_11_input_east),
					.clb0_cin(clb_10_cin_west),
					.clb1_cin(clb_11_cin_east),
					.c()
					);

   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBIN1(CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CLBOUT1(CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(ROW),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(ROW),
       .CLBX(CLBX)
       )
   vcb_01
				       (
					.single0(switch_box_01_south_single),
					.single1(switch_box_11_north_single),
					.double0(switch_box_01_south_double),
					.double1(switch_box_11_north_double),
					.global(vertical_global_1),
					.clb0_output(clb_11_output_west),
					.clb1_output(clb_12_output_east),
					.clb0_cout(clb_11_cout),
					.clb1_cout(clb_12_cout),
					.clb0_input(clb_11_input_west),
					.clb1_input(clb_12_input_east),
					.clb0_cin(clb_11_cin_west),
					.clb1_cin(clb_12_cin_east),
					.c()
					);
   
   connection_block
     #(
       .WS(WS),
       .WD(WD),
       .WG(WG),
       .CLBIN(CLBIN),
       .CLBIN0(CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBIN1(WESTMOST? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
       .CLBOUT(CLBOUT),
       .CLBOUT0(CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CLBOUT1(WESTMOST? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
       .CARRY(CARRY),
       .CLBOS(CLBOS),
       .CLBOS_BIAS(ROW),
       .CLBOD(CLBOD),
       .CLBOD_BIAS(ROW),
       .CLBX(CLBX)
       )
   vcb_02
			  (
			   .single0(switch_box_02_south_single),
			   .single1(switch_box_12_north_single),
			   .double0(switch_box_02_south_double),
			   .double1(switch_box_12_north_double),
			   .global(vertical_global_2),
			   .clb0_output(clb_12_output_west),
			   .clb1_output(clb_13_output_east),
			   .clb0_cout(clb_12_cout),
			   .clb1_cout(clb_13_cout),
			   .clb0_input(clb_12_input_west),
			   .clb1_input(clb_13_input_east),
			   .clb0_cin(clb_12_cin_west),
			   .clb1_cin(clb_13_cin_east),
			   .c()
			   );
   
endmodule

