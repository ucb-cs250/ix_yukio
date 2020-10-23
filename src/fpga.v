module fpga
  #(
    parameter N = 1, // #set-rows 
    parameter M = 2, // #set-columns
    parameter WS = 4,
    parameter WD = 4, // WD must be multiple of 2
    parameter WG = 3,
    parameter WN = 2, // WN * WW bits around MAC/MEM column
    parameter CLBOS = 2, // CLBOS must be less than or equal to WS
    parameter CLBOD = 2, // CLBOD must be less than or equal to WD
    parameter CLBIOTYPE = 0, // 0 ... anyside with MUX, 1 ... left to right or right to left with MUX, 2 ... divided (CLBIN and CLBOUT must be multiple of 4)
    parameter CLBX = 1, // 0 or 1 to toggle using direct connection between adjacent CLBs
    parameter CARRYTYPE = 2, // 0 ... anyside with MUX, 1 ... vertical two-way and horizontal one-way only at the top and bottom with MUX, 2 ... one-way meandering (top to bottom -> left to right -> bottom to top -> left to right -> ...)
    parameter MCLB = 2, // #CLB-columns in a set, must be multiple of 2
    parameter NSB = 1, // No horizontal line and SB when ROW%NSB != 0 (except near io block and MAC/MEM). CLBIOTYPE must not be 2 when NSB is not 1
    parameter NSBSB = 1, // #USBs inputted to one DSB. NSBSB must be less than or equal to min(NCLBMAC, NCLBMEM)
    parameter NMAC = 1, // #MACs in a set
    parameter NMEM = 1, // #MEMs in a set
    parameter EXTIN = 3, // per io block
    parameter EXTOUT = 3, // per io block
    parameter EXTDATAIN = 2, // input bits per data io block
    parameter EXTDATAOUT = 2 // output bits per data io block
    )
   (
    input [EXTIN*(MCLBFLAT+M+1)-1:0]   north_external_input,
    input [EXTIN*(NCLBFLAT+1)-1:0]     east_external_input,
    input [EXTIN*(MCLBFLAT+M+1)-1:0]   south_external_input,
    input [EXTIN*(NCLBFLAT+1)-1:0]     west_external_input,
    output [EXTOUT*(MCLBFLAT+M+1)-1:0] north_external_output,
    output [EXTOUT*(NCLBFLAT+1)-1:0]   east_external_output,
    output [EXTOUT*(MCLBFLAT+M+1)-1:0]     south_external_output,
    output [EXTOUT*(NCLBFLAT+1)-1:0]   west_external_output,
    input [WW*EXTDATAIN*2*M-1:0]       north_external_data_input,
    input [WW*EXTDATAIN*2*M-1:0]       south_external_data_input,
    output [WW*EXTDATAOUT*2*M-1:0]     north_external_data_output,
    output [WW*EXTDATAOUT*2*M-1:0]     south_external_data_output
    );
   
   // parameters from modules
   localparam CLBIN = 4;
   localparam CLBOUT = 4;
   localparam CARRY = 1; // bit-width of carry
   localparam WW = 4;
   localparam MACDATAIN = 2;
   localparam MACDATAOUT = 2;
   localparam MACCONTROLIN = 2;
   localparam MEMDATAIN = 2;
   localparam MEMDATAOUT = 2;
   localparam MEMCONTROLIN = 4;
   localparam NCLBMAC = 2; // #CLBs per MAC in terms of height
   localparam NCLBMEM = 2; // #CLBs per MEM in terms of height
   
   // useful constants
   localparam NCLBFLAT = (NCLBMAC*NMAC+NCLBMEM*NMEM)*N;
   localparam MCLBFLAT = MCLB*M;

   // wires      
   wire [WS-1:0] switch_box_north_single [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];
   wire [WD-1:0] switch_box_north_double [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];
   wire [WS-1:0] switch_box_east_single [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];
   wire [WD-1:0] switch_box_east_double [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];
   wire [WS-1:0] switch_box_south_single [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];
   wire [WD-1:0] switch_box_south_double [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];
   wire [WS-1:0] switch_box_west_single [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];
   wire [WD-1:0] switch_box_west_double [0:(NCLBFLAT+1)*(MCLBFLAT+M+1)-1];

   wire [CLBIN-1:0] clb_input [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBIN-1:0] clb_input_north [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBIN-1:0] clb_input_east [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBIN-1:0] clb_input_south [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBIN-1:0] clb_input_west [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBOUT-1:0] clb_output [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBOUT-1:0] clb_output_north [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBOUT-1:0] clb_output_east [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBOUT-1:0] clb_output_south [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CLBOUT-1:0] clb_output_west [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CARRY-1:0] clb_cin [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CARRY-1:0] clb_cin_north [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CARRY-1:0] clb_cin_east [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CARRY-1:0] clb_cin_south [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CARRY-1:0] clb_cin_west [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   wire [CARRY-1:0] clb_cout [0:(NCLBFLAT+2)*(MCLBFLAT+2)-1];
   
   wire [WW*WN-1:0] data_switch_box_north [0:((NMAC+NMEM)*N+1)*2*M-1];
   wire [WW*WN-1:0] data_switch_box_east [0:((NMAC+NMEM)*N+1)*2*M-1];
   wire [WW*WN-1:0] data_switch_box_south [0:((NMAC+NMEM)*N+1)*2*M-1];
   wire [WW*WN-1:0] data_switch_box_west [0:((NMAC+NMEM)*N+1)*2*M-1];
   
   wire [MACCONTROLIN-1:0]  mac_control_input [0:NMAC*N*M-1];
   wire [MEMCONTROLIN-1:0]  mem_control_input [0:NMEM*N*M-1];
   
   wire [WW*MACDATAIN-1:0] mac_data_input [0:NMAC*N*M-1];
   wire [WW*MACDATAIN-1:0] mac_data_input_east [0:NMAC*N*M-1];
   wire [WW*MACDATAIN-1:0] mac_data_input_west [0:NMAC*N*M-1];
   wire [WW*MACDATAOUT-1:0] mac_data_output [0:NMAC*N*M-1];
   
   wire [WW*MEMDATAIN-1:0]  mem_data_input [0:NMEM*N*M-1];
   wire [WW*MEMDATAIN-1:0]  mem_data_input_east [0:NMEM*N*M-1];
   wire [WW*MEMDATAIN-1:0]  mem_data_input_west [0:NMEM*N*M-1];
   wire [WW*MEMDATAOUT-1:0] mem_data_output [0:NMEM*N*M-1];
   
   wire [WG-1:0] horizontal_global [0:(NCLBFLAT+1)-1];
   wire [WG-1:0] vertical_global [0:(MCLBFLAT+M+1)-1];
   
   genvar i, j, k, l;

   // io block
   generate
      for(j = 0; j < MCLBFLAT+M+1; j = j + 1) begin : io_block_north
	 io_block
	      #(
		.WS(WS),
		.WD(WD),
		.WG(WG),
		.EXTIN(EXTIN),
		.EXTOUT(EXTOUT)
		)
	 iob
	      (
	       .single(switch_box_north_single[j]),
	       .double(switch_box_north_double[j]),
	       .global(vertical_global[j]),
	       .external_input(north_external_input[(j+1)*EXTIN-1:j*EXTIN]),
	       .external_output(north_external_output[(j+1)*EXTIN-1:j*EXTIN]),
	       .c()
	       );
      end
      for(i = 0; i < NCLBFLAT+1; i = i + 1) begin : io_block_east
	 io_block
	      #(
		.WS(WS),
		.WD(WD),
		.WG(WG),
		.EXTIN(EXTIN),
		.EXTOUT(EXTOUT)
		)
	 iob
	      (
	       .single(switch_box_east_single[i*(MCLBFLAT+M+1)]),
	       .double(switch_box_east_double[i*(MCLBFLAT+M+1)]),
	       .global(horizontal_global[i]),
	       .external_input(east_external_input[(i+1)*EXTIN-1:i*EXTIN]),
	       .external_output(east_external_output[(i+1)*EXTIN-1:i*EXTIN]),
	       .c()
	       );
      end
      for(j = 0; j < MCLBFLAT+M+1; j = j + 1) begin : io_block_south
	 io_block
	      #(
		.WS(WS),
		.WD(WD),
		.WG(WG),
		.EXTIN(EXTIN),
		.EXTOUT(EXTOUT)
		)
	 iob
	      (
	       .single(switch_box_south_single[j+NCLBFLAT*(MCLBFLAT+M+1)]),
	       .double(switch_box_south_double[j+NCLBFLAT*(MCLBFLAT+M+1)]),
	       .global(vertical_global[j]),
	       .external_input(south_external_input[(j+1)*EXTIN-1:j*EXTIN]),
	       .external_output(south_external_output[(j+1)*EXTIN-1:j*EXTIN]),
	       .c()
	       );
      end
      for(i = 0; i < NCLBFLAT+1; i = i + 1) begin : io_block_west
	 io_block
	      #(
		.WS(WS),
		.WD(WD),
		.WG(WG),
		.EXTIN(EXTIN),
		.EXTOUT(EXTOUT)
		)
	 iob
	      (
	       .single(switch_box_west_single[(i+1)*(MCLBFLAT+M+1)-1]),
	       .double(switch_box_west_double[(i+1)*(MCLBFLAT+M+1)-1]),
	       .global(horizontal_global[i]),
	       .external_input(west_external_input[(i+1)*EXTIN-1:i*EXTIN]),
	       .external_output(west_external_output[(i+1)*EXTIN-1:i*EXTIN]),
	       .c()
	       );
      end
   endgenerate
   
   // switch box
   generate
      for(i = 0; i < NCLBFLAT+1; i = i + 1) begin
	 for(j = 0; j < MCLBFLAT+M+1; j = j + 1) begin : switch_box
	    if(i%NSB != 0 && i != NCLBFLAT && j != 0 && j != MCLBFLAT+M && j%(MCLB+1) != MCLB/2 && j%(MCLB+1) != MCLB/2+1) begin
	       // disjointing box
	    end else begin
	       clb_switch_box 
		 #(
		   .WS(WS),
		   .WD(WD)
		   )
	       usb
		 (
		  .north_single(switch_box_north_single[j+i*(MCLBFLAT+M+1)]),
		  .east_single(switch_box_east_single[j+i*(MCLBFLAT+M+1)]),
		  .south_single(switch_box_south_single[j+i*(MCLBFLAT+M+1)]),
		  .west_single(switch_box_west_single[j+i*(MCLBFLAT+M+1)]),
		  .north_double(switch_box_north_double[j+i*(MCLBFLAT+M+1)]),
		  .east_double(switch_box_east_double[j+i*(MCLBFLAT+M+1)]),
		  .south_double(switch_box_south_double[j+i*(MCLBFLAT+M+1)]),
		  .west_double(switch_box_west_double[j+i*(MCLBFLAT+M+1)]),
		  .c()
		  );
	    end
	end
      end
   endgenerate

   // clb
   generate
      for(i = 0; i < NCLBFLAT; i = i + 1) begin
	 for(j = 0; j < MCLBFLAT; j = j + 1) begin : clbs
	    // clb
	    clb
		 #(
		   .CLBIN(CLBIN),
		   .CLBOUT(CLBOUT),
		   .CARRY(CARRY)
		   )
	    clb0
		 (
		  .inputs(clb_input[(j+1)+(i+1)*MCLBFLAT]),
		  .outputs(clb_output[(j+1)+(i+1)*MCLBFLAT]),
		  .cin(clb_cin[(j+1)+(i+1)*MCLBFLAT]),
		  .cout(clb_cout[(j+1)+(i+1)*MCLBFLAT])
		  );
	 end
      end
   endgenerate
   
   // clb io
   generate
      if(CLBIOTYPE == 0) begin : clb_io_type0
	 for(i = 0; i < NCLBFLAT; i = i + 1) begin
	    for(j = 0; j < MCLBFLAT; j = j + 1) begin
	       assign clb_output_north[(j+1)+(i+1)*MCLBFLAT] = clb_output[(j+1)+(i+1)*MCLBFLAT];
	       assign clb_output_east[(j+1)+(i+1)*MCLBFLAT] = clb_output[(j+1)+(i+1)*MCLBFLAT];
	       assign clb_output_south[(j+1)+(i+1)*MCLBFLAT] = clb_output[(j+1)+(i+1)*MCLBFLAT];
	       assign clb_output_west[(j+1)+(i+1)*MCLBFLAT] = clb_output[(j+1)+(i+1)*MCLBFLAT];
	       for(l = 0; l < CLBIN; l = l + 1) begin : clb_io_mux
		  reg [1:0] c;
		  mux4 m (
			  clb_input[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_input_north[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_input_east[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_input_south[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_input_west[(j+1)+(i+1)*MCLBFLAT][l],
			  c
			  );
	       end
	    end
	 end
      end else if(CLBIOTYPE == 1) begin : clb_io_type1
	 for(i = 0; i < NCLBFLAT; i = i + 1) begin
	    for(j = 0; j < MCLBFLAT; j = j + 1) begin
	       assign clb_output_east[(j+1)+(i+1)*MCLBFLAT] = clb_output[(j+1)+(i+1)*MCLBFLAT];
	       assign clb_output_west[(j+1)+(i+1)*MCLBFLAT] = clb_output[(j+1)+(i+1)*MCLBFLAT];
	       for(l = 0; l < CLBIN; l = l + 1) begin : clb_input_mux
		  reg c;
		  mux2 m (
			  clb_input[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_input_east[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_input_west[(j+1)+(i+1)*MCLBFLAT][l],
			  c
			  );
	       end
	    end
	 end
      end else if(CLBIOTYPE == 2) begin : clb_io_type2
	 for(i = 0; i < NCLBFLAT; i = i + 1) begin
	    for(j = 0; j < MCLBFLAT; j = j + 1) begin
	       assign clb_output_north[(j+1)+(i+1)*MCLBFLAT][CLBOUT/4-1:0] = clb_output[(j+1)+(i+1)*MCLBFLAT][CLBOUT/4-1:0];
	       assign clb_output_east[(j+1)+(i+1)*MCLBFLAT][CLBOUT/4-1:0] = clb_output[(j+1)+(i+1)*MCLBFLAT][CLBOUT/2-1:CLBOUT/4];
	       assign clb_output_south[(j+1)+(i+1)*MCLBFLAT][CLBOUT/4-1:0] = clb_output[(j+1)+(i+1)*MCLBFLAT][CLBOUT/4*3-1:CLBOUT/2];
	       assign clb_output_west[(j+1)+(i+1)*MCLBFLAT][CLBOUT/4-1:0] = clb_output[(j+1)+(i+1)*MCLBFLAT][CLBOUT-1:CLBOUT/4*3];
	       assign clb_input[(j+1)+(i+1)*MCLBFLAT] = {clb_input_west[(j+1)+(i+1)*MCLBFLAT][CLBIN/4-1:0],
							 clb_input_south[(j+1)+(i+1)*MCLBFLAT][CLBIN/4-1:0],
							 clb_input_east[(j+1)+(i+1)*MCLBFLAT][CLBIN/4-1:0],
							 clb_input_north[(j+1)+(i+1)*MCLBFLAT][CLBIN/4-1:0]};
	    end
	 end
      end
   endgenerate

   // cin
   generate
      if(CARRYTYPE == 0) begin : clb_cin_type0
	 for(i = 0; i < NCLBFLAT; i = i + 1) begin
	    for(j = 0; j < MCLBFLAT; j = j + 1) begin
	       for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux
		  reg [1:0] c;
		  mux4 m (
			  clb_cin[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_cin_north[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_cin_east[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_cin_south[(j+1)+(i+1)*MCLBFLAT][l],
			  clb_cin_west[(j+1)+(i+1)*MCLBFLAT][l],
			  c
			  );
	       end
	    end
	 end
      end else if(CARRYTYPE == 1) begin : clb_cin_type1
	 for(i = 0; i < NCLBFLAT; i = i + 1) begin
	    for(j = 0; j < MCLBFLAT; j = j + 1) begin
	       if(i == 0) begin
		  for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux_north
		     reg c;
		     mux2 m (
			     clb_cin[(j+1)+(i+1)*MCLBFLAT][l],
			     clb_cin_east[(j+1)+(i+1)*MCLBFLAT][l],
			     clb_cin_south[(j+1)+(i+1)*MCLBFLAT][l],
			     c
			     );
		  end
	       end else if(i == NCLBFLAT-1) begin
		  for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux_south
		     reg c;
		     mux2 m (
			     clb_cin[(j+1)+(i+1)*MCLBFLAT][l],
			     clb_cin_north[(j+1)+(i+1)*MCLBFLAT][l],
			     clb_cin_east[(j+1)+(i+1)*MCLBFLAT][l],
			     c
			     );
		  end
	       end else begin
		  for(l = 0; l < CARRY; l = l + 1) begin : clb_cin_mux
		     reg c;
		     mux2 m (
			     clb_cin[(j+1)+(i+1)*MCLBFLAT][l],
			     clb_cin_north[(j+1)+(i+1)*MCLBFLAT][l],
			     clb_cin_south[(j+1)+(i+1)*MCLBFLAT][l],
			     c
			     );
		  end
	       end
	    end
	 end
      end else if(CARRYTYPE == 2) begin : clb_cin_type2
	 for(i = 0; i < NCLBFLAT; i = i + 1) begin
	    for(j = 0; j < MCLBFLAT; j = j + 1) begin
	       if(j%2 == 0) begin
		  if(i == 0) begin
		     assign clb_cin[(j+1)+(i+1)*MCLBFLAT] = clb_cin_east[(j+1)+(i+1)*MCLBFLAT];
		  end else begin
		     assign clb_cin[(j+1)+(i+1)*MCLBFLAT] = clb_cin_north[(j+1)+(i+1)*MCLBFLAT];
		  end
	       end else begin
		  if(i == NCLBFLAT-1) begin
		     assign clb_cin[(j+1)+(i+1)*MCLBFLAT] = clb_cin_east[(j+1)+(i+1)*MCLBFLAT];
		  end else begin
		     assign clb_cin[(j+1)+(i+1)*MCLBFLAT] = clb_cin_south[(j+1)+(i+1)*MCLBFLAT];
		  end
	       end
	    end
	 end
      end   
   endgenerate

   // horizontal connection block
   generate
      for(i = 0; i < NCLBFLAT+1; i = i + 1) begin
	 for(k = 0; k < M; k = k + 1) begin
	    for(j = 0; j < MCLB; j = j + 1) begin : horizontal_connection_block
	       connection_block
		    #(
		      .WS(WS),
		      .WD(WD),
		      .WG(WG),
		      .CLBIN(CLBIN),
		      .CLBIN0(i == 0 || CLBIOTYPE == 1 || i%NSB != 0 ? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
		      .CLBIN1(i == NCLBFLAT || CLBIOTYPE == 1|| i%NSB != 0 ? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
		      .CLBOUT(CLBOUT),
		      .CLBOUT0(i == 0 || CLBIOTYPE == 1|| i%NSB != 0 ? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
		      .CLBOUT1(i == NCLBFLAT || CLBIOTYPE == 1|| i%NSB != 0 ? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
		      .CARRY(CARRY),
		      .CLBOS(CLBOS),
		      .CLBOS_BIAS(j),
		      .CLBOD(CLBOD),
		      .CLBOD_BIAS(j),
		      .CLBX(CLBX)
		      )
	       cb
		    (
		     .single0(switch_box_west_single[j+k*(MCLB+1)+i*(MCLBFLAT+M+1)+(j>=MCLB/2)]),
		     .single1(switch_box_east_single[(j+1)+k*(MCLB+1)+i*(MCLBFLAT+M+1)+(j>=MCLB/2)]),
		     .double0(switch_box_west_double[j+k*(MCLB+1)+i*(MCLBFLAT+M+1)+(j>=MCLB/2)]),
		     .double1(switch_box_east_double[(j+1)+k*(MCLB+1)+i*(MCLBFLAT+M+1)+(j>=MCLB/2)]),
		     .global(horizontal_global[i]),
		     .clb0_output(clb_output_south[(j+1)+k*MCLB+i*MCLBFLAT]),
		     .clb1_output(clb_output_north[(j+1)+k*MCLB+(i+1)*MCLBFLAT]),
		     .clb0_cout(clb_cout[(j+1)+k*MCLB+i*MCLBFLAT]),
		     .clb1_cout(clb_cout[(j+1)+k*MCLB+(i+1)*MCLBFLAT]),
		     .clb0_input(clb_input_south[(j+1)+k*MCLB+i*MCLBFLAT]),
		     .clb1_input(clb_input_north[(j+1)+k*MCLB+(i+1)*MCLBFLAT]),
		     .clb0_cin(clb_cin_south[(j+1)+k*MCLB+i*MCLBFLAT]),
		     .clb1_cin(clb_cin_north[(j+1)+k*MCLB+(i+1)*MCLBFLAT]),
		     .c()
		     );
	    end
	 end
      end
   endgenerate
   
   // vertical connection block
   generate
      for(i = 0; i < NCLBFLAT; i = i + 1) begin
	 for(k = 0; k < M; k = k + 1) begin
	    for(j = 0; j < MCLB+1+(k == M-1); j = j + 1) begin : vertical_connection_block
	       connection_block
		    #(
		      .WS(WS),
		      .WD(WD),
		      .WG(WG),
		      .CLBIN(CLBIN),
		      .CLBIN0((k == 0 && j == 0) || j == MCLB/2+1? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
		      .CLBIN1((j == MCLB+1) || j == MCLB/2? 0: CLBIOTYPE == 2? CLBIN/4: CLBIN),
		      .CLBOUT(CLBOUT),
		      .CLBOUT0((k == 0 && j == 0) || j == MCLB/2+1? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
		      .CLBOUT1((j == MCLB+1) || j == MCLB/2? 0: CLBIOTYPE == 2? CLBOUT/4: CLBOUT),
		      .CARRY(CARRY),
		      .CLBOS(CLBOS),
		      .CLBOS_BIAS(i),
		      .CLBOD(CLBOD),
		      .CLBOD_BIAS(i),
		      .CLBX(CLBX)
		      )
	       cb
		    (
		     .single0(switch_box_south_single[j+k*(MCLB+1)+i*(MCLBFLAT+M+1)]),
		     .single1(switch_box_north_single[j+k*(MCLB+1)+(i+1)*(MCLBFLAT+M+1)]),
		     .double0(switch_box_south_double[j+k*(MCLB+1)+i*(MCLBFLAT+M+1)]),
		     .double1(switch_box_north_double[j+k*(MCLB+1)+(i+1)*(MCLBFLAT+M+1)]),
		     .global(vertical_global[j]),
		     .clb0_output(clb_output_west[j+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .clb1_output(clb_output_east[(j+1)+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .clb0_cout(clb_cout[j+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .clb1_cout(clb_cout[(j+1)+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .clb0_input(clb_input_west[j+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .clb1_input(clb_input_east[(j+1)+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .clb0_cin(clb_cin_west[j+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .clb1_cin(clb_cin_east[(j+1)+k*MCLB+(i+1)*MCLBFLAT-(j>MCLB/2)]),
		     .c()
		     );
	    end
	 end
      end
   endgenerate

   // data io block
   generate
      for(j = 0; j < 2*M; j = j + 1) begin : data_io_block_north
	 data_io_block
	      #(
		.W(WW*WN),
		.WW(WW),
		.EXTDATAIN(EXTDATAIN),
		.EXTDATAOUT(EXTDATAOUT)
		)
	 diob
	      (
	       .data(data_switch_box_north[j]),
	       .external_input(north_external_data_input[(j+1)*WW*EXTDATAIN-1:j*WW*EXTDATAIN]),
	       .external_output(north_external_data_output[(j+1)*WW*EXTDATAIN-1:j*WW*EXTDATAIN]),
	       .c()
	       );
      end
      for(j = 0; j < 2*M; j = j + 1) begin : data_io_block_south
	 data_io_block
	      #(
		.W(WW*WN),
		.WW(WW),
		.EXTDATAIN(EXTDATAIN),
		.EXTDATAOUT(EXTDATAOUT)
		)
	 diob
	      (
	       .data(data_switch_box_south[j+(NMAC+NMEM)*N*2*M]),
	       .external_input(south_external_data_input[(j+1)*WW*EXTDATAIN-1:j*WW*EXTDATAIN]),
	       .external_output(south_external_data_output[(j+1)*WW*EXTDATAIN-1:j*WW*EXTDATAIN]),
	       .c()
	       );
      end
   endgenerate
   
   // data switch box
   generate
      for(i = 0; i < (NMAC+NMEM)*N+1; i = i + 1) begin
	 for(j = 0; j < 2*M; j = j + 1) begin : data_switch_box
	    disjoint_switch_box 
		 #(
		   .W(WW*WN)
		   )
	    dsb
		 (
		  .north(data_switch_box_north[j+i*2*M]),
		  .east(data_switch_box_east[j+i*2*M]),
		  .south(data_switch_box_south[j+i*2*M]),
		  .west(data_switch_box_west[j+i*2*M]),
		  .c()
		  );
	 end
      end
   endgenerate
   
   // mac
   generate
      for(i = 0; i < NMAC*N; i = i + 1) begin
	 for(j = 0; j < M; j = j + 1) begin : macs
	    mac
		 #(
		   .WW(WW),
		   .MACDATAIN(MACDATAIN),
		   .MACDATAOUT(MACDATAOUT),
		   .MACCONTROLIN(MACCONTROLIN)
		   )
	    m
		 (
		  .inputs(mac_data_input[j+i*M]),
		  .outputs(mac_data_output[j+i*M]),
		  .control_inputs(mac_control_input[j+i*M])
		  );
	 end
      end
   endgenerate

   // mac input
   generate
      for(i = 0; i < NMAC*N; i = i + 1) begin
	 for(j = 0; j < M; j = j + 1) begin
	    for(l = 0; l < WW*MACDATAIN; l = l + 1) begin : mac_input_mux
	       reg c;
	       mux2 m (
		       mac_data_input[j+i*M][l],
		       mac_data_input_east[j+i*M][l],
		       mac_data_input_west[j+i*M][l],
		       c
		       );
	    end
	 end
      end
   endgenerate

   // mem
   generate
      for(i = 0; i < NMEM*N; i = i + 1) begin
	 for(j = 0; j < M; j = j + 1) begin : mems
	    mem
		 #(
		   .WW(WW),
		   .MEMDATAIN(MEMDATAIN),
		   .MEMDATAOUT(MEMDATAOUT),
		   .MEMCONTROLIN(MEMCONTROLIN)
		   )
	    m
		 (
		  .inputs(mem_data_input[j+i*M]),
		  .outputs(mem_data_output[j+i*M]),
		  .control_inputs(mem_control_input[j+i*M])
		  );
	 end
      end
   endgenerate

   // mem input
   generate
      for(i = 0; i < NMEM*N; i = i + 1) begin
	 for(j = 0; j < M; j = j + 1) begin
	    for(l = 0; l < WW*MEMDATAIN; l = l + 1) begin : mem_input_mux
	       reg c;
	       mux2 m (
		       mem_data_input[j+i*M][l],
		       mem_data_input_east[j+i*M][l],
		       mem_data_input_west[j+i*M][l],
		       c
		       );
	    end
	 end
      end
   endgenerate

   // control connection block
   generate
      for(k = 0; k < N; k = k + 1) begin
	 for(i = 0; i < NMAC; i = i + 1) begin
	    for(j = 0; j < M; j = j + 1) begin : mac_control_connection_block 
	       control_connection_block
		    #(
		      .W(WW*WN),
		      .CONTROLIN(MACCONTROLIN)
		   )
	       ccb
		    (
		     .east(data_switch_box_west[j*2+i*2*M+k*2*M*(NMAC+NMEM)]),
		     .west(data_switch_box_east[1+j*2+i*2*M+k*2*M*(NMAC+NMEM)]),
		     .control_input(mac_control_input[j+i*M+k*M*NMAC]),
		     .c()
		     );
	    end
	 end
	 for(i = 0; i < NMEM; i = i + 1) begin
	    for(j = 0; j < M; j = j + 1) begin : mem_control_connection_block 
	       control_connection_block
		    #(
		      .W(WW*WN),
		      .CONTROLIN(MEMCONTROLIN)
		   )
	       ccb
		    (
		     .east(data_switch_box_west[j*2+(i+NMAC)*2*M+k*2*M*(NMAC+NMEM)]),
		     .west(data_switch_box_east[1+j*2+(i+NMAC)*2*M+k*2*M*(NMAC+NMEM)]),
		     .control_input(mem_control_input[j+i*M+k*M*NMEM]),
		     .c()
		     );
	    end
	 end
      end
      
      // bottom
      for(j = 0; j < M; j = j + 1) begin : bottom_connection_block
	 for(l = 0; l < WW*MEMDATAIN; l = l + 1) begin
	    tran(data_switch_box_west[j*2+(NMAC+NMEM)*N*2*M][l], data_switch_box_east[1+j*2+(NMAC+NMEM)*N*2*M][l]);
	 end
      end
   endgenerate

   // data connection block
   generate
      for(k = 0; k < N; k = k + 1) begin
	 for(i = 0; i < NMAC; i = i + 1) begin
	    for(j = 0; j < M; j = j + 1) begin : mac_data_connection_block 
	       data_connection_block
		    #(
		      .W(WW*WN),
		      .WW(WW),
		      .DATAIN(MACDATAIN),
		      .DATAOUT(MACDATAOUT)
		      )
	       ccb_east
		    (
		     .north(data_switch_box_south[j*2+i*2*M+k*2*M*(NMAC+NMEM)]),
		     .south(data_switch_box_north[j*2+(i+1)*2*M+k*2*M*(NMAC+NMEM)]),
		     .data_input(mac_data_input_east[j+i*M+k*M*NMAC]),
		     .data_output(mac_data_output[j+i*M+k*M*NMAC]),
		     .c()
		     );
	       
	       data_connection_block
		    #(
		      .W(WW*WN),
		      .WW(WW),
		      .DATAIN(MACDATAIN),
		      .DATAOUT(MACDATAOUT)
		      )
	       ccb_west
		    (
		     .north(data_switch_box_south[1+j*2+i*2*M+k*2*M*(NMAC+NMEM)]),
		     .south(data_switch_box_north[1+j*2+(i+1)*2*M+k*2*M*(NMAC+NMEM)]),
		     .data_input(mac_data_input_west[j+i*M+k*M*NMAC]),
		     .data_output(mac_data_output[j+i*M+k*M*NMAC]),
		     .c()
		     );
	    end
	 end
	 for(i = 0; i < NMEM; i = i + 1) begin
	    for(j = 0; j < M; j = j + 1) begin : mem_data_connection_block 
	       data_connection_block
		    #(
		      .W(WW*WN),
		      .WW(WW),
		      .DATAIN(MEMDATAIN),
		      .DATAOUT(MEMDATAOUT)
		      )
	       ccb_east
		    (
		     .north(data_switch_box_south[j*2+(i+NMAC)*2*M+k*2*M*(NMAC+NMEM)]),
		     .south(data_switch_box_north[j*2+(i+NMAC+1)*2*M+k*2*M*(NMAC+NMEM)]),
		     .data_input(mem_data_input_east[j+i*M+k*M*NMEM]),
		     .data_output(mem_data_output[j+i*M+k*M*NMEM]),
		     .c()
		     );
	       
	       data_connection_block
		    #(
		      .W(WW*WN),
		      .WW(WW),
		      .DATAIN(MEMDATAIN),
		      .DATAOUT(MEMDATAOUT)
		      )
	       ccb_west
		    (
		     .north(data_switch_box_south[1+j*2+(i+NMAC)*2*M+k*2*M*(NMAC+NMEM)]),
		     .south(data_switch_box_north[1+j*2+(i+NMAC+1)*2*M+k*2*M*(NMAC+NMEM)]),
		     .data_input(mem_data_input_west[j+i*M+k*M*NMEM]),
		     .data_output(mem_data_output[j+i*M+k*M*NMEM]),
		     .c()
		     );
	    end
	 end
      end
   endgenerate

   // switch box connector
   generate
      for(k = 0; k < N; k = k + 1) begin
	 for(i = 0; i < NMAC; i = i + 1) begin
	    for(j = 0; j < M; j = j + 1) begin : mac_switch_box_connector
	       wire [(WS+WD+WG)*NSBSB-1:0] east, west;
	       for(l = 0; l < NSBSB; l = l + 1) begin
		  assign east[(l+1)*(WS+WD+WG)-1:l*(WS+WD+WG)] = {horizontal_global[l+i*NCLBMAC+k*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_west_double[MCLB/2+j*(MCLB+1)+(l+i*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_west_single[MCLB/2+j*(MCLB+1)+(l+i*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)]};
		  assign west[(l+1)*(WS+WD+WG)-1:l*(WS+WD+WG)] = {horizontal_global[l+i*NCLBMAC+k*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_east_double[1+MCLB/2+j*(MCLB+1)+(l+i*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_east_single[1+MCLB/2+j*(MCLB+1)+(l+i*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)]};
	       end
	       
	       switch_box_connector
		    #(
		      .W0(WW*WN),
		      .W1((WS+WD+WG)*NSBSB)
		      )
	       sbc_east
		    (
		     .data0(data_switch_box_east[j*2+i*2*M+k*2*M*(NMAC+NMEM)]),
		     .data1(east)
		     );

	       switch_box_connector
		    #(
		      .W0(WW*WN),
		      .W1((WS+WD+WG)*NSBSB)
		      )
	       sbc_west
		    (
		     .data0(data_switch_box_west[1+j*2+i*2*M+k*2*M*(NMAC+NMEM)]),
		     .data1(west)
		     );
	    end
	 end
	 for(i = 0; i < NMEM; i = i + 1) begin
	    for(j = 0; j < M; j = j + 1) begin : mem_switch_box_connector
	       wire [(WS+WD+WG)*NSBSB-1:0] east, west;
	       for(l = 0; l < NSBSB; l = l + 1) begin
		  assign east[(l+1)*(WS+WD+WG)-1:l*(WS+WD+WG)] = {horizontal_global[l+i*NCLBMEM+NMAC*NCLBMAC+k*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_west_double[MCLB/2+j*(MCLB+1)+(l+i*NCLBMEM+NMAC*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_west_single[MCLB/2+j*(MCLB+1)+(l+i*NCLBMEM+NMAC*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)]};
		  assign west[(l+1)*(WS+WD+WG)-1:l*(WS+WD+WG)] = {horizontal_global[l+i*NCLBMEM+NMAC*NCLBMAC+k*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_east_double[1+MCLB/2+j*(MCLB+1)+(l+i*NCLBMEM+NMAC*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)],
								  switch_box_east_single[1+MCLB/2+j*(MCLB+1)+(l+i*NCLBMEM+NMAC*NCLBMAC)*(MCLBFLAT+M+1)+k*(MCLBFLAT+M+1)*(NCLBMAC*NMAC+NCLBMEM*NMEM)]};
	       end
	       
	       switch_box_connector
		    #(
		      .W0(WW*WN),
		      .W1((WS+WD+WG)*NSBSB)
		      )
	       sbc_east
		    (
		     .data0(data_switch_box_east[j*2+(i+NMAC)*2*M+k*2*M*(NMAC+NMEM)]),
		     .data1(east)
		     );

	       switch_box_connector
		    #(
		      .W0(WW*WN),
		      .W1((WS+WD+WG)*NSBSB)
		      )
	       sbc_west
		    (
		     .data0(data_switch_box_west[1+j*2+(i+NMAC)*2*M+k*2*M*(NMAC+NMEM)]),
		     .data1(west)
		     );
	    end
	 end
      end
   endgenerate
endmodule

