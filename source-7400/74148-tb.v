// Test: 8-line to 3-line priority encoder

module test;

`TBASSERT_METHOD(tbassert)

localparam WIDTH_IN = 8;   // do not pass this to the module because it is not variable
localparam WIDTH_OUT = 3;  // do not pass this to the module because it is not variable

// DUT inputs
reg EI_bar;
reg [WIDTH_IN-1:0] A_bar;

// DUT outputs
wire EO_bar;
wire GS_bar;
wire [WIDTH_OUT-1:0] Y_bar;

// DUT
ttl_74148 #(.DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .EI_bar(EI_bar),
  .A_bar(A_bar),
  .EO_bar(EO_bar),
  .GS_bar(GS_bar),
  .Y_bar(Y_bar)
);

initial
begin
  $dumpfile("74148-tb.vcd");
  $dumpvars;

  // the following set of tests show the outputs enabled and tracking the priority inputs:
  // since EI_bar is enabled (low), the output EO_bar tracks whether the result is an
  // encoded priority input (high), or there is no priority input to encode (low);
  // and the output GS_bar tracks the opposite

  EI_bar = 1'b0;

  // all zeroes -> output is highest priority 7 (active low), and EO_bar and GS_bar are
  // normal, 1 and 0
  A_bar = 8'b00000000;
#6
  tbassert(EO_bar == 1'b1, "Test 1");
  tbassert(GS_bar == 1'b0, "Test 1");
  tbassert(Y_bar == ~3'b111, "Test 1");
#0
  // all ones -> output is lowest priority 0, and EO_bar and GS_bar are
  // opposite to normal (for cascading)
  A_bar = 8'b11111111;
#6
  tbassert(EO_bar == 1'b0, "Test 2");
  tbassert(GS_bar == 1'b1, "Test 2");
  tbassert(Y_bar == ~3'b000, "Test 2");
#0
  // bit 6 zero (*where bit numbering goes from 0 to 7) -> output is 6
  A_bar = 8'b10111111;
#6
  tbassert(EO_bar == 1'b1, "Test 3");
  tbassert(GS_bar == 1'b0, "Test 3");
  tbassert(Y_bar == ~3'b110, "Test 3");
#0
  // bit 6 zero with other zeroes present -> output is 6
  A_bar = 8'b10100101;
#6
  tbassert(EO_bar == 1'b1, "Test 4");
  tbassert(GS_bar == 1'b0, "Test 4");
  tbassert(Y_bar == ~3'b110, "Test 4");
#0
  // single bit transition to bit 4 zero -> output is 4
  A_bar = 8'b11100101;
#6
  tbassert(EO_bar == 1'b1, "Test 5");
  tbassert(GS_bar == 1'b0, "Test 5");
  tbassert(Y_bar == ~3'b100, "Test 5");
#0
  // multiple bit transition to bit 0 zero -> output is 0
  A_bar = 8'b11111110;
#6
  tbassert(EO_bar == 1'b1, "Test 6");
  tbassert(GS_bar == 1'b0, "Test 6");
  tbassert(Y_bar == ~3'b000, "Test 6");
#0
  // single bit transition to bit 6 zero -> output is 6
  A_bar = 8'b10111110;
#6
  tbassert(EO_bar == 1'b1, "Test 7");
  tbassert(GS_bar == 1'b0, "Test 7");
  tbassert(Y_bar == ~3'b110, "Test 7");
#0
  // all input bits transition from previous -> output is 7
  A_bar = 8'b01000001;
#6
  tbassert(EO_bar == 1'b1, "Test 8");
  tbassert(GS_bar == 1'b0, "Test 8");
  tbassert(Y_bar == ~3'b111, "Test 8");
#0
  // multiple bit transition with null change to outputs -> output is 7
  A_bar = 8'b01111111;
#6
  tbassert(EO_bar == 1'b1, "Test 9");
  tbassert(GS_bar == 1'b0, "Test 9");
  tbassert(Y_bar == ~3'b111, "Test 9");
#0
  // multiple bit transition with null change to outputs -> output is 5
  A_bar = 8'b11001100;
#6
  tbassert(Y_bar == ~3'b101, "Test 10");
#0
  A_bar = 8'b11011011;
#6
  tbassert(EO_bar == 1'b1, "Test 10");
  tbassert(GS_bar == 1'b0, "Test 10");
  tbassert(Y_bar == ~3'b101, "Test 10");
#0
  // multiple bit transition from all ones to bit 6 zero -> output is 6
  A_bar = 8'b11111111;
#6
  tbassert(Y_bar == ~3'b000, "Test 11");
#0
  A_bar = 8'b10010110;
#6
  tbassert(EO_bar == 1'b1, "Test 11");
  tbassert(GS_bar == 1'b0, "Test 11");
  tbassert(Y_bar == ~3'b110, "Test 11");
#0
  // multiple bit transition to all ones -> output is 0, and EO_bar and GS_bar are
  // opposite to normal
  A_bar = 8'b11111111;
#6
  tbassert(EO_bar == 1'b0, "Test 12");
  tbassert(GS_bar == 1'b1, "Test 12");
  tbassert(Y_bar == ~3'b000, "Test 12");
#0
  // single bit transition to bit 7 zero -> output is 7
  A_bar = 8'b01111111;
#6
  tbassert(EO_bar == 1'b1, "Test 13");
  tbassert(GS_bar == 1'b0, "Test 13");
  tbassert(Y_bar == ~3'b111, "Test 13");
#0

  // the following set of tests show the outputs disabled, and fixed at lowest priority 0:
  // since EI_bar is disabled (high), the output EO_bar is disabled (high)
  // and the output GS_bar is disabled (high)

  EI_bar = 1'b1;

  // all zeroes -> output is lowest priority 0, and EO_bar and GS_bar are 1s
  A_bar = 8'b00000000;
#6
  tbassert(EO_bar == 1'b1, "Test 14");
  tbassert(GS_bar == 1'b1, "Test 14");
  tbassert(Y_bar == ~3'b000, "Test 14");
#0
  // all ones -> output is 0
  A_bar = 8'b11111111;
#6
  tbassert(EO_bar == 1'b1, "Test 15");
  tbassert(GS_bar == 1'b1, "Test 15");
  tbassert(Y_bar == ~3'b000, "Test 15");
#0
  // bit 6 zero -> output is 0
  A_bar = 8'b10111111;
#6
  tbassert(EO_bar == 1'b1, "Test 16");
  tbassert(GS_bar == 1'b1, "Test 16");
  tbassert(Y_bar == ~3'b000, "Test 16");
#0
  // bit 6 zero with other zeroes present -> output is 0
  A_bar = 8'b10100101;
#6
  tbassert(EO_bar == 1'b1, "Test 17");
  tbassert(GS_bar == 1'b1, "Test 17");
  tbassert(Y_bar == ~3'b000, "Test 17");
#0
  // single bit transition to bit 4 zero -> output is 0
  A_bar = 8'b11100101;
#6
  tbassert(EO_bar == 1'b1, "Test 18");
  tbassert(GS_bar == 1'b1, "Test 18");
  tbassert(Y_bar == ~3'b000, "Test 18");
#0
  // multiple bit transition to bit 0 zero -> output is 0
  A_bar = 8'b11111110;
#6
  tbassert(EO_bar == 1'b1, "Test 19");
  tbassert(GS_bar == 1'b1, "Test 19");
  tbassert(Y_bar == ~3'b000, "Test 19");
#0
  // single bit transition to bit 7 zero -> output is 0
  A_bar = 8'b11111111;
#6
  tbassert(Y_bar == ~3'b000, "Test 20");
#0
  A_bar = 8'b01111111;
#6
  tbassert(EO_bar == 1'b1, "Test 20");
  tbassert(GS_bar == 1'b1, "Test 20");
  tbassert(Y_bar == ~3'b000, "Test 20");
#0

  // the following set of tests show transitions between outputs enabled and disabled,
  // where there is no priority input to encode

  // both inputs transition: to enabled, with all ones -> output is lowest priority 0,
  // and EO_bar and GS_bar are opposite to normal (for cascading)
  EI_bar = 1'b0;
  A_bar = 8'b11111111;
#6
  tbassert(EO_bar == 1'b0, "Test 21");
  tbassert(GS_bar == 1'b1, "Test 21");
  tbassert(Y_bar == ~3'b000, "Test 21");
#0
  // enable input transition: to disabled, with all ones -> output is lowest priority 0,
  // and EO_bar and GS_bar are 1s
  EI_bar = 1'b1;
  // A_bar = 8'b11111111;
#6
  tbassert(EO_bar == 1'b1, "Test 22");
  tbassert(GS_bar == 1'b1, "Test 22");
  tbassert(Y_bar == ~3'b000, "Test 22");
#0

  // the following set of tests check when the inputs are floating (high impedance)
  // since the device logic incorporates don't cares

  // 1. floating inputs behind any leading zero do not affect the output

  // 2. inputs that may affect the output must be tied to high or low logic voltage level
  //    (e.g. pull-up resistor); therefore floating input at leading bit position is not tested
  //    and should not be simulated

  EI_bar = 1'b0;

  // bit 7 zero -> output is 7, and EO_bar and GS_bar are normal, 1 and 0
  A_bar = 8'b0zz0zz00;
#6
  tbassert(EO_bar == 1'b1, "Test 23");
  tbassert(GS_bar == 1'b0, "Test 23");
  tbassert(Y_bar == ~3'b111, "Test 23");
#0
  // bit 6 zero -> output is 6
  A_bar = 8'b10z01zzz;
#6
  tbassert(EO_bar == 1'b1, "Test 24");
  tbassert(GS_bar == 1'b0, "Test 24");
  tbassert(Y_bar == ~3'b110, "Test 24");
#0
  // bit 1 zero -> output is 1
  A_bar = 8'b1111110z;
#6
  tbassert(EO_bar == 1'b1, "Test 25");
  tbassert(GS_bar == 1'b0, "Test 25");
  tbassert(Y_bar == ~3'b001, "Test 25");
#10
  $finish;
end

endmodule
