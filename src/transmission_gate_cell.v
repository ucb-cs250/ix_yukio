module transmission_gate_cell(inout a, inout b, input c, input c_not);
  // Use the verilog primitive where available, in which case c_not is not
  // used.
  tranif1(a, b, c);
endmodule
