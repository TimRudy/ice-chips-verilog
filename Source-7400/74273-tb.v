// Test: Octal D flip-flop with clear

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2R_METHOD(tbassert2R)

localparam WIDTH = 3;

// DUT inputs
reg Clear_bar;
reg [WIDTH-1:0] D;
reg Clk;

// DUT outputs
wire [WIDTH-1:0] Q;

// DUT
ttl_74273 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Clear_bar(Clear_bar),
  .D(D),
  .Clk(Clk),
  .Q(Q)
);

initial
begin
  reg [WIDTH-1:0] D_next;
  reg [WIDTH-1:0] Q_expected;
  integer i;

  $dumpfile("74273-tb.vcd");
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
  // hold state, the clear input takes on a value
  Clear_bar = 1'b1;
#50
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

  // the following set of tests are for: clear

  // clear from 101, not enough time for output to fall
  Clear_bar = 1'b0;
#2
  tbassert(Q == 3'b101, "Test 7");
#2
  // clear from 101 -> output 0s
  tbassert(Q == 3'b000, "Test 7");
#150
  // hold state -> remains clear after clear signal ends
  Clear_bar = 1'b1;
#120
  tbassert(Q == 3'b000, "Test 8");
#50
  // load new value
  D = 3'b011;
#15
  Clk = 1'b1;
#15
  Clk = 1'b0;
#15
  tbassert(Q == 3'b011, "Test 9");
#0
  // set up different data input value
  D = 3'b010;
#15
  // clear from 011 in contention with load (at clock edge)
  Clear_bar = 1'b0;
  Clk = 1'b1;
#2
  tbassert(Q == 3'b011, "Test 9");
#2
  // clear from 011 in contention with load -> output 0s
  tbassert(Q == 3'b000, "Test 9");
#150
  // hold state -> remains clear after clear signal ends
  Clear_bar = 1'b1;
#70
  tbassert(Q == 3'b000, "Test 10");
#50

  // the following set of tests are for: clear from initial state

  // set up the data for initial state
  D = 3'bxxx;
#15
  // load to initial state
  Clk = 1'b0;
#15
  Clk = 1'b1;
#15
  tbassert(Q === 3'bxxx, "Test 11");
#0
  // set up the control inputs for initial state
  Clear_bar = 1'bx;
  Clk = 1'bx;
#15
  // clear from initial state, not enough time for output to fall
  Clear_bar = 1'b0;
#2
  tbassert(Q === 3'bxxx, "Test 11");
#2
  // clear from initial state -> output 0s
  tbassert(Q == 3'b000, "Test 11");
#75
  // hold state -> remains clear after clear signal ends
  Clear_bar = 1'b1;
#80
  tbassert(Q == 3'b000, "Test 12");
#0
  D = 3'b000;
#15
  // hold state, the clock input takes on a value, first 1 then 0
  Clk = 1'b1;
#15
  tbassert(Q == 3'b000, "Test 12");
#0
  Clk = 1'b0;
#15
  tbassert(Q == 3'b000, "Test 12");
#0

  // repeat tests: hold state

  D_next = 3'b000;  // initial value to start the loop

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
    D = Q_expected;
#7
    Clk = 1'b1;
#20
    tbassert2R(Q == Q_expected, "Test", "1", (12 + i));
#0
    Clk = 1'b0;
#50
    tbassert2R(Q == Q_expected, "Test", "1", (12 + i));
#0
    // transient (unclocked) change to data input with null effect on output
    Clk = 1'b1;
#7
    D = D_next;
#75
    tbassert2R(Q == Q_expected, "Test", "2", (12 + i));
#0
    Clk = 1'b0;
#25
    D = 3'bzzz;
#25
    tbassert2R(Q == Q_expected, "Test", "2", (12 + i));

  end

  // end repeat tests

  tbassert2R(Q == 3'b001, "Test", "2", 15);  // actual value at exit of the loop
#50
  $finish;
end

endmodule
