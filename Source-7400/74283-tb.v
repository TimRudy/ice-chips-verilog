// Test: 4-bit binary full adder with fast carry

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)
`CASE_TBASSERT_2_METHOD(case_tbassert2, tbassert2)

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

  // all zeroes -> 0s
  A = {WIDTH{1'b0}};
  B = {WIDTH{1'b0}};
  C_in = 1'b0;
#4
  tbassert(Sum == 5'b00000, "Test 1");
  tbassert(C_out == 1'b0, "Test 1");
#0
  // all ones (31 + 31 + 1) -> Sum all 1s (31) + Carry 1 (1<<32)
  A = {WIDTH{1'b1}};
  B = {WIDTH{1'b1}};
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b11111, "Test 2");
  tbassert(C_out == 1'b1, "Test 2");
#0

  // repeat tests: "C_in" is clear then set

  for (i = 1; i <= 2; i=i+1)
  begin
    case (i)
      1:
      begin
        C_in = 1'b0;
      end
      2:
      begin
        C_in = 1'b1;
      end
    endcase

    // the following set of tests show the Carry output unaffected by the Carry input

    // 1 + 1 -> 2 + Carry
    A = 5'b00001;
    B = 5'b00001;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b00010, "Test", i, "3");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00011, "Test", i, "3");
    tbassert2(C_out == 1'b0, "Test", i, "3");
#0
    // 1 + 2 -> 3 + Carry
    // A = 5'b00001;
    B = 5'b00010;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b00011, "Test", i, "4");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00100, "Test", i, "4");
    tbassert2(C_out == 1'b0, "Test", i, "4");
#0
    // same on the other inputs
    A = 5'b00010;
    B = 5'b00001;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b00011, "Test", i, "5");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00100, "Test", i, "5");
    tbassert2(C_out == 1'b0, "Test", i, "5");
#0

    // the following set of tests show the Carry output affected by the Carry input

    // zeroes on either side and all ones (0 + 31) -> Sum all 1s (31) + Carry
    A = 5'b00000;
    B = 5'b11111;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b11111, "Test", i, "6");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00000, "Test", i, "6");
    case_tbassert2(C_in == 1'b0, C_out == 1'b0, "Test", i, "6");
    case_tbassert2(C_in == 1'b1, C_out == 1'b1, "Test", i, "6");
#0
    // same on the other inputs
    A = 5'b11111;
    B = 5'b00000;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b11111, "Test", i, "7");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00000, "Test", i, "7");
    case_tbassert2(C_in == 1'b0, C_out == 1'b0, "Test", i, "7");
    case_tbassert2(C_in == 1'b1, C_out == 1'b1, "Test", i, "7");
#0
    // 16 + 15 -> 31 + Carry
    A = 5'b10000;
    B = 5'b01111;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b11111, "Test", i, "8");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00000, "Test", i, "8");
    case_tbassert2(C_in == 1'b0, C_out == 1'b0, "Test", i, "8");
    case_tbassert2(C_in == 1'b1, C_out == 1'b1, "Test", i, "8");
#0
    // all input bits transition from previous (15 + 16) -> 31 + Carry
    A = 5'b01111;
    B = 5'b10000;
    C_in = ~C_in;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b11111, "Test", i, "9");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00000, "Test", i, "9");
    case_tbassert2(C_in == 1'b0, C_out == 1'b0, "Test", i, "9");
    case_tbassert2(C_in == 1'b1, C_out == 1'b1, "Test", i, "9");
#0
    C_in = ~C_in;
#10

    // the following set of tests show the Carry output unaffected by the Carry input

    // 16 + 16 -> 32 + Carry
    A = 5'b10000;
    B = 5'b10000;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b00000, "Test", i, "10");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00001, "Test", i, "10");
    tbassert2(C_out == 1'b1, "Test", i, "10");
#0
    // 16 + 17 -> 33 + Carry
    // A = 5'b10000;
    B = 5'b10001;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b00001, "Test", i, "11");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00010, "Test", i, "11");
    tbassert2(C_out == 1'b1, "Test", i, "11");
#0
    // all input bits transition from previous (15 + 14) -> 29 + Carry
    A = 5'b01111;
    B = 5'b01110;
    C_in = ~C_in;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b11101, "Test", i, "12");
    case_tbassert2(C_in == 1'b1, Sum == 5'b11110, "Test", i, "12");
    tbassert2(C_out == 1'b0, "Test", i, "12");
#0
    C_in = ~C_in;
#10
    // 16 + 18 -> 34 + Carry
    A = 5'b10000;
    B = 5'b10010;
#10
    case_tbassert2(C_in == 1'b0, Sum == 5'b00010, "Test", i, "13");
    case_tbassert2(C_in == 1'b1, Sum == 5'b00011, "Test", i, "13");
    tbassert2(C_out == 1'b1, "Test", i, "13");

  end

  // end repeat tests
#0

  // 2 + 2 + Carry 0 -> 4
  A = 5'b00010;
  B = 5'b00010;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b00100, "Test 14");
  tbassert(C_out == 1'b0, "Test 14");
#0
  // 2 + 2 + Carry 1 -> 5
  // A = 5'b00010;
  // B = 5'b00010;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b00101, "Test 15");
  tbassert(C_out == 1'b0, "Test 15");
#0
  // 3 + 5 + Carry 1 -> 9
  A = 5'b00011;
  B = 5'b00101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b01001, "Test 16");
  tbassert(C_out == 1'b0, "Test 16");
#0
  // 13 + 13 + Carry 1 -> 27
  A = 5'b01101;
  B = 5'b01101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b11011, "Test 17");
  tbassert(C_out == 1'b0, "Test 17");
#0
  // 13 + 17 + Carry 1 -> 31
  A = 5'b01101;
  B = 5'b10001;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b11111, "Test 18");
  tbassert(C_out == 1'b0, "Test 18");
#0
  // 17 + 17 + Carry 1 -> 35
  A = 5'b10001;
  B = 5'b10001;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b00011, "Test 19");
  tbassert(C_out == 1'b1, "Test 19");
#0
  // 7 + 27 + Carry 1 -> 35
  A = 5'b00111;
  B = 5'b11011;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b00011, "Test 20");
  tbassert(C_out == 1'b1, "Test 20");
#0
  // 19 + 31 + Carry 1 -> 51
  A = 5'b10011;
  B = 5'b11111;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b10011, "Test 21");
  tbassert(C_out == 1'b1, "Test 21");
#0
  // 23 + 29 + Carry 0 -> 52
  A = 5'b10111;
  B = 5'b11101;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b10100, "Test 22");
  tbassert(C_out == 1'b1, "Test 22");
#0
  // 23 + 29 + Carry 1 -> 53
  // A = 5'b10111;
  // B = 5'b11101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b10101, "Test 23");
  tbassert(C_out == 1'b1, "Test 23");
#0

  // change between input bits that are set to ones with null effect on outputs

  // 3 + 5 + Carry 0 -> 8
  A = 5'b00011;
  B = 5'b00101;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b01000, "Test 24");
  tbassert(C_out == 1'b0, "Test 24");
#0
  // 2 + 5 + Carry 1 -> 8
  A = 5'b00010;
  // B = 5'b00101;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b01000, "Test 25");
  tbassert(C_out == 1'b0, "Test 25");
#0
  // 19 + 29 + Carry 0 -> 48
  A = 5'b10011;
  B = 5'b11101;
  C_in = 1'b0;
#6
  tbassert(Sum == 5'b10000, "Test 26");
  tbassert(C_out == 1'b1, "Test 26");
#0
  // 29 + 18 + Carry 1 -> 48
  A = 5'b11101;
  B = 5'b10010;
  C_in = 1'b1;
#6
  tbassert(Sum == 5'b10000, "Test 27");
  tbassert(C_out == 1'b1, "Test 27");
#10
  $finish;
end

endmodule
