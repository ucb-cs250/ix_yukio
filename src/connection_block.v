module connection_block
  #(
    parameter WS = 8,
    parameter WD= 8, // WD must be multiple of 2
    parameter WG = 3,
    parameter CLBIN = 6,
    parameter CLBIN0 = 6,
    parameter CLBIN1 = 6,
    parameter CLBOUT = 1,
    parameter CLBOUT0 = 1,
    parameter CLBOUT1 = 1,
    parameter CARRY = 1,
    parameter CARRYTYPE = 2,
    parameter CLBOS = 2,
    parameter CLBOS_BIAS = 0,
    parameter CLBOD = 2,
    parameter CLBOD_BIAS = 0,
    parameter CLBX = 1 // toggle using direct connections between CLBs or not
    ) 
   (
    inout [WS-1:0] 	single0, single1,
    inout [WD-1:0] 	double0, double1,
    input [WG-1:0] 	global0,
    input [CLBOUT-1:0] clb0_output,
    input [CLBOUT-1:0] clb1_output,
    input [CARRY-1:0] 	clb0_cout,
    input [CARRY-1:0] 	clb1_cout,
    output [CLBIN-1:0] clb0_input,
    output [CLBIN-1:0] clb1_input,
    output [CARRY-1:0] 	clb0_cin,
    output [CARRY-1:0] 	clb1_cin,
    input [
	   CLBOUT0*(CLBOS+CLBOD)
	   +CLBIN0*(WS+WD+WG+CLBX*CLBOUT1)
	   +CLBOUT1*(CLBOS+CLBOD)
	   +CLBIN1*(WS+WD+WG+CLBX*CLBOUT0)-1:0
	   ] 			c
    );
   
   localparam SWITCH_PER_IN0 = WS + WD + WG + CLBX * CLBOUT1;
   localparam SWITCH_PER_IN1 = WS + WD + WG + CLBX * CLBOUT0;
   localparam SWITCH_PER_OUT = CLBOS + CLBOD;
   
   genvar 		       i, j;

   generate
      for(i = 0; i < WS; i = i + 1) begin : single_wires
	 tran(single0[i], single1[i]);
      end
      for(i = 0; i < WD; i = i + 1) begin : double_wires
	 tran(double0[i], double1[i]);
      end
   endgenerate

   generate
      if(CARRYTYPE%2 == 1) begin
	 assign clb1_cin = clb0_cout;
      end else begin
	 assign clb1_cin = {CARRY{1'b0}};
      end
      if(CARRYTYPE/2 == 1) begin
	 assign clb0_cin = clb1_cout;
      end else begin
	 assign clb0_cin = {CARRY{1'b0}};
      end
   endgenerate
   
   generate
      for(i = 0; i < CLBIN0; i = i + 1) begin
	 for(j = 0; j < WS; j = j + 1) begin : clb0_input_single_switches
	    transmission_gate s(clb0_input[i], single0[j], c[j+i*SWITCH_PER_IN0]);
	 end
	 for(j = 0; j < WD; j = j + 1) begin : clb0_input_double_switches
	    transmission_gate s(clb0_input[i], double0[j], c[j+WS+i*SWITCH_PER_IN0]);
	 end
	 for(j = 0; j < WG; j = j + 1) begin : clb0_input_global_switches
	    transmission_gate s(clb0_input[i], global0[j], c[j+WS+WD+i*SWITCH_PER_IN0]);
	 end
	 if(CLBX) begin
	    for(j = 0; j < CLBOUT1; j = j + 1) begin : clb0_input_direct_connection_switches
	       transmission_gate s(clb0_input[i], clb1_output[j], c[j+WS+WD+WG+i*SWITCH_PER_IN0]);
	    end
	 end
      end
      for(i = 0; i < CLBOUT0; i = i + 1) begin
	 for(j = 0; j < WS; j = j + 1) begin : clb0_output_single_switches
	    if((j + i * CLBOS + CLBOS_BIAS) % WS < CLBOS) begin
	       transmission_gate s(clb0_output[i], single0[j], c[(j+i*CLBOS+CLBOS_BIAS)%WS
								 +i*SWITCH_PER_OUT+CLBIN0*SWITCH_PER_IN0]);
	    end
	 end
	 for(j = 0; j < WD/2; j = j + 1) begin : clb0_output_double_switches
	    if((j + i * CLBOD + CLBOD_BIAS) % (WD / 2) < CLBOD) begin
	       transmission_gate s(clb0_output[i], double0[j], c[(j+i*CLBOD+CLBOD_BIAS)%(WD/2)
								 +CLBOS+i*SWITCH_PER_OUT+CLBIN0*SWITCH_PER_IN0]);
	    end
	 end
      end
   endgenerate

   localparam BASE = CLBOUT0*SWITCH_PER_OUT+CLBIN0*SWITCH_PER_IN0;
   
   generate
      for(i = 0; i < CLBIN1; i = i + 1) begin
	 for(j = 0; j < WS; j = j + 1) begin : clb1_input_single_switches
	    transmission_gate s(clb1_input[i], single0[j], c[BASE+j+i*SWITCH_PER_IN1]);
	 end
	 for(j = 0; j < WD; j = j + 1) begin : clb1_input_double_switches
	    transmission_gate s(clb1_input[i], double0[j], c[BASE+j+WS+i*SWITCH_PER_IN1]);
	 end
	 for(j = 0; j < WG; j = j + 1) begin : clb1_input_global_switches
	    transmission_gate s(clb1_input[i], global0[j], c[BASE+j+WS+WD+i*SWITCH_PER_IN1]);
	 end
	 if(CLBX) begin
	    for(j = 0; j < CLBOUT0; j = j + 1) begin : clb1_input_direct_connection_switches
	       transmission_gate s(clb1_input[i], clb0_output[j], c[BASE+j+WS+WD+WG+i*SWITCH_PER_IN1]);
	    end
	 end
      end
      for(i = 0; i < CLBOUT1; i = i + 1) begin
	 for(j = 0; j < WS; j = j + 1) begin : clb1_output_single_switches
	    if((j + i * CLBOS + CLBOS_BIAS) % WS < CLBOS) begin
	       transmission_gate s(clb1_output[i], single0[j], c[BASE+(j+i*CLBOS+CLBOS_BIAS)%WS
								 +i*SWITCH_PER_OUT+CLBIN1*SWITCH_PER_IN1]);
	    end
	 end
	 for(j = 0; j < WD/2; j = j + 1) begin : clb1_output_double_switches
	    if((j + i * CLBOD + CLBOD_BIAS) % (WD / 2) < CLBOD) begin
	       transmission_gate s(clb1_output[i], double0[j], c[BASE+(j+i*CLBOD+CLBOD_BIAS)%(WD/2)
								 +CLBOS+i*SWITCH_PER_OUT+CLBIN1*SWITCH_PER_IN1]);
	    end
	 end
      end
   endgenerate

endmodule
