// Test: Octal bus transceiver with 3-state outputs

module test;

`TBASSERT_METHOD(tbassert)

localparam WIDTH = 8;

// DUT inputs
reg Dir;
reg OE_bar;
reg [WIDTH-1:0] A_in;
reg [WIDTH-1:0] B_in;

// DUT outputs
wire [WIDTH-1:0] A_out;
wire [WIDTH-1:0] B_out;

// DUT
ttl_74245 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Dir(Dir),
  .OE_bar(OE_bar),
  .A_in(A_in),
  .B_in(B_in),
  .A_out(A_out),
  .B_out(B_out)
);

initial
begin
  $dumpfile("74245-tb.vcd");
  $dumpvars;

  // the following set of tests are for: A to B direction (Dir=1)

#65
  // initial state
  tbassert(A_out === {WIDTH{1'bx}}, "Test 1");
  tbassert(B_out === {WIDTH{1'bx}}, "Test 1");
#0
  // enable A to B direction
  Dir = 1'b1;
  OE_bar = 1'b0;
  A_in = 8'hFF;
  B_in = 8'h00;
#7
  // A_in passes through to B_out, A_out is high-Z
  tbassert(B_out == 8'hFF, "Test 2");
  tbassert(A_out === {WIDTH{1'bz}}, "Test 2");
#50
  // change A_in -> B_out follows
  A_in = 8'h00;
#7
  tbassert(B_out == 8'h00, "Test 3");
  tbassert(A_out === {WIDTH{1'bz}}, "Test 3");
#50
  // pattern on A_in
  A_in = 8'b10100101;
#7
  tbassert(B_out == 8'b10100101, "Test 4");
  tbassert(A_out === {WIDTH{1'bz}}, "Test 4");
#50
  // B_in has no effect on outputs in A to B direction
  B_in = 8'hFF;
#7
  tbassert(B_out == 8'b10100101, "Test 5");
  tbassert(A_out === {WIDTH{1'bz}}, "Test 5");
#50

  // the following set of tests are for: B to A direction (Dir=0)

  // switch to B to A direction
  Dir = 1'b0;
  B_in = 8'hFF;
  A_in = 8'h00;
#7
  // B_in passes through to A_out, B_out is high-Z
  tbassert(A_out == 8'hFF, "Test 6");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 6");
#50
  // change B_in -> A_out follows
  B_in = 8'h00;
#7
  tbassert(A_out == 8'h00, "Test 7");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 7");
#50
  // pattern on B_in
  B_in = 8'b01011010;
#7
  tbassert(A_out == 8'b01011010, "Test 8");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 8");
#50
  // A_in has no effect on outputs in B to A direction
  A_in = 8'hFF;
#7
  tbassert(A_out == 8'b01011010, "Test 9");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 9");
#50

  // the following set of tests are for: output enable (3-state)

  // disable outputs
  OE_bar = 1'b1;
#7
  // both outputs are high-Z regardless of Dir
  tbassert(A_out === {WIDTH{1'bz}}, "Test 10");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 10");
#50
  // Dir=1 with OE disabled -> still high-Z
  Dir = 1'b1;
  A_in = 8'hFF;
#7
  tbassert(A_out === {WIDTH{1'bz}}, "Test 11");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 11");
#50
  // Dir=0 with OE disabled -> still high-Z
  Dir = 1'b0;
  B_in = 8'hFF;
#7
  tbassert(A_out === {WIDTH{1'bz}}, "Test 12");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 12");
#50
  // re-enable outputs -> data passes through immediately
  Dir = 1'b1;
  A_in = 8'b11001100;
  OE_bar = 1'b0;
#7
  tbassert(B_out == 8'b11001100, "Test 13");
  tbassert(A_out === {WIDTH{1'bz}}, "Test 13");
#50

  // the following set of tests are for: switching direction while enabled

  // A to B with data
  Dir = 1'b1;
  A_in = 8'b10101010;
  B_in = 8'b01010101;
#7
  tbassert(B_out == 8'b10101010, "Test 14");
  tbassert(A_out === {WIDTH{1'bz}}, "Test 14");
#50
  // switch to B to A -> outputs swap
  Dir = 1'b0;
#7
  tbassert(A_out == 8'b01010101, "Test 15");
  tbassert(B_out === {WIDTH{1'bz}}, "Test 15");
#50
  // switch back to A to B
  Dir = 1'b1;
#7
  tbassert(B_out == 8'b10101010, "Test 16");
  tbassert(A_out === {WIDTH{1'bz}}, "Test 16");
#50

  // the following set of tests are for: all bits individually

  // verify each bit passes through independently
  Dir = 1'b1;
  A_in = 8'b00000001;
#7
  tbassert(B_out == 8'b00000001, "Test 17");
#0
  A_in = 8'b00000010;
#7
  tbassert(B_out == 8'b00000010, "Test 18");
#0
  A_in = 8'b00000100;
#7
  tbassert(B_out == 8'b00000100, "Test 19");
#0
  A_in = 8'b00001000;
#7
  tbassert(B_out == 8'b00001000, "Test 20");
#0
  A_in = 8'b00010000;
#7
  tbassert(B_out == 8'b00010000, "Test 21");
#0
  A_in = 8'b00100000;
#7
  tbassert(B_out == 8'b00100000, "Test 22");
#0
  A_in = 8'b01000000;
#7
  tbassert(B_out == 8'b01000000, "Test 23");
#0
  A_in = 8'b10000000;
#7
  tbassert(B_out == 8'b10000000, "Test 24");
#50

  // the following set of tests are for: timing

  // timing: disable then re-enable, check propagation delay
  OE_bar = 1'b1;
#10
  A_in = 8'hFF;
#10
  // re-enable, not enough time for output to rise
  OE_bar = 1'b0;
#2
  tbassert(B_out === {WIDTH{1'bz}}, "Test 25");
#5
  // output has risen
  tbassert(B_out == 8'hFF, "Test 25");
#10
  $finish;
end

endmodule
