module data_tile
  #(
    // parameters from top module
    parameter WW = 4,
    parameter WN = 4,  // WN * WW bits around MAC/MEM column
    parameter IOTYPE = 1, //  0 ... both sides with MUX, 1 ... divided (DATAIN and DATAOUT must be multiple of 2)
    // parameters for sub modules
    parameter DATAIN = 2,
    parameter DATAOUT = 2,
    parameter CONTROLIN = 2,
    // useful parameters
    parameter W = WW*WN,
    parameter DIN_SIDE = IOTYPE? DATAIN/2: DATAIN,
    parameter DOUT_SIDE = IOTYPE? DATAOUT/2: DATAOUT,
    parameter SEL_PER_CIN = $clog2(W*2),
    parameter CONF_CCB = SEL_PER_CIN*CONTROLIN,
    parameter SEL_PER_DIN = $clog2(WN*2),
    parameter SEL_PER_DOUT = $clog2(DOUT_SIDE+1),
    parameter CONF_DCB = SEL_PER_DIN*DIN_SIDE*WW + SEL_PER_DOUT*W*2
    )
   (
    input [W-1:0] 	  north_left_in,
    input [W-1:0] 	  north_right_in,
    output [W-1:0] 	  north_left_out,
    output [W-1:0] 	  north_right_out,

    input [W-1:0] 	  east_in,
    output [W-1:0] 	  east_out,
   
    input [W-1:0] 	  west_in,
    output [W-1:0] 	  west_out,

    input [W-1:0] 	  south_left_in,
    input [W-1:0] 	  south_right_in,
    output [W-1:0] 	  south_left_out,
    output [W-1:0] 	  south_right_out,

    input [W*8-1:0] 	  conf_sb_left,
    input [W*8-1:0] 	  conf_sb_right,
    input [WW*DATAIN-1:0] conf_io_type0,
    input [CONF_CCB-1:0]  conf_ccb,
    input [CONF_DCB-1:0]  conf_dcb_left,
    input [CONF_DCB-1:0]  conf_dcb_right,

    input 		  clk,
    input 		  rst,
    input 		  cset
   
    );
   
   // wires for switch box
   wire [W-1:0] 	  left_switch_box_south_in;
   wire [W-1:0] 	  left_switch_box_south_out;
   wire [W-1:0] 	  left_switch_box_west_in;
   wire [W-1:0] 	  left_switch_box_west_out;
   wire [W-1:0] 	  right_switch_box_south_in;
   wire [W-1:0] 	  right_switch_box_south_out;
   wire [W-1:0] 	  right_switch_box_east_in;
   wire [W-1:0] 	  right_switch_box_east_out;
   
   // wires for unit
   wire [CONTROLIN-1:0]   control_input;
   wire [WW*DATAIN-1:0]   data_input;
   wire [WW*DIN_SIDE-1:0] data_input_east;
   wire [WW*DIN_SIDE-1:0] data_input_west;
   wire [WW*DATAOUT-1:0]  data_output;
   wire [WW*DOUT_SIDE-1:0] data_output_east;
   wire [WW*DOUT_SIDE-1:0] data_output_west;
   
   genvar 		   l;
   
   // switch box
   disjoint_switch_box 
     #(
       .W(W)
       )
   dsb_left (
	     .clk(clk),
	     .rst(rst),
	     .cset(cset),
	     .north_in(north_left_in),
	     .north_out(north_left_out),
	     .east_in(east_in),
	     .east_out(east_out),
	     .south_in(left_switch_box_south_in),
	     .south_out(left_switch_box_south_out),
	     .west_in(left_switch_box_west_in),
	     .west_out(left_switch_box_west_out),
	     .c(conf_sb_left)
	     );

   disjoint_switch_box 
     #(
       .W(W)
       )
   dsb_right (
	      .clk(clk),
	      .rst(rst),
	      .cset(cset),
	      .north_in(north_right_in),
	      .north_out(north_right_out),
	      .east_in(right_switch_box_east_in),
	      .east_out(right_switch_box_east_out),
	      .south_in(right_switch_box_south_in),
	      .south_out(right_switch_box_south_out),
	      .west_in(west_in),
	      .west_out(west_out),
	      .c(conf_sb_right)
	      );   

   mac
     #(
       .WW(WW),
       .MACDATAIN(DATAIN),
       .MACDATAOUT(DATAOUT),
       .MACCONTROLIN(CONTROLIN)
       )
   mac0 (
	 .inputs(data_input),
	 .outputs(data_output),
	 .control_inputs(control_input)
	 );
   /*
    mem
    #(
    .WW(WW),
    .MEMDATAIN(DATAIN),
    .MEMDATAOUT(DATAOUT),
    .MEMCONTROLIN(CONTROLIN)
    )
    mem0 (
    .inputs(data_input),
    .outputs(data_output),
    .control_inputs(control_input)
    );
    */  

   // io
   generate
      if(IOTYPE == 0) begin : io_type0
	 assign data_output_east = data_output;
	 assign data_output_west = data_output;
	 for(l = 0; l < WW*DATAIN; l = l + 1) begin
	    mux2 m (
		    data_input[l],
		    data_input_east[l],
		    data_input_west[l],
		    conf_io_type0[l]
		    );
	 end
      end else begin : io_type1
	 assign {data_output_west, data_output_east} = data_output;
	 assign data_input = {data_input_west, data_input_east};
      end      
   endgenerate

   // control connection block
   control_connection_block
     #(
       .W(W),
       .CONTROLIN(CONTROLIN)
       )
   ccb (
	.clk(clk),
	.rst(rst),
	.cset(cset),
	.east_in(left_switch_box_west_out),
	.east_out(left_switch_box_west_in),
	.west_in(right_switch_box_east_out),
	.west_out(right_switch_box_east_in),
	.control_input(control_input),
	.c(conf_ccb)
	);

   // data connection block
   data_connection_block
     #(
       .W(W),
       .WW(WW),
       .DATAIN(DIN_SIDE),
       .DATAOUT(DOUT_SIDE)
       )
   dcb_left (
	     .clk(clk),
	     .rst(rst),
	     .cset(cset),
	     .north_in(left_switch_box_south_out),
	     .north_out(left_switch_box_south_in),
	     .south_in(south_left_in),
	     .south_out(south_left_out),
	     .data_input(data_input_east),
	     .data_output(data_output_east),
	     .c(conf_dcb_left)
	     );
   
   data_connection_block
     #(
       .W(W),
       .WW(WW),
       .DATAIN(DIN_SIDE),
       .DATAOUT(DOUT_SIDE)
       )
   dcb_right (
	      .clk(clk),
	      .rst(rst),
	      .cset(cset),
	      .north_in(right_switch_box_south_out),
	      .north_out(right_switch_box_south_in),
	      .south_in(south_right_in),
	      .south_out(south_right_out),
	      .data_input(data_input_west),
	      .data_output(data_output_west),
	      .c(conf_dcb_right)
	      );
   
endmodule

