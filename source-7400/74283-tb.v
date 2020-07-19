// Test: 4-bit binary full adder with fast carry

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2R_METHOD(tbassert2R)
`CASE_TBASSERT_2R_METHOD(case_tbassert2R, tbassert2R)

localparam WIDTH = 5;

// DUT inputs
reg [WIDTH-1:0] A;
reg [WIDTH-1:0] B;
reg C_in;

// DUT outputs
wire [WIDTH-1:0] Sum;
wire C_out;

// DUT
ttl_74283 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A(A),
  .B(B),
  .C_in(C_in),
  .Sum(Sum),
  .C_out(C_out)
);

initial
begin
  integer i;

  $dumpfile("74283-tb.vcd");
  $dumpvars;

  // all zeroes + Carry 0 -> Sum all 0s + Carry 0
  A = {WIDTH{1'b0}};
  B = {WIDTH{1'b0}};
  C_in = 1'b0;
#4
  tbassert(Sum == 5'b00000, "Test 1");
  tbassert(C_out == 1'b0, "Test 1");
#0
  // all ones (31 + 31) + Carry 1 -> Sum all 1s (31) + Carry 1 (1<<5 == 32)
  A = {WIDTH{1'b1}};
  B = {WIDTH{1'b1}};
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b11111, "Test 2");
  tbassert(C_out == 1'b1, "Test 2");
#0

  // repeat tests: Carry input is clear then set

  for (i = 3; i <= 4; i++)
  begin
    case (i)
      3:
      begin
        C_in = 1'b0;
      end
      4:
      begin
        C_in = 1'b1;
      end
    endcase

    // the following set of tests show the Carry output unaffected by the Carry input
    // (Carry output is clear)

    // 1 + 1 -> 2 + Carry input
    A = 5'b00001;
    B = 5'b00001;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b00010, "Test", "1", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00011, "Test", "1", i);
    tbassert2R(C_out == 1'b0, "Test", "1", i);
#0
    // 1 + 2 -> 3 + Carry input
    // A = 5'b00001;
    B = 5'b00010;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b00011, "Test", "2", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00100, "Test", "2", i);
    tbassert2R(C_out == 1'b0, "Test", "2", i);
#0
    // same on the other inputs
    A = 5'b00010;
    B = 5'b00001;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b00011, "Test", "3", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00100, "Test", "3", i);
    tbassert2R(C_out == 1'b0, "Test", "3", i);
#0

    // the following set of tests show the Carry output affected by the Carry input

    // zeroes on either side and all ones (0 + 31) -> Sum all 1s (31) + Carry input
    A = 5'b00000;
    B = 5'b11111;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b11111, "Test", "4", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00000, "Test", "4", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "4", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "4", i);
#0
    // same on the other inputs
    A = 5'b11111;
    B = 5'b00000;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b11111, "Test", "5", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00000, "Test", "5", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "5", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "5", i);
#0
    // 16 + 15 -> 31 + Carry input
    A = 5'b10000;
    B = 5'b01111;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b11111, "Test", "6", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00000, "Test", "6", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "6", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "6", i);
#0
    // all input bits transition from previous (15 + 16) -> 31 + Carry input
    A = 5'b01111;
    B = 5'b10000;
    C_in = ~C_in;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b11111, "Test", "7", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00000, "Test", "7", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "7", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "7", i);
#0
    C_in = ~C_in;
#10

    // the following set of tests show the Carry output unaffected by the Carry input
    // (Carry output is set)

    // 16 + 16 -> 32 + Carry input
    A = 5'b10000;
    B = 5'b10000;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b00000, "Test", "8", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00001, "Test", "8", i);
    tbassert2R(C_out == 1'b1, "Test", "8", i);
#0
    // 16 + 18 -> 34 + Carry input
    // A = 5'b10000;
    B = 5'b10010;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b00010, "Test", "9", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00011, "Test", "9", i);
    tbassert2R(C_out == 1'b1, "Test", "9", i);
#0
    // 16 + 17 -> 33 + Carry input
    // A = 5'b10000;
    B = 5'b10001;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b00001, "Test", "10", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b00010, "Test", "10", i);
    tbassert2R(C_out == 1'b1, "Test", "10", i);
#0

    // the following set of tests show the Carry output unaffected by the Carry input
    // (Carry output is clear)

    // all input bits transition from previous (15 + 14) -> 29 + Carry input
    A = 5'b01111;
    B = 5'b01110;
    C_in = ~C_in;
#10
    case_tbassert2R(C_in == 1'b0, Sum == 5'b11101, "Test", "11", i);
    case_tbassert2R(C_in == 1'b1, Sum == 5'b11110, "Test", "11", i);
    tbassert2R(C_out == 1'b0, "Test", "11", i);
#0
    C_in = ~C_in;

  end

  // end repeat tests
#0

  // 2 + 2 + Carry 0 -> 4
  A = 5'b00010;
  B = 5'b00010;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b00100, "Test 5");
  tbassert(C_out == 1'b0, "Test 5");
#0
  // 2 + 2 + Carry 1 -> 5
  // A = 5'b00010;
  // B = 5'b00010;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b00101, "Test 6");
  tbassert(C_out == 1'b0, "Test 6");
#0
  // 3 + 5 + Carry 1 -> 9
  A = 5'b00011;
  B = 5'b00101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b01001, "Test 7");
  tbassert(C_out == 1'b0, "Test 7");
#0
  // 13 + 13 + Carry 1 -> 27
  A = 5'b01101;
  B = 5'b01101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b11011, "Test 8");
  tbassert(C_out == 1'b0, "Test 8");
#0
  // 13 + 17 + Carry 1 -> 31
  A = 5'b01101;
  B = 5'b10001;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b11111, "Test 9");
  tbassert(C_out == 1'b0, "Test 9");
#0
  // 17 + 17 + Carry 1 -> 35
  A = 5'b10001;
  B = 5'b10001;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b00011, "Test 10");
  tbassert(C_out == 1'b1, "Test 10");
#0
  // 7 + 27 + Carry 1 -> 35
  A = 5'b00111;
  B = 5'b11011;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b00011, "Test 11");
  tbassert(C_out == 1'b1, "Test 11");
#0
  // 19 + 31 + Carry 1 -> 51
  A = 5'b10011;
  B = 5'b11111;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b10011, "Test 12");
  tbassert(C_out == 1'b1, "Test 12");
#0
  // 23 + 29 + Carry 0 -> 52
  A = 5'b10111;
  B = 5'b11101;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b10100, "Test 13");
  tbassert(C_out == 1'b1, "Test 13");
#0
  // 23 + 29 + Carry 1 -> 53
  // A = 5'b10111;
  // B = 5'b11101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b10101, "Test 14");
  tbassert(C_out == 1'b1, "Test 14");
#0

  // the following set of tests show transitions between input bits that are set to ones
  // with null effect on outputs

  // 3 + 5 + Carry 0 -> 8
  A = 5'b00011;
  B = 5'b00101;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b01000, "Test 15");
  tbassert(C_out == 1'b0, "Test 15");
#0
  // 2 + 5 + Carry 1 -> 8
  A = 5'b00010;
  // B = 5'b00101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b01000, "Test 16");
  tbassert(C_out == 1'b0, "Test 16");
#0
  // 19 + 29 + Carry 0 -> 48
  A = 5'b10011;
  B = 5'b11101;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b10000, "Test 17");
  tbassert(C_out == 1'b1, "Test 17");
#0
  // 29 + 18 + Carry 1 -> 48
  A = 5'b11101;
  B = 5'b10010;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b10000, "Test 18");
  tbassert(C_out == 1'b1, "Test 18");
#10
  $finish;
end

endmodule
