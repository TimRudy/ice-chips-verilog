// Test: 4-bit magnitude comparator

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2R_METHOD(tbassert2R)

localparam WIDTH_IN = 5;

// DUT inputs
reg [WIDTH_IN-1:0] A;
reg [WIDTH_IN-1:0] B;
reg ALess_in;
reg Equal_in;
reg AGreater_in;

// DUT outputs
wire ALess_out;
wire Equal_out;
wire AGreater_out;

// DUT
ttl_7485 #(.WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A(A),
  .B(B),
  .ALess_in(ALess_in),
  .Equal_in(Equal_in),
  .AGreater_in(AGreater_in),
  .ALess_out(ALess_out),
  .Equal_out(Equal_out),
  .AGreater_out(AGreater_out)
);

initial
begin
  integer i;

  $dumpfile("7485-tb.vcd");
  $dumpvars;

  // repeat tests: three different valid cascading inputs

  for (i = 1; i <= 3; i++)
  begin
    case (i)
      1:
      begin
        ALess_in = 1'b1;
        Equal_in = 1'b0;
        AGreater_in = 1'b0;
      end
      2:
      begin
        ALess_in = 1'b0;
        Equal_in = 1'b1;
        AGreater_in = 1'b0;
      end
      3:
      begin
        ALess_in = 1'b0;
        Equal_in = 1'b0;
        AGreater_in = 1'b1;
      end
    endcase

    // the following set of tests show the result is affected by the cascading inputs:
    // since A and B are equal, the output result is equality only if input Equal_in
    // is set; otherwise the output result tracks input ALess_in or input AGreater_in

    // A and B zeroes -> equal
    A = {WIDTH_IN{1'b0}};
    B = {WIDTH_IN{1'b0}};
#6
    tbassert2R(ALess_out == ALess_in, "Test", "1", i);
    tbassert2R(Equal_out == Equal_in, "Test", "1", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "1", i);
#0
    // A and B ones -> equal
    A = {WIDTH_IN{1'b1}};
    B = {WIDTH_IN{1'b1}};
#6
    tbassert2R(ALess_out == ALess_in, "Test", "2", i);
    tbassert2R(Equal_out == Equal_in, "Test", "2", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "2", i);
#0
    // A and B mixed -> equal
    A = 5'b01101;
    B = 5'b01101;
#6
    tbassert2R(ALess_out == ALess_in, "Test", "3", i);
    tbassert2R(Equal_out == Equal_in, "Test", "3", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "3", i);
#0
    // A and B high bit set -> equal
    A = 5'b10000;
    B = 5'b10000;
#6
    tbassert2R(ALess_out == ALess_in, "Test", "4", i);
    tbassert2R(Equal_out == Equal_in, "Test", "4", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "4", i);
#0
    // A and B low bit set -> equal
    A = 5'b00001;
    B = 5'b00001;
#6
    tbassert2R(ALess_out == ALess_in, "Test", "5", i);
    tbassert2R(Equal_out == Equal_in, "Test", "5", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "5", i);
#0
    // arbitrary binary numbers -> equal
    A = 5'b10011;
    B = 5'b10011;
#10
    tbassert2R(ALess_out == ALess_in, "Test", "6", i);
    tbassert2R(Equal_out == Equal_in, "Test", "6", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "6", i);
#0
    // all input bits transition from previous with null change to outputs -> equal
    A = 5'b01100;
    B = 5'b01100;
#10
    tbassert2R(ALess_out == ALess_in, "Test", "7", i);
    tbassert2R(Equal_out == Equal_in, "Test", "7", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "7", i);
#0
    // all bits on one side transition from previous -> equal
    A = 5'b00011;
    B = 5'b11100;
#6
    tbassert2R(Equal_out == 1'b0, "Test", "8", i);
#0
    A = 5'b00011;
    B = 5'b00011;
#10
    tbassert2R(ALess_out == ALess_in, "Test", "8", i);
    tbassert2R(Equal_out == Equal_in, "Test", "8", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "8", i);
#0
    // same on the other side -> equal
    A = 5'b00011;
    B = 5'b11100;
#6
    tbassert2R(Equal_out == 1'b0, "Test", "9", i);
#0
    A = 5'b11100;
    B = 5'b11100;
#10
    tbassert2R(ALess_out == ALess_in, "Test", "9", i);
    tbassert2R(Equal_out == Equal_in, "Test", "9", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "9", i);
#0
    // single bit from one to zero causes -> equal
    A = 5'b00001;
    B = 5'b00011;
#6
    tbassert2R(Equal_out == 1'b0, "Test", "10", i);
#0
    B[1] = 1'b0;
    // A = 5'b00001;
    // B = 5'b00001;
#10
    tbassert2R(ALess_out == ALess_in, "Test", "10", i);
    tbassert2R(Equal_out == Equal_in, "Test", "10", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "10", i);
#0
    // single bit from zero to one causes -> equal
    A = 5'b00100;
    B = 5'b01100;
#6
    tbassert2R(Equal_out == 1'b0, "Test", "11", i);
#0
    A[3] = 1'b1;
    // A = 5'b01100;
    // B = 5'b01100;
#10
    tbassert2R(ALess_out == ALess_in, "Test", "11", i);
    tbassert2R(Equal_out == Equal_in, "Test", "11", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "11", i);
#0
    // multiple bits change with null change to outputs -> equal
    A = 5'b10101;
    B = 5'b10101;
#10
    tbassert2R(ALess_out == ALess_in, "Test", "12", i);
    tbassert2R(Equal_out == Equal_in, "Test", "12", i);
    tbassert2R(AGreater_out == AGreater_in, "Test", "12", i);
#0

    // the following set of tests show the result is unaffected by the cascading inputs
    // (except for some set-ups of equality in the main inputs A and B)

    // single low bit set -> greater than
    A = 5'b00001;
    B = 5'b00000;
#10
    tbassert2R(ALess_out == 1'b0, "Test", "13", i);
    tbassert2R(Equal_out == 1'b0, "Test", "13", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "13", i);
#0
    // same on the other side -> less than
    A = 5'b00000;
    B = 5'b00001;
#10
    tbassert2R(ALess_out == 1'b1, "Test", "14", i);
    tbassert2R(Equal_out == 1'b0, "Test", "14", i);
    tbassert2R(AGreater_out == 1'b0, "Test", "14", i);
#0
    // single high bit set -> greater than
    A = 5'b10000;
    B = 5'b00000;
#6
    tbassert2R(ALess_out == 1'b0, "Test", "15", i);
    tbassert2R(Equal_out == 1'b0, "Test", "15", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "15", i);
#0
    // same on the other side -> less than
    A = 5'b00000;
    B = 5'b10000;
#10
    tbassert2R(ALess_out == 1'b1, "Test", "16", i);
    tbassert2R(Equal_out == 1'b0, "Test", "16", i);
    tbassert2R(AGreater_out == 1'b0, "Test", "16", i);
#0
    // arbitrary binary numbers -> less than
    A = 5'b01100;
    B = 5'b10110;
#10
    tbassert2R(ALess_out == 1'b1, "Test", "17", i);
    tbassert2R(Equal_out == 1'b0, "Test", "17", i);
    tbassert2R(AGreater_out == 1'b0, "Test", "17", i);
#0
    // arbitrary binary numbers -> greater than
    A = 5'b11010;
    B = 5'b00011;
#10
    tbassert2R(ALess_out == 1'b0, "Test", "18", i);
    tbassert2R(Equal_out == 1'b0, "Test", "18", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "18", i);
#0
    // all bits on one side transition from previous -> greater than
    A = 5'b10011;
    B = 5'b10011;
#6
    tbassert2R(AGreater_out == AGreater_in, "Test", "19", i);
#0
    A = 5'b10011;
    B = 5'b01100;
#10
    tbassert2R(ALess_out == 1'b0, "Test", "19", i);
    tbassert2R(Equal_out == 1'b0, "Test", "19", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "19", i);
#0
    // same single bit on each side transition from previous -> less than
    A[4] = 1'b0;
    B[4] = 1'b1;
    // A = 5'b00011;
    // B = 5'b11100;
#10
    tbassert2R(ALess_out == 1'b1, "Test", "20", i);
    tbassert2R(Equal_out == 1'b0, "Test", "20", i);
    tbassert2R(AGreater_out == 1'b0, "Test", "20", i);
#0
    // single bit from one to zero causes -> greater than
    A = 5'b11100;
    B = 5'b11100;
#6
    tbassert2R(AGreater_out == AGreater_in, "Test", "21", i);
#0
    B[2] = 1'b0;
    // A = 5'b11100;
    // B = 5'b11000;
#10
    tbassert2R(ALess_out == 1'b0, "Test", "21", i);
    tbassert2R(Equal_out == 1'b0, "Test", "21", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "21", i);
#0
    // single bit from one to zero causes -> less than
    A[3] = 1'b0;
    // A = 5'b10100;
    // B = 5'b11000;
#10
    tbassert2R(ALess_out == 1'b1, "Test", "22", i);
    tbassert2R(Equal_out == 1'b0, "Test", "22", i);
    tbassert2R(AGreater_out == 1'b0, "Test", "22", i);
#0
    // single bit from zero to one causes -> greater than
    A = 5'b00100;
    B = 5'b00100;
#6
    tbassert2R(AGreater_out == AGreater_in, "Test", "23", i);
#0
    A[1] = 1'b1;
    // A = 5'b00110;
    // B = 5'b00100;
#10
    tbassert2R(ALess_out == 1'b0, "Test", "23", i);
    tbassert2R(Equal_out == 1'b0, "Test", "23", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "23", i);
#0
    // single bit from zero to one causes -> less than
    B[3] = 1'b1;
    // A = 5'b00110;
    // B = 5'b01100;
#10
    tbassert2R(ALess_out == 1'b1, "Test", "24", i);
    tbassert2R(Equal_out == 1'b0, "Test", "24", i);
    tbassert2R(AGreater_out == 1'b0, "Test", "24", i);
#0
    // multiple bits change with null change to outputs -> less than
    A = 5'b10101;
    B = 5'b11110;
#10
    tbassert2R(ALess_out == 1'b1, "Test", "25", i);
    tbassert2R(Equal_out == 1'b0, "Test", "25", i);
    tbassert2R(AGreater_out == 1'b0, "Test", "25", i);
#0
    // all bits on both sides transition -> greater than
    A = 5'b01010;
    B = 5'b00001;
#10
    tbassert2R(ALess_out == 1'b0, "Test", "26", i);
    tbassert2R(Equal_out == 1'b0, "Test", "26", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "26", i);
#0
    // timing: clear inputs, then must wait for outputs to transition ->
    // greater than
    A = {WIDTH_IN{1'bx}};
    B = {WIDTH_IN{1'bx}};
    ALess_in = 1'bx;
    Equal_in = 1'bx;
    AGreater_in = 1'bx;
#10
    A = 5'b01010;
    B = 5'b00001;

    case (i)
      1:
      begin
        ALess_in = 1'b1;
        Equal_in = 1'b0;
        AGreater_in = 1'b0;
      end
      2:
      begin
        ALess_in = 1'b0;
        Equal_in = 1'b1;
        AGreater_in = 1'b0;
      end
      3:
      begin
        ALess_in = 1'b0;
        Equal_in = 1'b0;
        AGreater_in = 1'b1;
      end
    endcase
#2
    tbassert2R(ALess_out === 1'bx, "Test", "27", i);
    tbassert2R(Equal_out === 1'bx, "Test", "27", i);
    tbassert2R(AGreater_out === 1'bx, "Test", "27", i);
#4
    tbassert2R(ALess_out == 1'b0, "Test", "27", i);
    tbassert2R(Equal_out == 1'b0, "Test", "27", i);
    tbassert2R(AGreater_out == 1'b1, "Test", "27", i);

  end

  // end repeat tests
#0

  // cascading input Equal_in set, A and B equal: other cascading inputs
  // become irrelevant (both set) -> output result is equality
  A = 5'b01010;
  B = 5'b01010;
  ALess_in = 1'b1;
  Equal_in = 1'b1;
  AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b0, "Test 4");
  tbassert(Equal_out == 1'b1, "Test 4");
  tbassert(AGreater_out == 1'b0, "Test 4");
#0
  // same, the other cascading inputs set and clear -> output result is equality
  AGreater_in = 1'b0;
#10
  tbassert(ALess_out == 1'b0, "Test 5");
  tbassert(Equal_out == 1'b1, "Test 5");
  tbassert(AGreater_out == 1'b0, "Test 5");
#0
  // same, the other cascading inputs both clear -> output result is equality
  ALess_in = 1'b0;
#10
  tbassert(ALess_out == 1'b0, "Test 6");
  tbassert(Equal_out == 1'b1, "Test 6");
  tbassert(AGreater_out == 1'b0, "Test 6");
#0
  // same, transition from A and B not equal -> output result is equality
  A = 5'b01010;
  B = 5'b01111;
  ALess_in = 1'b1;
  Equal_in = 1'b1;
  AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b1, "Test 7");
  tbassert(Equal_out == 1'b0, "Test 7");
  tbassert(AGreater_out == 1'b0, "Test 7");
#0
  A = 5'b01010;
  B = 5'b01010;
#10
  tbassert(ALess_out == 1'b0, "Test 7");
  tbassert(Equal_out == 1'b1, "Test 7");
  tbassert(AGreater_out == 1'b0, "Test 7");
#0
  // abnormal inputs used in parallel expansion configuration:
  // cascading inputs ALess_in, Equal_in, AGreater_in all clear
  // at the same time, A and B equal -> output Equal_out 0, other outputs 1
  A = 5'b11110;
  B = 5'b11110;
  ALess_in = 1'b0;
  Equal_in = 1'b0;
  AGreater_in = 1'b0;
#10
  tbassert(ALess_out == 1'b1, "Test 8");
  tbassert(Equal_out == 1'b0, "Test 8");
  tbassert(AGreater_out == 1'b1, "Test 8");
#0
  // same, transition from A and B not equal -> output Equal_out 0, other outputs 1
  A = 5'b01010;
  B = 5'b01111;
  // ALess_in = 1'b0;
  // Equal_in = 1'b0;
  // AGreater_in = 1'b0;
#10
  tbassert(ALess_out == 1'b1, "Test 9");
  tbassert(Equal_out == 1'b0, "Test 9");
  tbassert(AGreater_out == 1'b0, "Test 9");
#0
  A = 5'b01010;
  B = 5'b01010;
#10
  tbassert(ALess_out == 1'b1, "Test 9");
  tbassert(Equal_out == 1'b0, "Test 9");
  tbassert(AGreater_out == 1'b1, "Test 9");
#0
  // abnormal inputs used in parallel expansion configuration:
  // cascading inputs ALess_in, AGreater_in both set, input Equal_in clear,
  // A and B equal -> all outputs 0
  ALess_in = 1'b1;
  Equal_in = 1'b0;
  AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b0, "Test 10");
  tbassert(Equal_out == 1'b0, "Test 10");
  tbassert(AGreater_out == 1'b0, "Test 10");
#0
  // same, transition from A and B not equal -> all outputs 0
  A = 5'b01010;
  B = 5'b01111;
  // ALess_in = 1'b1;
  // Equal_in = 1'b0;
  // AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b1, "Test 11");
  tbassert(Equal_out == 1'b0, "Test 11");
  tbassert(AGreater_out == 1'b0, "Test 11");
#0
  A = 5'b01111;
  B = 5'b01111;
#10
  tbassert(ALess_out == 1'b0, "Test 11");
  tbassert(Equal_out == 1'b0, "Test 11");
  tbassert(AGreater_out == 1'b0, "Test 11");
#10
  $finish;
end

endmodule
