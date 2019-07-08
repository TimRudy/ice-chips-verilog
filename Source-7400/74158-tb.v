// Test: Quad 2-input multiplexer (inverted outputs)

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 3;
localparam WIDTH_IN = 2;
localparam WIDTH_SELECT = $clog2(WIDTH_IN);  // do not pass this to the module because
                                             // it is dependent value

// DUT inputs
reg Enable_bar;
reg [WIDTH_SELECT-1:0] Select;  // Select is one bit
reg [BLOCKS*WIDTH_IN-1:0] A;

// DUT outputs
wire [BLOCKS-1:0] Y_bar;

// DUT
ttl_74158 #(.BLOCKS(BLOCKS), .WIDTH_IN(WIDTH_IN), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable_bar(Enable_bar),
  .Select(Select),
  .A_2D(A),
  .Y_bar(Y_bar)
);

localparam SELECT_A = 1'b0;
localparam SELECT_B = 1'b1;

initial
begin
  reg [BLOCKS-1:0] AInputs;
  reg [BLOCKS-1:0] BInputs;

  $dumpfile("74158-tb.vcd");
  $dumpvars;

  // select A: enabled
  Enable_bar = 1'b0;
  Select = SELECT_A;
  AInputs = 3'b011;
  BInputs = 3'b111;
  A = {BInputs, AInputs};
#6
  tbassert(Y_bar == 3'b100, "Test 1");
#0
  // select A: disabled -> output 1s
  Enable_bar = 1'b1;
#6
  tbassert(Y_bar == 3'b111, "Test 2");
#0
  // select B: disabled
  Select = SELECT_B;
#10
  tbassert(Y_bar == 3'b111, "Test 3");
#0
  // select B: enabled
  Enable_bar = 1'b0;
#10
  tbassert(Y_bar == 3'b000, "Test 4");
#0
  // while enabled: change to select A from select B
  Select = SELECT_A;
#10
  tbassert(Y_bar == 3'b100, "Test 5");
#0
  // while select A enabled: change to different inputs
  AInputs = 3'b111;
  BInputs = 3'b001;
  A = {BInputs, AInputs};
#10
  tbassert(Y_bar == 3'b000, "Test 6");
#0
  // while enabled: change to select B from select A
  Select = SELECT_B;
#10
  tbassert(Y_bar == 3'b110, "Test 7");
#0
  // select B: disabled
  Enable_bar = 1'b1;
#6
  tbassert(Y_bar == 3'b111, "Test 8");
#0
  // select A: disabled
  Select = SELECT_A;
#10
  tbassert(Y_bar == 3'b111, "Test 9");
#0
  // select A: enabled and change to different inputs with null effect on output 1s
  Enable_bar = 1'b0;
  AInputs = 3'b000;
  A = {BInputs, AInputs};
#10
  tbassert(Y_bar == 3'b111, "Test 10");
#0
  // select B: enabled with null change to output 1s
  Select = SELECT_B;
  AInputs = 3'b010;
  BInputs = 3'b000;
  A = {BInputs, AInputs};
#10
  tbassert(Y_bar == 3'b111, "Test 11");
#0
  // select B: all output bits transition from previous, direct from inputs
  BInputs = 3'b111;
  A = {BInputs, AInputs};
#6
  tbassert(Y_bar == 3'b000, "Test 12");
#0
  // all output bits transition from previous, direct from select A
  AInputs = 3'b011;
  BInputs = 3'b110;
  A = {BInputs, AInputs};
#6
  tbassert(Y_bar == 3'b001, "Test 13");
#0
  Select = SELECT_A;
#6
  tbassert(Y_bar == 3'b100, "Test 13");
#0
  // select A: all output bits transition from previous, on disable
  AInputs = 3'b111;
  A = {BInputs, AInputs};
#6
  tbassert(Y_bar == 3'b000, "Test 14");
#0
  Enable_bar = 1'b1;
#10
  tbassert(Y_bar == 3'b111, "Test 14");
#0
  // while enabled: change to select B from select A and change to different inputs
  // with null effect on output 0s
  Enable_bar = 1'b0;
#6
  tbassert(Y_bar == 3'b000, "Test 15");
#10
  Select = SELECT_B;
  AInputs = {BLOCKS{1'b0}};
  BInputs = {BLOCKS{1'b1}};
  A = {BInputs, AInputs};
#10
  tbassert(Y_bar == 3'b000, "Test 15");
#0
  // timing: while enabled, clear/set inputs, then must wait for outputs to transition
  Enable_bar = 1'b0;
  Select = 1'bx;
  AInputs = {BLOCKS{1'bx}};
  BInputs = {BLOCKS{1'bx}};
  A = {BInputs, AInputs};
#10
  Select = SELECT_A;
  AInputs = 3'b011;
  BInputs = 3'b101;
  A = {BInputs, AInputs};
#2
  tbassert(Y_bar === 3'bxxx, "Test 16");
#3
  tbassert(Y_bar == 3'b100, "Test 16");
#0
  // timing: while enabled, clear/set inputs, then must wait for outputs to transition,
  // off the select input only
  Enable_bar = 1'b0;
  Select = 1'bx;
  AInputs = {BLOCKS{1'bx}};
  BInputs = {BLOCKS{1'bx}};
  A = {BInputs, AInputs};
#10
  AInputs = 3'b011;
  BInputs = 3'b101;
  A = {BInputs, AInputs};
#6
  Select = SELECT_A;
#2
  tbassert(Y_bar === 3'bxxx, "Test 17");
#3
  tbassert(Y_bar == 3'b100, "Test 17");
#0
  // timing: same, other select
  Enable_bar = 1'b0;
  Select = 1'bx;
  AInputs = {BLOCKS{1'bx}};
  BInputs = {BLOCKS{1'bx}};
  A = {BInputs, AInputs};
#10
  AInputs = 3'b110;
  BInputs = 3'b111;
  A = {BInputs, AInputs};
#6
  Select = SELECT_B;
#2
  tbassert(Y_bar === 3'bxxx, "Test 18");
#3
  tbassert(Y_bar == 3'b000, "Test 18");
#0
  // timing: while enabled, clear/set inputs, then must wait for outputs to transition,
  // off the data inputs only
  Select = 1'bx;
  AInputs = {BLOCKS{1'bx}};
  BInputs = {BLOCKS{1'bx}};
  A = {BInputs, AInputs};
#10
  Select = SELECT_B;
#6
  AInputs = 3'b011;
  BInputs = 3'b101;
  A = {BInputs, AInputs};
#2
  tbassert(Y_bar === 3'bxxx, "Test 19");
#3
  tbassert(Y_bar == 3'b010, "Test 19");
#0
  // timing: same, other select (with only the selected data input being set)
  Select = 1'bx;
  AInputs = {BLOCKS{1'bx}};
  BInputs = {BLOCKS{1'bx}};
  A = {BInputs, AInputs};
#10
  Select = SELECT_A;
#6
  AInputs = 3'b011;
  A = {BInputs, AInputs};
#2
  tbassert(Y_bar === 3'bxxx, "Test 20");
#3
  tbassert(Y_bar == 3'b100, "Test 20");
#10
  $finish;
end

endmodule
