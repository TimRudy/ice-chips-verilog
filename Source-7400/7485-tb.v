module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)

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

  for (i = 1; i <= 3; i += 1)
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

    // the following set of tests is affected by the cascading inputs:
    // since A and B are equal, the output result is equality only if "Equal_in"
    // is set; otherwise it follows input "ALess_in" or "AGreater_in"

    // A and B zeroes -> equal
    A = {WIDTH_IN{1'b0}};
    B = {WIDTH_IN{1'b0}};
#6
    tbassert2(ALess_out == ALess_in, "Test", i, "1");
    tbassert2(Equal_out == Equal_in, "Test", i, "1");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "1");
#0
    // A and B ones -> equal
    A = {WIDTH_IN{1'b1}};
    B = {WIDTH_IN{1'b1}};
#6
    tbassert2(ALess_out == ALess_in, "Test", i, "2");
    tbassert2(Equal_out == Equal_in, "Test", i, "2");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "2");
#0
    // A and B mixed -> equal
    A = 5'b01101;
    B = 5'b01101;
#6
    tbassert2(ALess_out == ALess_in, "Test", i, "3");
    tbassert2(Equal_out == Equal_in, "Test", i, "3");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "3");
#0
    // A and B high bit set -> equal
    A = 5'b10000;
    B = 5'b10000;
#6
    tbassert2(ALess_out == ALess_in, "Test", i, "4");
    tbassert2(Equal_out == Equal_in, "Test", i, "4");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "4");
#0
    // A and B low bit set -> equal
    A = 5'b00001;
    B = 5'b00001;
#6
    tbassert2(ALess_out == ALess_in, "Test", i, "5");
    tbassert2(Equal_out == Equal_in, "Test", i, "5");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "5");
#0
    // arbitrary binary numbers -> equal
    A = 5'b10011;
    B = 5'b10011;
#10
    tbassert2(ALess_out == ALess_in, "Test", i, "6");
    tbassert2(Equal_out == Equal_in, "Test", i, "6");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "6");
#0
    // all input bits transition from previous with null change to outputs -> equal
    A = 5'b01100;
    B = 5'b01100;
#10
    tbassert2(ALess_out == ALess_in, "Test", i, "7");
    tbassert2(Equal_out == Equal_in, "Test", i, "7");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "7");
#0
    // all bits on one side transition from previous -> equal
    A = 5'b00011;
    B = 5'b11100;
#6
    tbassert2(Equal_out == 1'b0, "Test", i, "8");
#0
    A = 5'b00011;
    B = 5'b00011;
#10
    tbassert2(ALess_out == ALess_in, "Test", i, "8");
    tbassert2(Equal_out == Equal_in, "Test", i, "8");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "8");
#0
    // same on the other side -> equal
    A = 5'b00011;
    B = 5'b11100;
#6
    tbassert2(Equal_out == 1'b0, "Test", i, "9");
#0
    A = 5'b11100;
    B = 5'b11100;
#10
    tbassert2(ALess_out == ALess_in, "Test", i, "9");
    tbassert2(Equal_out == Equal_in, "Test", i, "9");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "9");
#0
    // single bit from one to zero causes -> equal
    A = 5'b00001;
    B = 5'b00011;
#6
    tbassert2(Equal_out == 1'b0, "Test", i, "10");
#0
    B[1] = 1'b0;
    // A = 5'b00001;
    // B = 5'b00001;
#10
    tbassert2(ALess_out == ALess_in, "Test", i, "10");
    tbassert2(Equal_out == Equal_in, "Test", i, "10");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "10");
#0
    // single bit from zero to one causes -> equal
    A = 5'b00100;
    B = 5'b01100;
#6
    tbassert2(Equal_out == 1'b0, "Test", i, "11");
#0
    A[3] = 1'b1;
    // A = 5'b01100;
    // B = 5'b01100;
#10
    tbassert2(ALess_out == ALess_in, "Test", i, "11");
    tbassert2(Equal_out == Equal_in, "Test", i, "11");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "11");
#0
    // multiple bits change with null change to outputs -> equal
    A = 5'b10101;
    B = 5'b10101;
#10
    tbassert2(ALess_out == ALess_in, "Test", i, "12");
    tbassert2(Equal_out == Equal_in, "Test", i, "12");
    tbassert2(AGreater_out == AGreater_in, "Test", i, "12");
#0

    // the following set of tests is unaffected by the cascading inputs
    // (except for some set-ups of equality in the main inputs A and B)

    // single low bit set -> greater than
    A = 5'b00001;
    B = 5'b00000;
#10
    tbassert2(ALess_out == 1'b0, "Test", i, "13");
    tbassert2(Equal_out == 1'b0, "Test", i, "13");
    tbassert2(AGreater_out == 1'b1, "Test", i, "13");
#0
    // same on the other side -> less than
    A = 5'b00000;
    B = 5'b00001;
#10
    tbassert2(ALess_out == 1'b1, "Test", i, "14");
    tbassert2(Equal_out == 1'b0, "Test", i, "14");
    tbassert2(AGreater_out == 1'b0, "Test", i, "14");
#0
    // single high bit set -> greater than
    A = 5'b10000;
    B = 5'b00000;
#6
    tbassert2(ALess_out == 1'b0, "Test", i, "15");
    tbassert2(Equal_out == 1'b0, "Test", i, "15");
    tbassert2(AGreater_out == 1'b1, "Test", i, "15");
#0
    // same on the other side -> less than
    A = 5'b00000;
    B = 5'b10000;
#10
    tbassert2(ALess_out == 1'b1, "Test", i, "16");
    tbassert2(Equal_out == 1'b0, "Test", i, "16");
    tbassert2(AGreater_out == 1'b0, "Test", i, "16");
#0
    // arbitrary binary numbers -> less than
    A = 5'b01100;
    B = 5'b10110;
#10
    tbassert2(ALess_out == 1'b1, "Test", i, "17");
    tbassert2(Equal_out == 1'b0, "Test", i, "17");
    tbassert2(AGreater_out == 1'b0, "Test", i, "17");
#0
    // arbitrary binary numbers -> greater than
    A = 5'b11010;
    B = 5'b00011;
#10
    tbassert2(ALess_out == 1'b0, "Test", i, "18");
    tbassert2(Equal_out == 1'b0, "Test", i, "18");
    tbassert2(AGreater_out == 1'b1, "Test", i, "18");
#0
    // all bits on one side transition from previous -> greater than
    A = 5'b10011;
    B = 5'b10011;
#6
    tbassert2(AGreater_out == AGreater_in, "Test", i, "19");
#0
    A = 5'b10011;
    B = 5'b01100;
#10
    tbassert2(ALess_out == 1'b0, "Test", i, "19");
    tbassert2(Equal_out == 1'b0, "Test", i, "19");
    tbassert2(AGreater_out == 1'b1, "Test", i, "19");
#0
    // same single bit on each side transition from previous -> less than
    A[4] = 1'b0;
    B[4] = 1'b1;
    // A = 5'b00011;
    // B = 5'b11100;
#10
    tbassert2(ALess_out == 1'b1, "Test", i, "20");
    tbassert2(Equal_out == 1'b0, "Test", i, "20");
    tbassert2(AGreater_out == 1'b0, "Test", i, "20");
#0
    // single bit from one to zero causes -> greater than
    A = 5'b11100;
    B = 5'b11100;
#6
    tbassert2(AGreater_out == AGreater_in, "Test", i, "21");
#0
    B[2] = 1'b0;
    // A = 5'b11100;
    // B = 5'b11000;
#10
    tbassert2(ALess_out == 1'b0, "Test", i, "21");
    tbassert2(Equal_out == 1'b0, "Test", i, "21");
    tbassert2(AGreater_out == 1'b1, "Test", i, "21");
#0
    // single bit from one to zero causes -> less than
    A[3] = 1'b0;
    // A = 5'b10100;
    // B = 5'b11000;
#10
    tbassert2(ALess_out == 1'b1, "Test", i, "22");
    tbassert2(Equal_out == 1'b0, "Test", i, "22");
    tbassert2(AGreater_out == 1'b0, "Test", i, "22");
#0
    // single bit from zero to one causes -> greater than
    A = 5'b00100;
    B = 5'b00100;
#6
    tbassert2(AGreater_out == AGreater_in, "Test", i, "23");
#0
    A[1] = 1'b1;
    // A = 5'b00110;
    // B = 5'b00100;
#10
    tbassert2(ALess_out == 1'b0, "Test", i, "23");
    tbassert2(Equal_out == 1'b0, "Test", i, "23");
    tbassert2(AGreater_out == 1'b1, "Test", i, "23");
#0
    // single bit from zero to one causes -> less than
    B[3] = 1'b1;
    // A = 5'b00110;
    // B = 5'b01100;
#10
    tbassert2(ALess_out == 1'b1, "Test", i, "24");
    tbassert2(Equal_out == 1'b0, "Test", i, "24");
    tbassert2(AGreater_out == 1'b0, "Test", i, "24");
#0
    // multiple bits change with null change to outputs -> less than
    A = 5'b10101;
    B = 5'b11110;
#10
    tbassert2(ALess_out == 1'b1, "Test", i, "25");
    tbassert2(Equal_out == 1'b0, "Test", i, "25");
    tbassert2(AGreater_out == 1'b0, "Test", i, "25");
#0
    // all bits on both sides transition -> greater than
    A = 5'b01010;
    B = 5'b00001;
#10
    tbassert2(ALess_out == 1'b0, "Test", i, "26");
    tbassert2(Equal_out == 1'b0, "Test", i, "26");
    tbassert2(AGreater_out == 1'b1, "Test", i, "26");
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
    tbassert2(ALess_out === 1'bx, "Test", i, "27");
    tbassert2(Equal_out === 1'bx, "Test", i, "27");
    tbassert2(AGreater_out === 1'bx, "Test", i, "27");
#4
    tbassert2(ALess_out == 1'b0, "Test", i, "27");
    tbassert2(Equal_out == 1'b0, "Test", i, "27");
    tbassert2(AGreater_out == 1'b1, "Test", i, "27");

  end

  // end repeat tests
#0

  // cascading input "Equal_in" set, A and B equal: other cascading inputs
  // become irrelevant (both set) -> output result is equality
  A = 5'b01010;
  B = 5'b01010;
  ALess_in = 1'b1;
  Equal_in = 1'b1;
  AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b0, "Test 28");
  tbassert(Equal_out == 1'b1, "Test 28");
  tbassert(AGreater_out == 1'b0, "Test 28");
#0
  // same, the other cascading inputs set and clear -> output result is equality
  AGreater_in = 1'b0;
#10
  tbassert(ALess_out == 1'b0, "Test 29");
  tbassert(Equal_out == 1'b1, "Test 29");
  tbassert(AGreater_out == 1'b0, "Test 29");
#0
  // same, the other cascading inputs both clear -> output result is equality
  ALess_in = 1'b0;
#10
  tbassert(ALess_out == 1'b0, "Test 30");
  tbassert(Equal_out == 1'b1, "Test 30");
  tbassert(AGreater_out == 1'b0, "Test 30");
#0
  // same, transition from A and B not equal -> output result is equality
  A = 5'b01010;
  B = 5'b01111;
  ALess_in = 1'b1;
  Equal_in = 1'b1;
  AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b1, "Test 31");
  tbassert(Equal_out == 1'b0, "Test 31");
  tbassert(AGreater_out == 1'b0, "Test 31");
#0
  A = 5'b01010;
  B = 5'b01010;
#10
  tbassert(ALess_out == 1'b0, "Test 31");
  tbassert(Equal_out == 1'b1, "Test 31");
  tbassert(AGreater_out == 1'b0, "Test 31");
#0
  // abnormal inputs used in parallel expansion configuration:
  // cascading inputs "ALess_in", "Equal_in", "AGreater_in" all clear
  // at the same time, A and B equal -> "Equal_out" 0, other outputs 1
  A = 5'b11110;
  B = 5'b11110;
  ALess_in = 1'b0;
  Equal_in = 1'b0;
  AGreater_in = 1'b0;
#10
  tbassert(ALess_out == 1'b1, "Test 32");
  tbassert(Equal_out == 1'b0, "Test 32");
  tbassert(AGreater_out == 1'b1, "Test 32");
#0
  // same, transition from A and B not equal -> "Equal_out" 0, other outputs 1
  A = 5'b01010;
  B = 5'b01111;
  // ALess_in = 1'b0;
  // Equal_in = 1'b0;
  // AGreater_in = 1'b0;
#10
  tbassert(ALess_out == 1'b1, "Test 33");
  tbassert(Equal_out == 1'b0, "Test 33");
  tbassert(AGreater_out == 1'b0, "Test 33");
#0
  A = 5'b01010;
  B = 5'b01010;
#10
  tbassert(ALess_out == 1'b1, "Test 33");
  tbassert(Equal_out == 1'b0, "Test 33");
  tbassert(AGreater_out == 1'b1, "Test 33");
#0
  // abnormal inputs used in parallel expansion configuration:
  // cascading inputs "ALess_in", "AGreater_in" both set, "Equal_in" clear,
  // A and B equal -> all outputs 0
  ALess_in = 1'b1;
  Equal_in = 1'b0;
  AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b0, "Test 34");
  tbassert(Equal_out == 1'b0, "Test 34");
  tbassert(AGreater_out == 1'b0, "Test 34");
#0
  // same, transition from A and B not equal -> all outputs 0
  A = 5'b01010;
  B = 5'b01111;
  // ALess_in = 1'b1;
  // Equal_in = 1'b0;
  // AGreater_in = 1'b1;
#10
  tbassert(ALess_out == 1'b1, "Test 35");
  tbassert(Equal_out == 1'b0, "Test 35");
  tbassert(AGreater_out == 1'b0, "Test 35");
#0
  A = 5'b01111;
  B = 5'b01111;
#10
  tbassert(ALess_out == 1'b0, "Test 35");
  tbassert(Equal_out == 1'b0, "Test 35");
  tbassert(AGreater_out == 1'b0, "Test 35");
#10
  $finish;
end

endmodule
