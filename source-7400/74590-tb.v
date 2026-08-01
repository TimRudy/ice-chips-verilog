// Test: 8-bit binary counter with output register and 3-state outputs

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)

localparam WIDTH = 8;

// DUT inputs
reg CCLK;
reg CCLR_bar;
reg RCLK;
reg OE_bar;

// DUT outputs
wire RCO;
wire [WIDTH-1:0] Q;

// DUT
ttl_74590 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .CCLK(CCLK),
  .CCLR_bar(CCLR_bar),
  .RCLK(RCLK),
  .OE_bar(OE_bar),
  .RCO(RCO),
  .Q(Q)
);

task pulse_cclk;
  CCLK = 1'b0;
  #25;
  CCLK = 1'b1;
  #25;
endtask

task pulse_rclk;
  RCLK = 1'b0;
  #25;
  RCLK = 1'b1;
  #25;
endtask

initial
begin
  $dumpfile("74590-tb.vcd");
  $dumpvars;

  // the following set of tests are for: asynchronous counter clear

#65
  // initial state
  tbassert(Q === {WIDTH{1'bx}}, "Test 1");
  tbassert(RCO === 1'bx, "Test 1");
#0
  // initial control signals
  CCLK = 1'b0;
  RCLK = 1'b0;
  OE_bar = 1'b0;
  CCLR_bar = 1'b1;
#25
  tbassert(Q === {WIDTH{1'bx}}, "Test 1");
#0
  // asynchronous clear of counter
  CCLR_bar = 1'b0;
#7
  // counter is cleared but output register has not been clocked
  tbassert(Q === {WIDTH{1'bx}}, "Test 2");
  tbassert(RCO == 1'b0, "Test 2");
#50
  CCLR_bar = 1'b1;
#25
  // latch cleared counter into output register
  pulse_rclk();
#6
  tbassert(Q == 8'h00, "Test 3");
  tbassert(RCO == 1'b0, "Test 3");
#50

  // the following set of tests are for: counting and register latch

  // count up once
  pulse_cclk();
#0
  // output register still shows 0 (not yet latched)
  tbassert(Q == 8'h00, "Test 4");
#0
  // latch counter into output register
  pulse_rclk();
#6
  tbassert(Q == 8'h01, "Test 5");
#50
  // count up twice more without latching
  pulse_cclk();
  pulse_cclk();
#0
  // output register still shows 1
  tbassert(Q == 8'h01, "Test 6");
#0
  // latch -> output register shows 3
  pulse_rclk();
#6
  tbassert(Q == 8'h03, "Test 7");
#50
  // count and latch several times
  pulse_cclk();
  pulse_rclk();
#6
  tbassert(Q == 8'h04, "Test 8");
#25
  pulse_cclk();
  pulse_rclk();
#6
  tbassert(Q == 8'h05, "Test 9");
#50

  // the following set of tests are for: 3-state output

  // disable output
  OE_bar = 1'b1;
#7
  tbassert(Q === {WIDTH{1'bz}}, "Test 10");
#50
  // counter and register continue to work while output disabled
  pulse_cclk();
  pulse_rclk();
#6
  tbassert(Q === {WIDTH{1'bz}}, "Test 11");
#25
  // re-enable output -> latched value appears
  OE_bar = 1'b0;
#7
  tbassert(Q == 8'h06, "Test 12");
#50

  // the following set of tests are for: RCO and terminal count

  // clear counter and count up to 254
  CCLR_bar = 1'b0;
#7
  CCLR_bar = 1'b1;
#25
  begin: count_to_254
    integer i;

    for (i = 0; i < 254; i = i + 1)
    begin
      pulse_cclk();
    end
  end
#0
  // counter is at 254, RCO should be low
  tbassert(RCO == 1'b0, "Test 13");
#0
  // count to 255 -> RCO goes high
  pulse_cclk();
#7
  tbassert(RCO == 1'b1, "Test 14");
#0
  // latch terminal count into output register
  pulse_rclk();
#6
  tbassert(Q == 8'hFF, "Test 15");
#50
  // count wraps to 0 -> RCO goes low
  pulse_cclk();
#7
  tbassert(RCO == 1'b0, "Test 16");
#0
  // output register still shows 255 until latched
  tbassert(Q == 8'hFF, "Test 17");
#0
  // latch wrapped counter
  pulse_rclk();
#6
  tbassert(Q == 8'h00, "Test 18");
#50

  // the following set of tests are for: clear during count

  // count up a few
  pulse_cclk();
  pulse_cclk();
  pulse_cclk();
  pulse_rclk();
#6
  tbassert(Q == 8'h03, "Test 19");
#25
  // clear counter asynchronously
  CCLR_bar = 1'b0;
#7
  // output register retains value after counter clear
  tbassert(Q == 8'h03, "Test 20");
  tbassert(RCO == 1'b0, "Test 20");
#50
  CCLR_bar = 1'b1;
#25
  // latch cleared counter -> output shows 0
  pulse_rclk();
#6
  tbassert(Q == 8'h00, "Test 21");
#50

  // the following set of tests are for: independent clock domains

  // demonstrate RCLK can latch same counter value multiple times
  pulse_cclk();
  pulse_cclk();
  pulse_cclk();
#0
  // latch counter value 3
  pulse_rclk();
#6
  tbassert(Q == 8'h03, "Test 22");
#25
  // latch again without counting -> same value
  pulse_rclk();
#6
  tbassert(Q == 8'h03, "Test 23");
#50
  // simultaneous clock edges: CCLK and RCLK rising together
  // output register latches the pre-increment value
  CCLK = 1'b0;
  RCLK = 1'b0;
#25
  CCLK = 1'b1;
  RCLK = 1'b1;
#6
  tbassert(Q == 8'h03, "Test 24");
#50
  // next latch shows the incremented value
  pulse_rclk();
#6
  tbassert(Q == 8'h04, "Test 25");
#50

  // the following set of tests are for: timing

  // timing: clear, latch zero, then count and latch to verify rise delay
  CCLR_bar = 1'b0;
#7
  CCLR_bar = 1'b1;
#25
  pulse_rclk();
#6
  tbassert(Q == 8'h00, "Test 26");
#25
  pulse_cclk();
  RCLK = 1'b0;
#25
  RCLK = 1'b1;
#2
  // not enough time for rise (5)
  tbassert(Q == 8'h00, "Test 27");
#4
  // enough time for rise
  tbassert(Q == 8'h01, "Test 27");
#10
  $finish;
end

endmodule
