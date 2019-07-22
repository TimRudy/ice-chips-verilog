// Test: Octal D flip-flop with enable

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2R_METHOD(tbassert2R)

localparam WIDTH = 3;

// DUT inputs
reg Enable_bar;
reg [WIDTH-1:0] D;
reg Clk;

// DUT outputs
wire [WIDTH-1:0] Q;

// DUT
ttl_74377 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Enable_bar(Enable_bar),
  .D(D),
  .Clk(Clk),
  .Q(Q)
);

initial
begin
  reg [WIDTH-1:0] D_next;
  reg [WIDTH-1:0] Q_expected;
  integer i;

  $dumpfile("74377-tb.vcd");
  $dumpvars;

  // the following set of tests are for: load

#65
  // initial state
  tbassert(Q === 3'bxxx, "Test 1");
#0
  // load all zeroes, the clock input takes on a value
  Clk = 1'b0;
#7
  tbassert(Q === 3'bxxx, "Test 1");
#0
  // load all zeroes, set up the data
  D = 3'b000;
#25
  tbassert(Q === 3'bxxx, "Test 1");
#0
  // load all zeroes, steady state before the enable input takes on a value
  Clk = 1'b1;
#50
  Clk = 1'b0;
#50
  Clk = 1'b1;
#50
  tbassert(Q === 3'bxxx, "Test 1");
#0
  // load all zeroes, the enable input takes on a value (disabled)
  Enable_bar = 1'b1;
#50
  tbassert(Q === 3'bxxx, "Test 1");
#0
  // load all zeroes, enabled, steady state before clock edge
  Enable_bar = 1'b0;
  Clk = 1'b0;
#25
  tbassert(Q === 3'bxxx, "Test 1");
#0
  // load all zeroes, not enough time for output to fall
  Clk = 1'b1;
#2
  tbassert(Q === 3'bxxx, "Test 1");
#2
  // load all zeroes -> output 0s
  tbassert(Q == 3'b000, "Test 1");
#140
  // hold state
  Clk = 1'b0;
#175
  tbassert(Q == 3'b000, "Test 2");
#0
  // load all ones, set up the data
  D = 3'b111;
#125
  tbassert(Q == 3'b000, "Test 3");
#0
  // load all ones, not enough time for output to rise
  Clk = 1'b1;
#4
  tbassert(Q == 3'b000, "Test 3");
#2
  // load all ones -> output 1s
  tbassert(Q == 3'b111, "Test 3");
#50
  // hold state
  Clk = 1'b0;
#125
  tbassert(Q == 3'b111, "Test 4");
#0
  // load 101, set up the data
  D = 3'b101;
#15
  // load 101 -> output 101
  Clk = 1'b1;
#7
  tbassert(Q == 3'b101, "Test 5");
#140
  // hold state
  Clk = 1'b0;
#50
  tbassert(Q == 3'b101, "Test 6");
#0

  // the following set of tests are for: enable

  // while disabled, starting at clock 0: no load occurs
  Enable_bar = 1'b1;
  // Clk = 1'b0;
#25
  tbassert(Q == 3'b101, "Test 7");
#0
  // set up different data input value 011
  D = 3'b011;
#15
  // apply clock edge with null effect on output
  Clk = 1'b1;
#50
  Clk = 1'b0;
#50
  tbassert(Q == 3'b101, "Test 7");
#50
  Clk = 1'b1;
#15
  tbassert(Q == 3'b101, "Test 7");
#0
  // while enabled: load data input value 011
  Enable_bar = 1'b0;
#50
  Clk = 1'b0;
#50
  tbassert(Q == 3'b101, "Test 8");
#50
  // load 011 -> output 011
  Clk = 1'b1;
#15
  tbassert(Q == 3'b011, "Test 8");
#75
  // while disabled, starting at clock 1: no load occurs
  Enable_bar = 1'b1;
  // Clk = 1'b1;
#25
  tbassert(Q == 3'b011, "Test 9");
#0
  // set up different data input value 100
  D = 3'b100;
#25
  Clk = 1'b0;
#50
  // apply clock edge with null effect on output
  Clk = 1'b1;
#15
  tbassert(Q == 3'b011, "Test 9");
#35
  Clk = 1'b0;
#50
  Clk = 1'b1;
#15
  tbassert(Q == 3'b011, "Test 9");
#35
  Clk = 1'b0;
#0
  // while enabled: load data input value 100
  Enable_bar = 1'b0;
#25
  // load 100, not enough time for output to rise/fall
  Clk = 1'b1;
#2
  tbassert(Q == 3'b011, "Test 10");
#5
  // load 100 -> output 100
  tbassert(Q == 3'b100, "Test 10");
#75
  // hold state
  Clk = 1'b0;
#80
  tbassert(Q == 3'b100, "Test 11");
#0
  // while enabled: load same value appearing at the output with null effect on output
  Clk = 1'b1;
#50
  Clk = 1'b0;
#50
  tbassert(Q == 3'b100, "Test 12");
#0
  // while disabled: hold state
  Enable_bar = 1'b1;
#75
  tbassert(Q == 3'b100, "Test 13");
#0
  Enable_bar = 1'b0;
#0

  // repeat tests: hold state

  D_next = 3'b100;  // initial value to start the loop

  for (i = 1; i <= 3; i++)
  begin
    Q_expected = D_next;

    case (i)
      1:
      begin
        D_next = 3'b110;
      end
      2:
      begin
        D_next = 3'b001;
      end
      3:
      begin
        D_next = 3'b111;
      end
    endcase
#20
    // load same value appearing at the output with null effect on output
    // Enable_bar = 1'b0;
    D = Q_expected;
#7
    Clk = 1'b1;
#20
    tbassert2R(Q == Q_expected, "Test", "1", (13 + i));
#0
    Clk = 1'b0;
#50
    tbassert2R(Q == Q_expected, "Test", "1", (13 + i));
#0
    // while enabled: transient (unclocked) change to data input with null effect on output
    Clk = 1'b1;
#7
    D = D_next;
#75
    tbassert2R(Q == Q_expected, "Test", "2", (13 + i));
#0
    Clk = 1'b0;
#25
    // while disabled: change to data input, apply clock edge and no load occurs
    Enable_bar = 1'b1;
    // D = D_next;
#25
    Clk = 1'b1;
#75
    tbassert2R(Q == Q_expected, "Test", "3", (13 + i));
#0
    Clk = 1'b0;
#50
    Clk = 1'b1;
#50
    tbassert2R(Q == Q_expected, "Test", "3", (13 + i));
#0
    Clk = 1'b0;
#25
    Enable_bar = 1'b0;
    D = 3'bzzz;
#25
    tbassert2R(Q == Q_expected, "Test", "3", (13 + i));

  end

  // end repeat tests

  tbassert2R(Q == 3'b001, "Test", "3", 16);  // actual value at exit of the loop
#50
  $finish;
end

endmodule
