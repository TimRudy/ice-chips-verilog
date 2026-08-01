// Test: Octal D-type edge-triggered flip-flop with 3-state outputs

module test;

`TBASSERT_METHOD(tbassert)

localparam WIDTH = 8;

// DUT inputs
reg Clk;
reg OE_bar;
reg [WIDTH-1:0] D;

// DUT outputs
wire [WIDTH-1:0] Q;

// DUT
ttl_74574 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Clk(Clk),
  .OE_bar(OE_bar),
  .D(D),
  .Q(Q)
);

initial
begin
  $dumpfile("74574-tb.vcd");
  $dumpvars;

  // the following set of tests are for: clocked latch

#65
  // initial state
  tbassert(Q === {WIDTH{1'bx}}, "Test 1");
#0
  // initial control signals
  Clk = 1'b0;
  OE_bar = 1'b0;
  D = 8'h00;
#7
  tbassert(Q === {WIDTH{1'bx}}, "Test 1");
#0
  // latch all ones on rising clock edge, not enough time for output to rise
  D = 8'hFF;
#25
  Clk = 1'b1;
#2
  tbassert(Q === {WIDTH{1'bx}}, "Test 2");
#5
  // latch all ones -> output 1s
  tbassert(Q == 8'hFF, "Test 2");
#50
  // return clock low
  Clk = 1'b0;
#25
  // latch all zeroes, not enough time for output to fall
  D = 8'h00;
#15
  Clk = 1'b1;
#2
  tbassert(Q == 8'hFF, "Test 3");
#4
  // latch all zeroes -> output 0s
  tbassert(Q == 8'h00, "Test 3");
#50
  // latch pattern
  Clk = 1'b0;
  D = 8'b10100101;
#25
  Clk = 1'b1;
#6
  tbassert(Q == 8'b10100101, "Test 4");
#50
  // latch different pattern
  Clk = 1'b0;
  D = 8'b01011010;
#25
  Clk = 1'b1;
#6
  tbassert(Q == 8'b01011010, "Test 5");
#50

  // the following set of tests are for: data hold after clock edge

  // data changes after clock edge have no effect on output
  Clk = 1'b0;
  D = 8'b11001100;
#25
  Clk = 1'b1;
#6
  tbassert(Q == 8'b11001100, "Test 6");
#10
  // change data while clock is high -> no effect
  D = 8'hFF;
#50
  tbassert(Q == 8'b11001100, "Test 7");
#0
  // change data while clock is low -> no effect until next rising edge
  Clk = 1'b0;
  D = 8'b00110011;
#50
  tbassert(Q == 8'b11001100, "Test 8");
#0
  // next rising edge latches the new data
  Clk = 1'b1;
#6
  tbassert(Q == 8'b00110011, "Test 9");
#50

  // the following set of tests are for: 3-state output

  // disable output
  OE_bar = 1'b1;
#7
  tbassert(Q === {WIDTH{1'bz}}, "Test 10");
#50
  // clock edge while output disabled -> data is latched internally
  Clk = 1'b0;
  D = 8'b11110000;
#25
  Clk = 1'b1;
#6
  // output still high-Z
  tbassert(Q === {WIDTH{1'bz}}, "Test 11");
#50
  // re-enable output -> latched data appears
  OE_bar = 1'b0;
#7
  tbassert(Q == 8'b11110000, "Test 12");
#50
  // disable and re-enable without clock edge -> same data
  OE_bar = 1'b1;
#50
  tbassert(Q === {WIDTH{1'bz}}, "Test 13");
#0
  OE_bar = 1'b0;
#7
  tbassert(Q == 8'b11110000, "Test 14");
#50

  // the following set of tests are for: multiple clock cycles with output disabled

  // latch several values while output is disabled
  OE_bar = 1'b1;
  Clk = 1'b0;
  D = 8'hAA;
#25
  Clk = 1'b1;
#50
  Clk = 1'b0;
  D = 8'h55;
#25
  Clk = 1'b1;
#50
  Clk = 1'b0;
  D = 8'hC3;
#25
  Clk = 1'b1;
#50
  // output still high-Z
  tbassert(Q === {WIDTH{1'bz}}, "Test 15");
#0
  // re-enable -> only the last latched value appears
  OE_bar = 1'b0;
#7
  tbassert(Q == 8'hC3, "Test 16");
#50

  // the following set of tests are for: each bit individually

  Clk = 1'b0;
  D = 8'b00000001;
#25
  Clk = 1'b1;
#6
  tbassert(Q == 8'b00000001, "Test 17");
#10
  Clk = 1'b0;
  D = 8'b10000000;
#25
  Clk = 1'b1;
#6
  tbassert(Q == 8'b10000000, "Test 18");
#50

  // the following set of tests are for: timing

  // timing: clear then latch, verify rise delay
  Clk = 1'b0;
  D = 8'h00;
#25
  Clk = 1'b1;
#6
  tbassert(Q == 8'h00, "Test 19");
#50
  Clk = 1'b0;
  D = 8'hFF;
#25
  Clk = 1'b1;
#2
  // not enough time for rise (5)
  tbassert(Q == 8'h00, "Test 20");
#4
  // enough time for rise
  tbassert(Q == 8'hFF, "Test 20");
#50
  // timing: verify fall delay
  Clk = 1'b0;
  D = 8'h00;
#25
  Clk = 1'b1;
#2
  // not enough time for fall (3)
  tbassert(Q == 8'hFF, "Test 21");
#4
  // enough time for fall
  tbassert(Q == 8'h00, "Test 21");
#10
  $finish;
end

endmodule
