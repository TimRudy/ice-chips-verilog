// Test: Dual 2-line to 4-line decoder/demultiplexer (inverted outputs)

module test;

`TBASSERT_METHOD(tbassert)

localparam BLOCKS = 3;
localparam WIDTH_OUT = 2;
localparam WIDTH_IN = $clog2(WIDTH_OUT);  // do not pass this to the module because
                                          // it is dependent value

// DUT inputs
reg [BLOCKS-1:0] Enable_bar;
reg [BLOCKS*WIDTH_IN-1:0] A;  // WIDTH_IN is one bit

// DUT outputs
wire [BLOCKS*WIDTH_OUT-1:0] Y;

// DUT
ttl_74139 #(.BLOCKS(BLOCKS), .WIDTH_OUT(WIDTH_OUT), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable_bar(Enable_bar),
  .A_2D(A),
  .Y_2D(Y)
);

initial
begin
  reg [WIDTH_IN-1:0] AInputs;
  reg [WIDTH_IN-1:0] BInputs;
  reg [WIDTH_IN-1:0] CInputs;
  reg [WIDTH_OUT-1:0] XOutputs;
  reg [WIDTH_OUT-1:0] YOutputs;
  reg [WIDTH_OUT-1:0] ZOutputs;

  $dumpfile("74139-tb.vcd");
  $dumpvars;

  // select A: enabled -> first output is 0
  Enable_bar = {BLOCKS{1'b0}};
  AInputs = 1'b0;
  BInputs = 1'b0;
  CInputs = 1'b0;
  A = {CInputs, BInputs, AInputs};
#6
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b10, "Test 1");
  tbassert(YOutputs == 2'b10, "Test 1");
  tbassert(ZOutputs == 2'b10, "Test 1");
#0
  // select A: disabled in first block -> output is 11 instead of 10
  Enable_bar[0] = 1'b1;
#6
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b11, "Test 2");
  tbassert(YOutputs == 2'b10, "Test 2");
  tbassert(ZOutputs == 2'b10, "Test 2");
#0
  // select A: disabled in second block, enabled in first block
  Enable_bar[0] = 1'b0;
  Enable_bar[1] = 1'b1;
#6
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b10, "Test 3");
  tbassert(YOutputs == 2'b11, "Test 3");
  tbassert(ZOutputs == 2'b10, "Test 3");
#0
  // select B: disabled -> output 1s
  Enable_bar = {BLOCKS{1'b1}};
  AInputs = 1'b1;
  BInputs = 1'b1;
  CInputs = 1'b1;
  A = {CInputs, BInputs, AInputs};
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b11, "Test 4");
  tbassert(YOutputs == 2'b11, "Test 4");
  tbassert(ZOutputs == 2'b11, "Test 4");
#0
  // select B: enabled in second and third blocks -> second output is 0 where enabled
  Enable_bar[1] = 1'b0;
  Enable_bar[2] = 1'b0;
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b11, "Test 5");
  tbassert(YOutputs == 2'b01, "Test 5");
  tbassert(ZOutputs == 2'b01, "Test 5");
#0
  // select A: enabled in second and third blocks -> first output is 0 where enabled
  A = {BLOCKS{1'b0}};
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b11, "Test 6");
  tbassert(YOutputs == 2'b10, "Test 6");
  tbassert(ZOutputs == 2'b10, "Test 6");
#0
  // select A: enabled in first and third blocks
  Enable_bar[0] = 1'b0;
  Enable_bar[1] = 1'b1;
  Enable_bar[2] = 1'b0;
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b10, "Test 7");
  tbassert(YOutputs == 2'b11, "Test 7");
  tbassert(ZOutputs == 2'b10, "Test 7");
#0
  // while enabled: change to select B from select A -> second output is 0
  Enable_bar[1] = 1'b0;
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b10, "Test 8");
  tbassert(YOutputs == 2'b10, "Test 8");
  tbassert(ZOutputs == 2'b10, "Test 8");
#0
  A = {BLOCKS{1'b1}};
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b01, "Test 8");
  tbassert(YOutputs == 2'b01, "Test 8");
  tbassert(ZOutputs == 2'b01, "Test 8");
#0
  // while disabled: change to select A from select B with null change to output 1s
  Enable_bar = {BLOCKS{1'b1}};
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b11, "Test 9");
  tbassert(YOutputs == 2'b11, "Test 9");
  tbassert(ZOutputs == 2'b11, "Test 9");
#0
  A = {BLOCKS{1'b0}};
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b11, "Test 9");
  tbassert(YOutputs == 2'b11, "Test 9");
  tbassert(ZOutputs == 2'b11, "Test 9");
#0
  // while enabled: mixed selects -> outputs are both 01, 10
  Enable_bar = {BLOCKS{1'b0}};
  AInputs = 1'b1;
  BInputs = 1'b0;
  CInputs = 1'b0;
  A = {CInputs, BInputs, AInputs};
#10
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b01, "Test 10");
  tbassert(YOutputs == 2'b10, "Test 10");
  tbassert(ZOutputs == 2'b10, "Test 10");
#0
  // while enabled: change to select B from select A in third block only
  CInputs = 1'b1;
  A = {CInputs, BInputs, AInputs};
#6
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b01, "Test 11");
  tbassert(YOutputs == 2'b10, "Test 11");
  tbassert(ZOutputs == 2'b01, "Test 11");
#0
  // same selects but disabled in first block -> output is 11 instead of 01
  Enable_bar[0] = 1'b1;
#6
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b11, "Test 12");
  tbassert(YOutputs == 2'b10, "Test 12");
  tbassert(ZOutputs == 2'b01, "Test 12");
#0
  // same selects but disabled in second block, enabled in first block -> output is 11
  // instead of 10
  Enable_bar[0] = 1'b0;
  Enable_bar[1] = 1'b1;
#6
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b01, "Test 13");
  tbassert(YOutputs == 2'b11, "Test 13");
  tbassert(ZOutputs == 2'b01, "Test 13");
#0
  // all input selects transition from previous
  AInputs = 1'b0;
  BInputs = 1'b1;
  CInputs = 1'b0;
  A = {CInputs, BInputs, AInputs};
#6
  {ZOutputs, YOutputs, XOutputs} = Y;
  tbassert(XOutputs == 2'b10, "Test 14");
  tbassert(YOutputs == 2'b11, "Test 14");
  tbassert(ZOutputs == 2'b10, "Test 14");
#10
  $finish;
end

endmodule
