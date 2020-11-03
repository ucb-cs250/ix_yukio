module transmission_gate_oneway_tb();

  reg b, c;
  wire a;

  transmission_gate_oneway dut (
    .a(a),
    .b(b),
    .c(c)
  );

  initial begin
    // set b to be 1'b1
    b = 1'b1;
    $display("test passed is 1, fail is 0");

    c = 1'b0;
    #1 $display("when c is %b, a is %b, test passed: %b", c, a, (a === 1'bz));    
    c = 1'b1;
    #1 $display("when c is %b, a is %b, test passed: %b", c, a, (a === b));

    $finish();
  end

endmodule

