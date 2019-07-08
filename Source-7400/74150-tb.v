// Test: 16-input multiplexer

module test;

`TBASSERT_METHOD(tbassert)

localparam WIDTH_IN = 5;
localparam WIDTH_SELECT = $clog2(WIDTH_IN);  // do not pass this to the module because
                                             // it is dependent value

// DUT inputs
reg Enable_bar;
reg [WIDTH_SELECT-1:0] Select;  // Select is three bits but only valid in range 3'b000
                                // to 3'b100
reg [WIDTH_IN-1:0] D;

// DUT outputs
wire Y_bar;

// DUT
ttl_74150 #(.WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable_bar(Enable_bar),
  .Select(Select),
  .D(D),
  .Y_bar(Y_bar)
);

initial
begin
  $dumpfile("74150-tb.vcd");
  $dumpvars;

  // select 000: enabled
  Enable_bar = 1'b0;
  Select = 3'b000;
  D = 5'b01011;
#6
  tbassert(Y_bar == 1'b0, "Test 1");
#0
  // select 000: disabled -> output 0
  Enable_bar = 1'b1;
#6
  tbassert(Y_bar == 1'b1, "Test 2");
#0
  // select 011: disabled
  Select = 3'b011;
#10
  tbassert(Y_bar == 1'b1, "Test 3");
#0
  // select 011: enabled
  Enable_bar = 1'b0;
#10
  tbassert(Y_bar == 1'b0, "Test 4");
#0
  // select 100: enabled
  Select = 3'b100;
#10
  tbassert(Y_bar == 1'b1, "Test 5");
#0
  // select 100: disabled
  Enable_bar = 1'b1;
#10
  tbassert(Y_bar == 1'b1, "Test 6");
#0
  // select 001: disabled
  Select = 3'b001;
#10
  tbassert(Y_bar == 1'b1, "Test 7");
#0
  // select 001: enabled
  Enable_bar = 1'b0;
#10
  tbassert(Y_bar == 1'b0, "Test 8");
#0
  // while enabled: change to select 000 from select 001
  Select = 3'b000;
#10
  tbassert(Y_bar == 1'b0, "Test 9");
#0
  // while enabled: change to select 100 from select 001
  Select = 3'b001;
#10
  tbassert(Y_bar == 1'b0, "Test 10");
  Select = 3'b100;
#10
  tbassert(Y_bar == 1'b1, "Test 10");
#0
  // while select 100 enabled: change to different inputs
  D = 5'b11110;
#10
  tbassert(Y_bar == 1'b0, "Test 11");
#0
  // while enabled: change to select 000 from select 100
  Select = 3'b000;
#10
  tbassert(Y_bar == 1'b1, "Test 12");
#0
  // select 000: disabled
  Enable_bar = 1'b1;
#6
  tbassert(Y_bar == 1'b1, "Test 13");
#0
  // select 010: disabled
  Select = 3'b010;
#10
  tbassert(Y_bar == 1'b1, "Test 14");
#0
  // select 010: enabled and change to different inputs with null effect on output 0
  Enable_bar = 1'b0;
  D = 5'b00000;
#10
  tbassert(Y_bar == 1'b1, "Test 15");
#0
  // select 100: enabled with null change to output 0
  Select = 3'b100;
#10
  tbassert(Y_bar == 1'b1, "Test 16");
#0
  // select 100: output bit transitions from previous, direct from inputs
  D = 5'b11111;
#6
  tbassert(Y_bar == 1'b0, "Test 17");
#0
  // output bit transitions from previous, direct from select 001
  D = 5'b00010;
#10
  tbassert(Y_bar == 1'b1, "Test 18");
  Select = 3'b001;
#6
  tbassert(Y_bar == 1'b0, "Test 18");
#0
  // select 001: output bit transitions from previous, on disable
  Enable_bar = 1'b1;
#10
  tbassert(Y_bar == 1'b1, "Test 19");
#0
  // select 001: enabled and change to different inputs with null effect on output 1
  Enable_bar = 1'b0;
#10
  tbassert(Y_bar == 1'b0, "Test 20");
  D = 5'b11110;
#10
  tbassert(Y_bar == 1'b0, "Test 20");
#0
  // change to select 010 from select 001 and change to different inputs with null effect on
  // output 1
  Select = 3'b010;
  D = 5'b10101;
#10
  tbassert(Y_bar == 1'b0, "Test 21");
#0
  // change to select 011 from select 010 and change to different inputs with null effect on
  // output 1
  Select = 3'b011;
  D = 5'b01010;
#10
  tbassert(Y_bar == 1'b0, "Test 22");
#0

  // the following set of tests show the implementer is responsible for valid range of input
  // when the WIDTH_IN parameter is set for this device

  // select invalid (101), with input ones -> output is not driven
  Enable_bar = 1'b0;
  Select = 3'b101;
  D = 5'b11111;
#10
  tbassert(Y_bar === 1'bx, "Test 23");
#0
  // select invalid (111), with input zeroes -> output is not driven
  Enable_bar = 1'b0;
  Select = 3'b111;
  D = 5'b00000;
#10
  tbassert(Y_bar === 1'bx, "Test 24");
#10
  $finish;
end

endmodule
