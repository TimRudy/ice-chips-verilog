// Test: 10-line to 4-line priority encoder

module test;

`TBASSERT_METHOD(tbassert)

localparam WIDTH_IN = 9;   // do not pass this to the module because it is not variable
localparam WIDTH_OUT = 4;  // do not pass this to the module because it is not variable

// DUT inputs
reg [WIDTH_IN-1:0] A_bar;

// DUT outputs
wire [WIDTH_OUT-1:0] Y_bar;

// DUT
ttl_74147 #(.DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .A_bar(A_bar),
  .Y_bar(Y_bar)
);

initial
begin
  $dumpfile("74147-tb.vcd");
  $dumpvars;

  // all zeroes -> output is highest priority 9 (active low)
  A_bar = 9'b000000000;
#6
  tbassert(Y_bar == ~4'b1001, "Test 1");
#0
  // all ones -> output is lowest priority 0
  A_bar = 9'b111111111;
#6
  tbassert(Y_bar == ~4'b0000, "Test 2");
#0
  // bit 6 zero (*where bit numbering goes from 1 to 9) -> output is 6
  A_bar = 9'b111011111;
#6
  tbassert(Y_bar == ~4'b0110, "Test 3");
#0
  // bit 6 zero with other zeroes present -> output is 6
  A_bar = 9'b111010101;
#6
  tbassert(Y_bar == ~4'b0110, "Test 4");
#0
  // single bit transition to bit 4 zero -> output is 4
  A_bar = 9'b111110101;
#6
  tbassert(Y_bar == ~4'b0100, "Test 5");
#0
  // multiple bit transition to bit 1 zero -> output is 1
  A_bar = 9'b111111110;
#6
  tbassert(Y_bar == ~4'b0001, "Test 6");
#0
  // single bit transition to bit 8 zero -> output is 8
  A_bar = 9'b101111110;
#6
  tbassert(Y_bar == ~4'b1000, "Test 7");
#0
  // all input bits transition from previous -> output is 9
  A_bar = 9'b010000001;
#6
  tbassert(Y_bar == ~4'b1001, "Test 8");
#0
  // multiple bit transition with null change to outputs -> output is 9
  A_bar = 9'b011111111;
#6
  tbassert(Y_bar == ~4'b1001, "Test 9");
#0
  // multiple bit transition with null change to outputs -> output is 7
  A_bar = 9'b110101100;
#6
  tbassert(Y_bar == ~4'b0111, "Test 10");
#0
  A_bar = 9'b110000111;
#6
  tbassert(Y_bar == ~4'b0111, "Test 10");
#0
  // multiple bit transition from all ones to bit 6 zero -> output is 6
  A_bar = 9'b111111111;
#6
  tbassert(Y_bar == ~4'b0000, "Test 11");
#0
  A_bar = 9'b111000110;
#6
  tbassert(Y_bar == ~4'b0110, "Test 11");
#0
  // multiple bit transition to all ones -> output is 0
  A_bar = 9'b111111111;
#6
  tbassert(Y_bar == ~4'b0000, "Test 12");
#0
  // single bit transition to bit 9 zero -> output is 9
  A_bar = 9'b011111111;
#6
  tbassert(Y_bar == ~4'b1001, "Test 13");
#0

  // the following set of tests check when the inputs are floating (high impedance)
  // since the device logic incorporates don't cares

  // 1. floating inputs behind any leading zero do not affect the output

  // 2. inputs that may affect the output must be tied to high or low logic voltage level
  //    (e.g. pull-up resistor); therefore floating input at leading bit position is not tested
  //    and should not be simulated

  // bit 9 zero -> output is 9
  A_bar = 9'b0zz0zz000;
#6
  tbassert(Y_bar == ~4'b1001, "Test 14");
#0
  // bit 6 zero -> output is 6
  A_bar = 9'b1110z01zz;
#6
  tbassert(Y_bar == ~4'b0110, "Test 15");
#0
  // bit 2 zero -> output is 2
  A_bar = 9'b11111110z;
#6
  tbassert(Y_bar == ~4'b0010, "Test 16");
#10
  $finish;
end

endmodule
