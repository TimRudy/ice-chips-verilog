// Test: 4-bit arithmetic logic unit

// Notes:
//
// - active-high data convention is used for all tests below (unless specially indicated);
//   see datasheet for differences between active-high and active-low data convention;
//   for many of the Select inputs, the data convention used affects the operation performed;
//   however, the following operations are consistent and unaffected by active-high or active-low:
//   Select == 1001 (Add)
//   Select == 0110 (Subtract)
//   Select == 1100 (A PLUS A or Shift Left)
//   Select == 0011 (MINUS 1)
//
// - Mode == 0 is for arithmetic (carry is included in calculations);
//   Mode == 1 is for logic (carry is irrelevant)
//
// - C_in, C_out carry signals are inverted compared to A, B and F signals;
//   for example, with active-high data, A_bar == 0 means zero, C_in == 1 means no carry in
//
// - CP_bar output is carry propagate to another unit (for carry lookahead across multiple units);
//   CG_bar output is carry generate to another unit (  "  "  )
//
// - Equal flag output is a valid comparator output only in a specific configuration:
//   the operation must be Select == 0110 (Subtract) with C_in == 1;
//   also in this configuration, Equal and C_out can be used together to indicate B < A or B > A
//
// * see notes below explaining the Subtract operation, its range of values and use of the carry
//
// * see IceChips Technical Notes regarding performance and carry lookahead: in particular, be aware
//   that there is a compromise in using this device with arbitrary WIDTH parameter greater than
//   design value of 4; for a real-world application, where performance is concerned, you will want
//   to use carry lookahead that is hierarchical, meaning multiple 74181 units and a 74182 unit
//
// * refer to the datasheets of the 74181 and the 74182 for information on using CP_bar and CG_bar
//   to create carry lookahead across multiple devices

module test;

`TBASSERT_METHOD(tbassert)
`TBASSERT_2_METHOD(tbassert2)
`TBASSERT_2R_METHOD(tbassert2R)
`TBASSERT_2I_METHOD(tbassert2I)
`CASE_TBASSERT_2R_METHOD(case_tbassert2R, tbassert2R)
`CASE_TBASSERT_2I_METHOD(case_tbassert2I, tbassert2I)

localparam WIDTH = 5;

// DUT inputs
reg [3:0] Select;
reg Mode;
reg C_in;
reg [WIDTH-1:0] A_bar;
reg [WIDTH-1:0] B_bar;

// DUT outputs
wire CP_bar;
wire CG_bar;
wire Equal;
wire C_out;
wire [WIDTH-1:0] F_bar;

// DUT
ttl_74181 #(.WIDTH(WIDTH), .DELAY_RISE(5), .DELAY_FALL(3)) dut(
  .Select(Select),
  .Mode(Mode),
  .C_in(C_in),
  .A_bar(A_bar),
  .B_bar(B_bar),
  .CP_bar(CP_bar),
  .CG_bar(CG_bar),
  .Equal(Equal),
  .C_out(C_out),
  .F_bar(F_bar)
);

initial
begin
  integer i;
  integer j;
  integer k;
  reg C_in_value;
  reg [WIDTH-1:0] A_value;
  reg [WIDTH-1:0] B_value;
  reg C_out_value;
  reg [WIDTH-1:0] F_value;

  $dumpfile("74181-tb.vcd");
  $dumpvars;

  // the following set of tests are for: arithmetic

  Mode = 1'b0;

  // the following set of tests are for: arithmetic: add

  // Notes:
  //
  // 1. the Carry signals are inverted compared to the A, B and F signals:
  //    C_in == 1 is a no carry
  //    C_out == 1 is a no carry
  //
  // 2. value of Carry output:
  //    the Carry output, if present, contributes the positional value of 1 in the next group
  //    of 5 bits: 1<<5 == 32
  //
  // 3. details about the Carry Propagate (CP_bar) and Carry Generate (CG_bar) output signals:
  //
  //    * in this note, number of bits will refer to the device design value of 4, rather than
  //      the number of bits in this test bench; correspondingly, the maximum representable value
  //      will be 15 in context of this discussion
  //
  //    - the signals are only meaningful for Add and Subtract operations; they do not have meaning
  //      for the other 14 arithmetic operations
  //
  //    - the signals are used in the context of multiple units operating on a longer word length:
  //      the adjacent (higher) unit needs to know this unit's Carry output (its Carry input);
  //      the Carry value can be determined in a faster manner than by waiting for each internal
  //      Carry to ripple through the bit calculations of this unit; instead, the calculation is
  //      parallelized by gathering the overall magnitude given by A and B inputs, and using this
  //      as threshold/overflow information as follows
  //
  //    - the magnitude of all 4 A and B inputs summed together is either below the threshold
  //      (there will be no Carry output); or above the threshold at value 16 or greater, meaning
  //      there is overflow (a Carry output); or equal to the threshold at value 15, where overflow
  //      will or will not occur depending on the Carry input
  //
  //    - "Carry Generate" indicates that unconditionally there must be a Carry output, since
  //      the magnitude is already an overflow value (16 or greater)
  //
  //    - "Carry Propagate" indicates that there will be a Carry output precisely if
  //      there is a Carry input (magnitude is at the threshold 15)
  //
  //    - by definition the signals are independent of the Carry input; this is important in their
  //      functional purpose, which is at the longer word length; the purpose is to feed the Carry
  //      input at the lowest bit directly into calculating the Carry input at the next unit's
  //      lowest bit, with minimal gate delay (hence: carry lookahead, and there is no ripple carry)
  //
  //    - external logic is required for this: the Carry input of this unit is gated together
  //      with Carry Propagate and Carry Generate to create the next unit's Carry input
  //
  //    - the speed-up obtained by using the CP_bar and CG_bar signals becomes more significant
  //      as the number of 74181 units rises
  //
  //    for Add, the information provided by the signals is as follows:
  //
  //    a) if using active-low data convention:
  //
  //       - CP_bar and CG_bar are active-low: a 0 gives the indication
  //       - CP_bar alone indicates that result F == 15
  //       - CG_bar alone indicates that result F >= 16 (overflow)
  //
  //    b) if using active-high data convention:
  //
  //       - CP_bar and CG_bar are active-high: a 1 gives the indication
  //       - roles are swapped: CG_bar is Carry Propagate and CP_bar is Carry Generate
  //       - CG_bar alone indicates that result F == 15
  //       - CG_bar and CP_bar together indicate that result F >= 16 (overflow)
  //
  //    c) this table summarizes the signal values:
  //
  //         Convention  Range    CP_bar CG_bar
  //         ___________ ________ ______ ______
  //
  //         active-low  F < 15   1      1
  //         active-low  F == 15  0      1
  //         active-low  F > 15   X      0 (* CG_bar takes priority here)
  //
  //         active-high F < 15   X      0 (* CG_bar takes priority here)
  //         active-high F == 15  0      1 (* this shows CG_bar acts as Carry Propagate)
  //         active-high F > 15   1      1
  //
  //       * X is don't-care (it takes value 0 or 1 depending on inputs)
  //
  //       * there are three sets of tests below to cover the ranges
  //
  //       * these details are noted here in the interest of behavioural testing; however, the
  //         signal values do not need to concern the designer, because a 74182 or equivalent logic
  //         will receive CP_bar and CG_bar and pass the required signal to the adjacent 74181 unit
  //
  // 4. the function (independent of active-high or active-low data choice):
  //    Select == 4'b1001 is:
  //    F = A PLUS B PLUS Carry

  Select = 4'b1001;

  // all zeroes + Carry 0 -> Sum all 0s + Carry 0
  A_bar = {WIDTH{1'b0}};
  B_bar = {WIDTH{1'b0}};
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00000, "Test 1");
  tbassert(C_out == 1'b1, "Test 1");
  tbassert(CP_bar == 1'b0, "Test 1");
  tbassert(CG_bar == 1'b0, "Test 1");
  // * Note: is not an Equal comparison since operation is not arithmetic: subtract
  tbassert(Equal == 1'b0, "Test 1");
#0
  // all ones (31 + 31) + Carry 1 -> Sum all 1s (31) + Carry 1 (1<<5 == 32)
  A_bar = {WIDTH{1'b1}};
  B_bar = {WIDTH{1'b1}};
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b11111, "Test 2");
  tbassert(C_out == 1'b0, "Test 2");
  tbassert(CP_bar == 1'b1, "Test 2");
  tbassert(CG_bar == 1'b1, "Test 2");
  // * Note: is not an Equal comparison since operation is not arithmetic: subtract
  // * Note: beyond this, the Equal output test will be skipped until arithmetic: subtract
  tbassert(Equal == 1'b1, "Test 2");
#0

  // repeat tests: Carry input is set then clear (meaning, respectively, no Carry then Carry)

  for (i = 3; i <= 4; i++)
  begin
    case (i)
      3:
      begin
        C_in = 1'b1;
      end
      4:
      begin
        C_in = 1'b0;
      end
    endcase

    // the following set of tests show the Carry output unaffected by the Carry input
    // (Carry output is Carry 0)

    // 1 + 1 -> 2 + Carry input
    A_bar = 5'b00001;
    B_bar = 5'b00001;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00010, "Test", "1", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00011, "Test", "1", i);
    tbassert2R(C_out == 1'b1, "Test", "1", i);
    tbassert2R(CP_bar == 1'b1, "Test", "1", i);
    tbassert2R(CG_bar == 1'b0, "Test", "1", i);
#0
    // 1 + 2 -> 3 + Carry input
    // A_bar = 5'b00001;
    B_bar = 5'b00010;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00011, "Test", "2", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00100, "Test", "2", i);
    tbassert2R(C_out == 1'b1, "Test", "2", i);
    tbassert2R(CP_bar == 1'b0, "Test", "2", i);
    tbassert2R(CG_bar == 1'b0, "Test", "2", i);
#0
    // same on the other inputs
    A_bar = 5'b00010;
    B_bar = 5'b00001;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00011, "Test", "3", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00100, "Test", "3", i);
    tbassert2R(C_out == 1'b1, "Test", "3", i);
    tbassert2R(CP_bar == 1'b0, "Test", "3", i);
    tbassert2R(CG_bar == 1'b0, "Test", "3", i);
#0

    // the following set of tests show the Carry output affected by the Carry input

    // zeroes on either side and all ones (0 + 31) -> Sum all 1s (31) + Carry input
    A_bar = 5'b00000;
    B_bar = 5'b11111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11111, "Test", "4", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00000, "Test", "4", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "4", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "4", i);
    tbassert2R(CP_bar == 1'b0, "Test", "4", i);
    tbassert2R(CG_bar == 1'b1, "Test", "4", i);
#0
    // same on the other inputs
    A_bar = 5'b11111;
    B_bar = 5'b00000;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11111, "Test", "5", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00000, "Test", "5", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "5", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "5", i);
    tbassert2R(CP_bar == 1'b0, "Test", "5", i);
    tbassert2R(CG_bar == 1'b1, "Test", "5", i);
#0
    // 16 + 15 -> 31 + Carry input
    A_bar = 5'b10000;
    B_bar = 5'b01111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11111, "Test", "6", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00000, "Test", "6", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "6", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "6", i);
    tbassert2R(CP_bar == 1'b0, "Test", "6", i);
    tbassert2R(CG_bar == 1'b1, "Test", "6", i);
#0
    // all input bits transition from previous (15 + 16) -> 31 + Carry input
    A_bar = 5'b01111;
    B_bar = 5'b10000;
    C_in = ~C_in;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11111, "Test", "7", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00000, "Test", "7", i);
    case_tbassert2R(C_in == 1'b1, C_out == 1'b1, "Test", "7", i);
    case_tbassert2R(C_in == 1'b0, C_out == 1'b0, "Test", "7", i);
    tbassert2R(CP_bar == 1'b0, "Test", "7", i);
    tbassert2R(CG_bar == 1'b1, "Test", "7", i);
#0
    C_in = ~C_in;
#10

    // the following set of tests show the Carry output unaffected by the Carry input
    // (Carry output is Carry 1)

    // 16 + 16 -> 32 + Carry input
    A_bar = 5'b10000;
    B_bar = 5'b10000;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00000, "Test", "8", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00001, "Test", "8", i);
    tbassert2R(C_out == 1'b0, "Test", "8", i);
    tbassert2R(CP_bar == 1'b1, "Test", "8", i);
    tbassert2R(CG_bar == 1'b1, "Test", "8", i);
#0
    // 16 + 18 -> 34 + Carry input
    // A_bar = 5'b10000;
    B_bar = 5'b10010;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00010, "Test", "9", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00011, "Test", "9", i);
    tbassert2R(C_out == 1'b0, "Test", "9", i);
    tbassert2R(CP_bar == 1'b1, "Test", "9", i);
    tbassert2R(CG_bar == 1'b1, "Test", "9", i);
#0
    // 16 + 17 -> 33 + Carry input
    // A_bar = 5'b10000;
    B_bar = 5'b10001;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00001, "Test", "10", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00010, "Test", "10", i);
    tbassert2R(C_out == 1'b0, "Test", "10", i);
    tbassert2R(CP_bar == 1'b1, "Test", "10", i);
    tbassert2R(CG_bar == 1'b1, "Test", "10", i);
#0

    // the following set of tests show the Carry output unaffected by the Carry input
    // (Carry output is Carry 0)

    // all input bits transition from previous (15 + 14) -> 29 + Carry input
    A_bar = 5'b01111;
    B_bar = 5'b01110;
    C_in = ~C_in;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11101, "Test", "11", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b11110, "Test", "11", i);
    tbassert2R(C_out == 1'b1, "Test", "11", i);
    tbassert2R(CP_bar == 1'b1, "Test", "11", i);
    tbassert2R(CG_bar == 1'b0, "Test", "11", i);
#0
    C_in = ~C_in;

  end

  // end repeat tests
#0

  // 2 + 2 + Carry 0 -> 4
  A_bar = 5'b00010;
  B_bar = 5'b00010;
  C_in = 1'b1;
#6
  tbassert(F_bar == 5'b00100, "Test 5");
  tbassert(C_out == 1'b1, "Test 5");
  tbassert(CP_bar == 1'b1, "Test 5");
  tbassert(CG_bar == 1'b0, "Test 5");
#0
  // 2 + 2 + Carry 1 -> 5
  // A_bar = 5'b00010;
  // B_bar = 5'b00010;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b00101, "Test 6");
  tbassert(C_out == 1'b1, "Test 6");
  tbassert(CP_bar == 1'b1, "Test 6");
  tbassert(CG_bar == 1'b0, "Test 6");
#0
  // 3 + 5 + Carry 1 -> 9
  A_bar = 5'b00011;
  B_bar = 5'b00101;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b01001, "Test 7");
  tbassert(C_out == 1'b1, "Test 7");
  tbassert(CP_bar == 1'b1, "Test 7");
  tbassert(CG_bar == 1'b0, "Test 7");
#0
  // 13 + 13 + Carry 1 -> 27
  A_bar = 5'b01101;
  B_bar = 5'b01101;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b11011, "Test 8");
  tbassert(C_out == 1'b1, "Test 8");
  tbassert(CP_bar == 1'b1, "Test 8");
  tbassert(CG_bar == 1'b0, "Test 8");
#0
  // 13 + 17 + Carry 1 -> 31
  A_bar = 5'b01101;
  B_bar = 5'b10001;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b11111, "Test 9");
  tbassert(C_out == 1'b1, "Test 9");
  tbassert(CP_bar == 1'b1, "Test 9");
  tbassert(CG_bar == 1'b0, "Test 9");
#0
  // 17 + 17 + Carry 1 -> 35
  A_bar = 5'b10001;
  B_bar = 5'b10001;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b00011, "Test 10");
  tbassert(C_out == 1'b0, "Test 10");
  tbassert(CP_bar == 1'b1, "Test 10");
  tbassert(CG_bar == 1'b1, "Test 10");
#0
  // 7 + 27 + Carry 1 -> 35
  A_bar = 5'b00111;
  B_bar = 5'b11011;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b00011, "Test 11");
  tbassert(C_out == 1'b0, "Test 11");
  tbassert(CP_bar == 1'b1, "Test 11");
  tbassert(CG_bar == 1'b1, "Test 11");
#0
  // 19 + 31 + Carry 1 -> 51
  A_bar = 5'b10011;
  B_bar = 5'b11111;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b10011, "Test 12");
  tbassert(C_out == 1'b0, "Test 12");
  tbassert(CP_bar == 1'b1, "Test 12");
  tbassert(CG_bar == 1'b1, "Test 12");
#0
  // 23 + 29 + Carry 0 -> 52
  A_bar = 5'b10111;
  B_bar = 5'b11101;
  C_in = 1'b1;
#6
  tbassert(F_bar == 5'b10100, "Test 13");
  tbassert(C_out == 1'b0, "Test 13");
  tbassert(CP_bar == 1'b1, "Test 13");
  tbassert(CG_bar == 1'b1, "Test 13");
#0
  // 23 + 29 + Carry 1 -> 53
  // A_bar = 5'b10111;
  // B_bar = 5'b11101;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b10101, "Test 14");
  tbassert(C_out == 1'b0, "Test 14");
  tbassert(CP_bar == 1'b1, "Test 14");
  tbassert(CG_bar == 1'b1, "Test 14");
#0

  // the following set of tests show transitions between input bits that are set to ones
  // with null effect on outputs

  // 3 + 5 + Carry 0 -> 8
  A_bar = 5'b00011;
  B_bar = 5'b00101;
  C_in = 1'b1;
#6
  tbassert(F_bar == 5'b01000, "Test 15");
  tbassert(C_out == 1'b1, "Test 15");
  tbassert(CP_bar == 1'b1, "Test 15");
  tbassert(CG_bar == 1'b0, "Test 15");
#0
  // 2 + 5 + Carry 1 -> 8
  A_bar = 5'b00010;
  // B_bar = 5'b00101;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b01000, "Test 16");
  tbassert(C_out == 1'b1, "Test 16");
  tbassert(CP_bar == 1'b0, "Test 16");
  tbassert(CG_bar == 1'b0, "Test 16");
#0
  // 19 + 29 + Carry 0 -> 48
  A_bar = 5'b10011;
  B_bar = 5'b11101;
  C_in = 1'b1;
#6
  tbassert(F_bar == 5'b10000, "Test 17");
  tbassert(C_out == 1'b0, "Test 17");
  tbassert(CP_bar == 1'b1, "Test 17");
  tbassert(CG_bar == 1'b1, "Test 17");
#0
  // 29 + 18 + Carry 1 -> 48
  A_bar = 5'b11101;
  B_bar = 5'b10010;
  C_in = 1'b0;
#6
  tbassert(F_bar == 5'b10000, "Test 18");
  tbassert(C_out == 1'b0, "Test 18");
  tbassert(CP_bar == 1'b1, "Test 18");
  tbassert(CG_bar == 1'b1, "Test 18");
#25

  // the following set of tests show the largest input values at which CG_bar output remains clear
  // (CP_bar output is not necessarily clear in this range so CG_bar takes priority)
  // (* because these tests use active-high data convention but the device pins are named
  //    according to active-low data convention, the roles of the two outputs as seen here
  //    are swapped: CG_bar is Carry Propagate and CP_bar is Carry Generate!)

  // 14 + 16 + Carry 0 -> 30
  A_bar = 5'b01110;
  B_bar = 5'b10000;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11110, "Test 19");
  tbassert(C_out == 1'b1, "Test 19");
  tbassert(CP_bar == 1'b0, "Test 19");
  tbassert(CG_bar == 1'b0, "Test 19");
#0
  // 29 + 1 + Carry 0 -> 30
  A_bar = 5'b11101;
  B_bar = 5'b00001;
  // C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11110, "Test 20");
  tbassert(C_out == 1'b1, "Test 20");
  tbassert(CP_bar == 1'b1, "Test 20");
  tbassert(CG_bar == 1'b0, "Test 20");
#0
  // 0 + 30 + Carry 0 -> 30
  A_bar = 5'b00000;
  B_bar = 5'b11110;
  // C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11110, "Test 21");
  tbassert(C_out == 1'b1, "Test 21");
  tbassert(CP_bar == 1'b0, "Test 21");
  tbassert(CG_bar == 1'b0, "Test 21");
#0
  // 29 + 1 + Carry 1 -> 31
  A_bar = 5'b11101;
  B_bar = 5'b00001;
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b11111, "Test 22");
  tbassert(C_out == 1'b1, "Test 22");
  tbassert(CP_bar == 1'b1, "Test 22");
  tbassert(CG_bar == 1'b0, "Test 22");
#0

  // the following set of tests show the specific input values at which CG_bar output
  // becomes set while CP_bar output remains clear
  // (* because these tests use active-high data convention but the device pins are named
  //    according to active-low data convention, the roles of the two outputs as seen here
  //    are swapped: CG_bar is Carry Propagate and CP_bar is Carry Generate!)

  // 10 + 21 + Carry 0 -> 31
  A_bar = 5'b01010;
  B_bar = 5'b10101;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11111, "Test 23");
  tbassert(C_out == 1'b1, "Test 23");
  tbassert(CP_bar == 1'b0, "Test 23");
  tbassert(CG_bar == 1'b1, "Test 23");
#0
  // 9 + 22 + Carry 1 -> 32
  A_bar = 5'b01001;
  B_bar = 5'b10110;
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b00000, "Test 24");
  tbassert(C_out == 1'b0, "Test 24");
  tbassert(CP_bar == 1'b0, "Test 24");
  tbassert(CG_bar == 1'b1, "Test 24");
#0
  // 26 + 5 + Carry 1 -> 32
  A_bar = 5'b11010;
  B_bar = 5'b00101;
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b00000, "Test 25");
  tbassert(C_out == 1'b0, "Test 25");
  tbassert(CP_bar == 1'b0, "Test 25");
  tbassert(CG_bar == 1'b1, "Test 25");
#0
  // 26 + 5 + Carry 0 -> 31
  A_bar = 5'b11010;
  B_bar = 5'b00101;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11111, "Test 26");
  tbassert(C_out == 1'b1, "Test 26");
  tbassert(CP_bar == 1'b0, "Test 26");
  tbassert(CG_bar == 1'b1, "Test 26");
#0

  // the following set of tests show the overflow values at which CG_bar output and CP_bar output
  // are both set
  // (* because these tests use active-high data convention but the device pins are named
  //    according to active-low data convention, the roles of the two outputs as seen here
  //    are swapped: CG_bar is Carry Propagate and CP_bar is Carry Generate!)

  // 31 + 2 + Carry 0 -> 33
  A_bar = 5'b11111;
  B_bar = 5'b00010;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00001, "Test 27");
  tbassert(C_out == 1'b0, "Test 27");
  tbassert(CP_bar == 1'b1, "Test 27");
  tbassert(CG_bar == 1'b1, "Test 27");
#0
  // 28 + 8 + Carry 0 -> 36
  A_bar = 5'b11100;
  B_bar = 5'b01000;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00100, "Test 28");
  tbassert(C_out == 1'b0, "Test 28");
  tbassert(CP_bar == 1'b1, "Test 28");
  tbassert(CG_bar == 1'b1, "Test 28");
#75

  // the following set of tests are for: arithmetic: subtract

  // Notes:
  //
  // 1. the Carry input signal is inverted compared to the A, B and F signals:
  //    C_in == 1 is a no carry
  //
  // 2. the Carry output signal:
  //    C_out == 1 is a borrow, which is also equivalent to "no carry";
  //    the two possible values of C_out correspond to the two possible results of Subtract:
  //
  //    - if the result F is positive, it is the "normal" case (because input numbers A and B
  //      are positive also) and there is nothing to do: C_out == 0, meaning no borrow
  //
  //    - if the result F is negative, it is the "underflow" case: the number needs some
  //      interpretation and this is through using the Carry output value: C_out == 1,
  //      meaning borrow (see value of Carry output, next)
  //
  //    * in different hardware implementations or computer processor architectures, the ALU
  //      Carry output bit (equivalent to the Carry flag stored as state) can use 0 or 1
  //      to represent the borrow for the Subtract operation; this is just a convention,
  //      and the convention for the 74181 is hereby documented
  //      (see IceChips Technical Notes for further information)
  //
  // 3. value of Carry output:
  //    if it is a borrow (C_out == 1), the Carry output contributes the positional value of -1
  //    in the next group of 5 bits: -1<<5 == -32
  //
  // 4. the A input (minuend) is an unsigned, positive number only;
  //    the B input (subtrahend) is an unsigned, positive number only;
  //    the F output result is a signed number (see next)
  //
  // 5. signed number representation and range:
  //    it's useful to note this method of representing a signed number: one bit at the highest
  //    position of a representation can be considered to have a negative value; if present
  //    (equal to 1), then this bit will provide the sign of the number with the correct magnitude
  //    as follows
  //
  //    a) in 5 bits, the smallest negative number that can be represented looks like the following:
  //       the highest bit position is special, and is given a positional value of -16
  //       instead of 16:
  //               1   1   1   1   1
  //             -16 + 8 + 4 + 2 + 1 == -1
  //
  //    b) in 5 bits, the largest negative number is:
  //               1   0   0   0   0
  //             -16 + 0 + 0 + 0 + 0 == -16
  //
  //    c) in 5 bits (when it is a signed number), a positive number cannot exceed this magnitude
  //       so as not to use the high bit value:
  //               0   1   1   1   1
  //               0 + 8 + 4 + 2 + 1 == 15
  //
  //    d) however, 6 bits could be used as well; if we wish to use the first 5 bits to represent
  //       numbers up to 31, a signed number representation for this is:
  //         0     1   1   1   1   1
  //         0  + 16 + 8 + 4 + 2 + 1 == 31
  //
  //    e) in 6 bits, a negative number looks like the following:
  //         1     0   1   1   1   1
  //       -32   + 0 + 8 + 4 + 2 + 1 == -17
  //
  // 6. ones complement operation gives subtraction:
  //    the base operation for this device is not actually twos complement addition but ones
  //    complement addition; consequently, there is an extra "MINUS 1" in the function expression;
  //    here is an example of applying the operation to 14 and 5 (F output result == 9):
  //
  //    a) provide A input == 14:
  //               0   1   1   1   0
  //               0 + 8 + 4 + 2 + 0 == 14
  //
  //    b) provide B input == 5:
  //               0   0   1   0   1
  //               0 + 0 + 4 + 0 + 1 == 5
  //
  //    c) provide C_in input == 1 (the default input, meaning: no Carry):
  //               0   0   0   0   1
  //               0 + 0 + 0 + 0 + 1 == 1
  //
  //    d) ones complement of 5 ("~5"):
  //               1   1   0   1   0
  //             -16 + 8 + 0 + 2 + 0 == -6
  //
  //    e) ones complement addition operation A PLUS ~B:
  //               0   1   1   1   0 == 14
  //               1   1   0   1   0 == -6
  //             + _________________
  //         1     0   1   0   0   0 == 8 with a carry out bit
  //
  //    f) therefore the ones complement addition by itself is:
  //       A PLUS ~B == A MINUS B MINUS 1 (with a carry out bit)
  //
  //    g) however, the carry in bit is used in a "PLUS Carry" as well; recall that this bit
  //       is inverted compared to its arithmetic value*, and in the present case, from (c),
  //       the bit value is 1; so here is the operation A PLUS ~B PLUS Carry:
  //         1     0   1   0   0   0 == 8 with a carry out bit
  //               0   0   0   0   1 == 1
  //             + _________________
  //         1     0   1   0   0   1 == 9 with a carry out bit (this bit is also inverted**)
  //
  //       * the inverted definitions of the Carry input and Carry output signals for this
  //         device are a convenience for doing arithmetic and for signal connection between
  //         devices with a minimal gate delay
  //
  //       ** the carry out bit 1 here appears actually as C_out output == 0
  //
  //    h) the overall subtraction operation is*:
  //       A PLUS ~B PLUS Carry == A MINUS B MINUS 1 PLUS Carry
  //
  //       * subject to the appropriate definition of "Carry"
  //         (think of it as: invert B and invert the carry in; perform addition; then invert
  //         the carry out)
  //
  // 7. details about the numerical ranges of inputs, outputs, and the resulting Carry output:
  //    for Subtract, the values of A and B inputs and the Carry input divide into
  //    three domains as follows
  //
  //    * as mentioned, A and B are always positive, unsigned numbers
  //
  //    * F positive includes F equal to zero
  //
  //    a) Domain 1: B < A*, result F is positive
  //                 - always C_out == 0
  //                 - "no underflow" case: the result (a small number which is a positive
  //                   difference) is exactly the number that it appears to be
  //
  //                 * extends to B <= A in the case of C_in == 0, because with this Carry in
  //                   value of 1 and B == A, result F will still be zero and not go negative
  //                   (see Domain 3)
  //
  //    b) Domain 2: B > A, result F is negative
  //                 - here B cannot be zero (as A is zero or greater)
  //                 - always C_out == 1
  //                 - "underflow" case: the result is interpreted as the correct negative
  //                   number by adding -32 (Borrow: -1<<5 == -32)
  //
  //    c) Domain 3: B == A with C_in == 1 (no Carry in), result F == -1
  //                   (successful Equal comparison)
  //                 - C_in == 1 is a requirement
  //                 - always C_out == 1
  //                 - "underflow" case as above
  //                 - Equal == 1
  //
  // 8. details about the Carry Propagate (CP_bar) and Carry Generate (CG_bar) output signals:
  //
  //    * in this note, number of bits will refer to the device design value of 4, rather than
  //      the number of bits in this test bench
  //
  //    - the signals are only meaningful for Add and Subtract operations; they do not have meaning
  //      for the other 14 arithmetic operations
  //
  //    - the signals are used in the context of multiple units operating on a longer word length:
  //      the adjacent (higher) unit needs to know this unit's Carry output (its Carry input);
  //      the Carry value can be determined in a faster manner than by waiting for each internal
  //      Carry to ripple through the bit calculations of this unit; instead, the calculation is
  //      parallelized by gathering the overall magnitude given by A and B inputs, and using this
  //      as threshold/underflow information as follows
  //
  //    - the magnitude of all 4 A and B inputs (difference) is either above the threshold
  //      (there will be no Borrow); or below the threshold at value -1 or less, meaning
  //      there is underflow (a Borrow); or equal to the threshold at value 0, where underflow
  //      will or will not occur depending on the Carry input
  //
  //    - "Carry Generate" indicates that unconditionally there must be a Borrow, since
  //      the magnitude is already an underflow value (-1 or less)
  //
  //    - "Carry Propagate" indicates that there will be a Borrow/no Borrow precisely if
  //      there is no Carry input/Carry input (magnitude is at the threshold 0)
  //
  //    - by definition the signals are independent of the Carry input; this is important in their
  //      functional purpose, which is at the longer word length; the purpose is to feed the Carry
  //      input at the lowest bit directly into calculating the Carry input at the next unit's
  //      lowest bit, with minimal gate delay (hence: carry lookahead, and there is no ripple carry)
  //
  //    - external logic is required for this: the Carry input of this unit is gated together
  //      with Carry Propagate and Carry Generate to create the next unit's Carry input
  //
  //    - the speed-up obtained by using the CP_bar and CG_bar signals becomes more significant
  //      as the number of 74181 units rises
  //
  //    for Subtract, the information provided by the signals is as follows:
  //
  //    a) if using active-low data convention:
  //
  //       - CP_bar and CG_bar are active-high: a 1 gives the indication
  //       - roles are swapped: CG_bar is Carry Propagate and CP_bar is Carry Generate
  //       - CG_bar alone indicates that result F == 0
  //       - CG_bar and CP_bar together indicate that result F < 0 (underflow)
  //
  //    b) if using active-high data convention:
  //
  //       - CP_bar and CG_bar are active-low: a 0 gives the indication
  //       - CP_bar alone indicates that result F == 0
  //       - CG_bar alone indicates that result F < 0 (underflow)
  //
  //    c) this table summarizes the signal values:
  //
  //         Convention  Range    CP_bar CG_bar
  //         ___________ ________ ______ ______
  //
  //         active-low  F > 0    X      0 (* CG_bar takes priority here)
  //         active-low  F == 0   0      1 (* this shows CG_bar acts as Carry Propagate)
  //         active-low  F < 0    1      1
  //
  //         active-high F > 0    1      1
  //         active-high F == 0   0      1
  //         active-high F < 0    X      0 (* CG_bar takes priority here)
  //
  //       * X is don't-care (it takes value 0 or 1 depending on inputs)
  //
  //       * there are three sets of tests below to cover the ranges
  //
  //       * these details are noted here in the interest of behavioural testing; however, the
  //         signal values do not need to concern the designer, because a 74182 or equivalent logic
  //         will receive CP_bar and CG_bar and pass the required signal to the adjacent 74181 unit
  //
  // 9. the function (independent of active-high or active-low data choice):
  //    Select == 4'b0110 is:
  //    F = A MINUS B MINUS 1 PLUS Carry

  // Mode = 1'b0;

  Select = 4'b0110;

  // all zeroes (0 - 0 - 1) + Carry 1 -> 0 (with C_out == 0, meaning: no Borrow)
  // (Domain 1)
  A_bar = {WIDTH{1'b0}};
  B_bar = {WIDTH{1'b0}};
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b00000, "Test 29");
  tbassert(C_out == 1'b0, "Test 29");
  tbassert(CP_bar == 1'b0, "Test 29");
  tbassert(CG_bar == 1'b1, "Test 29");
  // * Note: is not an Equal comparison since C_in == 0
  tbassert(Equal == 1'b0, "Test 29");
#0
  // all zeroes (0 - 0 - 1) + Carry 0 -> -1 (with Equal == 1, C_out == 1, meaning: Borrow)
  // (Domain 3)
  // A_bar = {WIDTH{1'b0}};
  // B_bar = {WIDTH{1'b0}};
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11111, "Test 30");
  tbassert(C_out == 1'b1, "Test 30");
  tbassert(CP_bar == 1'b0, "Test 30");
  tbassert(CG_bar == 1'b1, "Test 30");
  // * Note: is an Equal comparison since C_in == 1
  tbassert(Equal == 1'b1, "Test 30");
#0
  // all ones (31 - 31 - 1) + Carry 0 -> -1 (with Equal == 1, C_out == 1)
  // (Domain 3)
  A_bar = {WIDTH{1'b1}};
  B_bar = {WIDTH{1'b1}};
  // C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11111, "Test 31");
  tbassert(C_out == 1'b1, "Test 31");
  tbassert(CP_bar == 1'b0, "Test 31");
  tbassert(CG_bar == 1'b1, "Test 31");
  // * Note: is an Equal comparison since C_in == 1
  tbassert(Equal == 1'b1, "Test 31");
#0
  // all ones (31 - 31 - 1) + Carry 1 -> 0 (with C_out == 0)
  // (Domain 1)
  // A_bar = {WIDTH{1'b1}};
  // B_bar = {WIDTH{1'b1}};
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b00000, "Test 32");
  tbassert(C_out == 1'b0, "Test 32");
  tbassert(CP_bar == 1'b0, "Test 32");
  tbassert(CG_bar == 1'b1, "Test 32");
  // * Note: is not an Equal comparison since C_in == 0
  tbassert(Equal == 1'b0, "Test 32");
#0

  // repeat tests: Carry input is set then clear (meaning, respectively, no Carry then Carry)

  for (i = 33; i <= 34; i++)
  begin
    case (i)
      33:
      begin
        C_in = 1'b1;
      end
      34:
      begin
        C_in = 1'b0;
      end
    endcase

    // the following set of tests show B > A, therefore result F is negative
    // with Carry output C_out == 1, meaning: Borrow
    // (Domain 2)

    // 0 - 16 - 1 + Carry -> 15 or 16 + Borrow 1 (-1<<5 == -32) (total -17 or -16)
    A_bar = 5'b00000;
    B_bar = 5'b10000;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b01111, "Test", "1", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b10000, "Test", "1", i);
    tbassert2R(C_out == 1'b1, "Test", "1", i);
    tbassert2R(CP_bar == 1'b0, "Test", "1", i);
    tbassert2R(CG_bar == 1'b0, "Test", "1", i);
    tbassert2R(Equal == 1'b0, "Test", "1", i);
#0
    // 0 - 31 - 1 + Carry -> 0 or 1 (total -32 or -31)
    A_bar = 5'b00000;
    B_bar = 5'b11111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00000, "Test", "2", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00001, "Test", "2", i);
    tbassert2R(C_out == 1'b1, "Test", "2", i);
    tbassert2R(CP_bar == 1'b0, "Test", "2", i);
    tbassert2R(CG_bar == 1'b0, "Test", "2", i);
    tbassert2R(Equal == 1'b0, "Test", "2", i);
#0
    // 1 - 31 - 1 + Carry -> 1 or 2 (total -31 or -30)
    A_bar = 5'b00001;
    // B_bar = 5'b11111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00001, "Test", "3", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00010, "Test", "3", i);
    tbassert2R(C_out == 1'b1, "Test", "3", i);
    tbassert2R(CP_bar == 1'b0, "Test", "3", i);
    tbassert2R(CG_bar == 1'b0, "Test", "3", i);
    tbassert2R(Equal == 1'b0, "Test", "3", i);
#0
    // 16 - 31 - 1 + Carry -> 16 or 17 (total -16 or -15)
    A_bar = 5'b10000;
    // B_bar = 5'b11111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b10000, "Test", "4", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b10001, "Test", "4", i);
    tbassert2R(C_out == 1'b1, "Test", "4", i);
    tbassert2R(CP_bar == 1'b0, "Test", "4", i);
    tbassert2R(CG_bar == 1'b0, "Test", "4", i);
    tbassert2R(Equal == 1'b0, "Test", "4", i);
#0
    // 30 - 31 - 1 + Carry -> 30 or 31 (total -2 or -1)
    A_bar = 5'b11110;
    // B_bar = 5'b11111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11110, "Test", "5", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b11111, "Test", "5", i);
    tbassert2R(C_out == 1'b1, "Test", "5", i);
    tbassert2R(CP_bar == 1'b0, "Test", "5", i);
    tbassert2R(CG_bar == 1'b0, "Test", "5", i);
    case_tbassert2R(C_in == 1'b1, Equal == 1'b0, "Test", "5", i);
    // * Note: is not an Equal comparison since C_in == 0
    case_tbassert2R(C_in == 1'b0, Equal == 1'b1, "Test", "5", i);
#0
    // 15 - 30 - 1 + Carry -> 16 or 17 (total -16 or -15)
    A_bar = 5'b01111;
    B_bar = 5'b11110;
#7
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b10000, "Test", "6", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b10001, "Test", "6", i);
    tbassert2R(C_out == 1'b1, "Test", "6", i);
    tbassert2R(CP_bar == 1'b1, "Test", "6", i);
    tbassert2R(CG_bar == 1'b0, "Test", "6", i);
    tbassert2R(Equal == 1'b0, "Test", "6", i);
#0
    // 15 - 17 - 1 + Carry -> 29 or 30 (total -3 or -2)
    // A_bar = 5'b01111;
    B_bar = 5'b10001;
#7
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11101, "Test", "7", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b11110, "Test", "7", i);
    tbassert2R(C_out == 1'b1, "Test", "7", i);
    tbassert2R(CP_bar == 1'b1, "Test", "7", i);
    tbassert2R(CG_bar == 1'b0, "Test", "7", i);
    tbassert2R(Equal == 1'b0, "Test", "7", i);
#0
    // 0 - 15 - 1 + Carry -> 16 or 17 (total -16 or -15)
    A_bar = 5'b00000;
    B_bar = 5'b01111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b10000, "Test", "8", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b10001, "Test", "8", i);
    tbassert2R(C_out == 1'b1, "Test", "8", i);
    tbassert2R(CP_bar == 1'b0, "Test", "8", i);
    tbassert2R(CG_bar == 1'b0, "Test", "8", i);
    tbassert2R(Equal == 1'b0, "Test", "8", i);
#0
    // 1 - 2 - 1 + Carry -> 30 or 31 (total -2 or -1)
    A_bar = 5'b00001;
    B_bar = 5'b00010;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11110, "Test", "9", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b11111, "Test", "9", i);
    tbassert2R(C_out == 1'b1, "Test", "9", i);
    tbassert2R(CP_bar == 1'b1, "Test", "9", i);
    tbassert2R(CG_bar == 1'b0, "Test", "9", i);
    case_tbassert2R(C_in == 1'b1, Equal == 1'b0, "Test", "9", i);
    // * Note: is not an Equal comparison since C_in == 0
    case_tbassert2R(C_in == 1'b0, Equal == 1'b1, "Test", "9", i);
#0
    // 1 - 13 - 1 + Carry -> 19 or 20 (total -13 or -12)
    // A_bar = 5'b00001;
    B_bar = 5'b01101;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b10011, "Test", "10", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b10100, "Test", "10", i);
    tbassert2R(C_out == 1'b1, "Test", "10", i);
    tbassert2R(CP_bar == 1'b0, "Test", "10", i);
    tbassert2R(CG_bar == 1'b0, "Test", "10", i);
    tbassert2R(Equal == 1'b0, "Test", "10", i);
#0
    // 13 - 14 - 1 + Carry -> 30 or 31 (total -2 or -1)
    A_bar = 5'b01101;
    B_bar = 5'b01110;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b11110, "Test", "11", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b11111, "Test", "11", i);
    tbassert2R(C_out == 1'b1, "Test", "11", i);
    tbassert2R(CP_bar == 1'b1, "Test", "11", i);
    tbassert2R(CG_bar == 1'b0, "Test", "11", i);
    case_tbassert2R(C_in == 1'b1, Equal == 1'b0, "Test", "11", i);
    // * Note: is not an Equal comparison since C_in == 0
    case_tbassert2R(C_in == 1'b0, Equal == 1'b1, "Test", "11", i);
#45

    // the following set of tests show B < A, therefore result F is positive
    // with Carry output C_out == 0, meaning: no Borrow
    // (Domain 1)

    // 31 - 16 - 1 + Carry -> 14 or 15
    A_bar = 5'b11111;
    B_bar = 5'b10000;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b01110, "Test", "12", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b01111, "Test", "12", i);
    tbassert2R(C_out == 1'b0, "Test", "12", i);
    tbassert2R(CP_bar == 1'b1, "Test", "12", i);
    tbassert2R(CG_bar == 1'b1, "Test", "12", i);
    tbassert2R(Equal == 1'b0, "Test", "12", i);
#0
    // 20 - 16 - 1 + Carry -> 3 or 4
    A_bar = 5'b10100;
    // B_bar = 5'b10000;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00011, "Test", "13", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00100, "Test", "13", i);
    tbassert2R(C_out == 1'b0, "Test", "13", i);
    tbassert2R(CP_bar == 1'b1, "Test", "13", i);
    tbassert2R(CG_bar == 1'b1, "Test", "13", i);
    tbassert2R(Equal == 1'b0, "Test", "13", i);
#0
    // 16 - 4 - 1 + Carry -> 11 or 12
    A_bar = 5'b10000;
    B_bar = 5'b00100;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b01011, "Test", "14", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b01100, "Test", "14", i);
    tbassert2R(C_out == 1'b0, "Test", "14", i);
    tbassert2R(CP_bar == 1'b1, "Test", "14", i);
    tbassert2R(CG_bar == 1'b1, "Test", "14", i);
    tbassert2R(Equal == 1'b0, "Test", "14", i);
#0
    // 26 - 23 - 1 + Carry -> 2 or 3
    A_bar = 5'b11010;
    B_bar = 5'b10111;
#10
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00010, "Test", "15", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00011, "Test", "15", i);
    tbassert2R(C_out == 1'b0, "Test", "15", i);
    tbassert2R(CP_bar == 1'b1, "Test", "15", i);
    tbassert2R(CG_bar == 1'b1, "Test", "15", i);
    tbassert2R(Equal == 1'b0, "Test", "15", i);
#0
    // 6 - 3 - 1 + Carry -> 2 or 3
    A_bar = 5'b00110;
    B_bar = 5'b00011;
#7
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00010, "Test", "16", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00011, "Test", "16", i);
    tbassert2R(C_out == 1'b0, "Test", "16", i);
    tbassert2R(CP_bar == 1'b1, "Test", "16", i);
    tbassert2R(CG_bar == 1'b1, "Test", "16", i);
    tbassert2R(Equal == 1'b0, "Test", "16", i);
#0
    // 22 - 21 - 1 + Carry -> 0 or 1
    A_bar = 5'b10110;
    B_bar = 5'b10101;
#7
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00000, "Test", "17", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00001, "Test", "17", i);
    tbassert2R(C_out == 1'b0, "Test", "17", i);
    tbassert2R(CP_bar == 1'b1, "Test", "17", i);
    tbassert2R(CG_bar == 1'b1, "Test", "17", i);
    tbassert2R(Equal == 1'b0, "Test", "17", i);
#0
    // 2 - 1 - 1 + Carry -> 0 or 1
    A_bar = 5'b00010;
    B_bar = 5'b00001;
#7
    case_tbassert2R(C_in == 1'b1, F_bar == 5'b00000, "Test", "18", i);
    case_tbassert2R(C_in == 1'b0, F_bar == 5'b00001, "Test", "18", i);
    tbassert2R(C_out == 1'b0, "Test", "18", i);
    tbassert2R(CP_bar == 1'b1, "Test", "18", i);
    tbassert2R(CG_bar == 1'b1, "Test", "18", i);
    tbassert2R(Equal == 1'b0, "Test", "18", i);

  end

  // end repeat tests
#25

  // the following set of tests show the smallest positive difference values at which both
  // CG_bar output and CP_bar output remain set
  // (Domain 1)
  // (* using active-high data convention, the functionality of the two outputs aligns with
  //    the pin names: CP_bar is Carry Propagate and CG_bar is Carry Generate)

  // 7 - 6 - 1 + Carry 0 -> 0
  A_bar = 5'b00111;
  B_bar = 5'b00110;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00000, "Test 35");
  tbassert(C_out == 1'b0, "Test 35");
  tbassert(CP_bar == 1'b1, "Test 35");
  tbassert(CG_bar == 1'b1, "Test 35");
  tbassert(Equal == 1'b0, "Test 35");
#0
  // 17 - 16 - 1 + Carry 0 -> 0
  A_bar = 5'b10001;
  B_bar = 5'b10000;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00000, "Test 36");
  tbassert(C_out == 1'b0, "Test 36");
  tbassert(CP_bar == 1'b1, "Test 36");
  tbassert(CG_bar == 1'b1, "Test 36");
  tbassert(Equal == 1'b0, "Test 36");
#0
  // 1 - 0 - 1 + Carry 1 -> 1
  A_bar = 5'b00001;
  B_bar = 5'b00000;
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b00001, "Test 37");
  tbassert(C_out == 1'b0, "Test 37");
  tbassert(CP_bar == 1'b1, "Test 37");
  tbassert(CG_bar == 1'b1, "Test 37");
  tbassert(Equal == 1'b0, "Test 37");
#0
  // 1 - 0 - 1 + Carry 0 -> 0
  // A_bar = 5'b00001;
  // B_bar = 5'b00000;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00000, "Test 38");
  tbassert(C_out == 1'b0, "Test 38");
  tbassert(CP_bar == 1'b1, "Test 38");
  tbassert(CG_bar == 1'b1, "Test 38");
  tbassert(Equal == 1'b0, "Test 38");
#45

  // the following set of tests show successful Equal comparison
  // (Domain 3);
  // these are also the specific input values at which CP_bar output becomes clear
  // while CG_bar output remains set
  // (* using active-high data convention, the functionality of the two outputs aligns with
  //    the pin names: CP_bar is Carry Propagate and CG_bar is Carry Generate)

  // a - a - 1 + Carry 0 -> -1 (with Equal == 1, C_out == 1)
  C_in = 1'b1;

  // repeat tests: all A input values, all B input values

  for (i = 0; i <= 31; i++)
  begin
    A_bar = i;
    B_bar = i;
#10
    tbassert2(F_bar == 5'b11111, "Test", (1 + i), "39");
    tbassert2(C_out == 1'b1, "Test", (1 + i), "39");
    tbassert2(CP_bar == 1'b0, "Test", (1 + i), "39");
    tbassert2(CG_bar == 1'b1, "Test", (1 + i), "39");
    // * Note: is an Equal comparison since C_in == 1
    tbassert2(Equal == 1'b1, "Test", (1 + i), "39");

  end

  // end repeat tests
#25

  // the following set of tests show Equal comparison where Equal and C_out can be used together
  // to indicate B < A or B > A

  // B < A (difference 6 - 5) -> Equal == 0, C_out == 0
  // (Domain 1)
  A_bar = 5'b00110;
  B_bar = 5'b00101;
  // C_in = 1'b1;
#10
  tbassert(F_bar == 5'b00000, "Test 40");
  tbassert(C_out == 1'b0, "Test 40");
  tbassert(CP_bar == 1'b1, "Test 40");
  tbassert(CG_bar == 1'b1, "Test 40");
  // * Note: is an Equal comparison since C_in == 1
  tbassert(Equal == 1'b0, "Test 40");
#0
  // B > A (difference 5 - 6) -> Equal == 0, C_out == 1
  // (Domain 2)
  A_bar = 5'b00101;
  B_bar = 5'b00110;
  // C_in = 1'b1;
#10
  tbassert(F_bar == 5'b11110, "Test 41");
  tbassert(C_out == 1'b1, "Test 41");
  tbassert(CP_bar == 1'b1, "Test 41");
  tbassert(CG_bar == 1'b0, "Test 41");
  // * Note: is an Equal comparison since C_in == 1
  tbassert(Equal == 1'b0, "Test 41");
#0
  // B < A (difference 28 - 23) -> Equal == 0, C_out == 0
  // (Domain 1)
  A_bar = 5'b11100;
  B_bar = 5'b10111;
  // C_in = 1'b1;
#10
  tbassert(F_bar == 5'b00100, "Test 42");
  tbassert(C_out == 1'b0, "Test 42");
  tbassert(CP_bar == 1'b1, "Test 42");
  tbassert(CG_bar == 1'b1, "Test 42");
  // * Note: is an Equal comparison since C_in == 1
  tbassert(Equal == 1'b0, "Test 42");
#0
  // B > A (difference 23 - 28) -> Equal == 0, C_out == 1
  // (Domain 2)
  A_bar = 5'b10111;
  B_bar = 5'b11100;
  // C_in = 1'b1;
#10
  tbassert(F_bar == 5'b11010, "Test 43");
  tbassert(C_out == 1'b1, "Test 43");
  tbassert(CP_bar == 1'b1, "Test 43");
  tbassert(CG_bar == 1'b0, "Test 43");
  // * Note: is an Equal comparison since C_in == 1
  tbassert(Equal == 1'b0, "Test 43");
#45

  // the following set of tests show the underflow values at which CG_bar output becomes clear
  // (CP_bar output is not necessarily clear in this range so CG_bar takes priority)
  // (Domain 2)
  // (* using active-high data convention, the functionality of the two outputs aligns with
  //    the pin names: CP_bar is Carry Propagate and CG_bar is Carry Generate)

  // 13 - 14 - 1 + Carry 1 -> -1
  A_bar = 5'b01101;
  B_bar = 5'b01110;
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b11111, "Test 44");
  tbassert(C_out == 1'b1, "Test 44");
  tbassert(CP_bar == 1'b1, "Test 44");
  tbassert(CG_bar == 1'b0, "Test 44");
  // * Note: is not an Equal comparison since C_in == 0
  tbassert(Equal == 1'b1, "Test 44");
#0
  // 13 - 14 - 1 + Carry 0 -> -2
  // A_bar = 5'b01101;
  // B_bar = 5'b01110;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11110, "Test 45");
  tbassert(C_out == 1'b1, "Test 45");
  tbassert(CP_bar == 1'b1, "Test 45");
  tbassert(CG_bar == 1'b0, "Test 45");
  tbassert(Equal == 1'b0, "Test 45");
#0
  // 4 - 6 - 1 + Carry 1 -> -2
  A_bar = 5'b00100;
  B_bar = 5'b00110;
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b11110, "Test 46");
  tbassert(C_out == 1'b1, "Test 46");
  tbassert(CP_bar == 1'b0, "Test 46");
  tbassert(CG_bar == 1'b0, "Test 46");
  tbassert(Equal == 1'b0, "Test 46");
#0
  // 5 - 7 - 1 + Carry 0 -> -3
  A_bar = 5'b00101;
  B_bar = 5'b00111;
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11101, "Test 47");
  tbassert(C_out == 1'b1, "Test 47");
  tbassert(CP_bar == 1'b0, "Test 47");
  tbassert(CG_bar == 1'b0, "Test 47");
  tbassert(Equal == 1'b0, "Test 47");
#75

  // the following set of tests are for: arithmetic incorporating logic

  // Notes:
  //
  // 1. the Carry Propagate (CP_bar) and Carry Generate (CG_bar) output signal values are not
  //    of consequence for the following arithmetic incorporating logic operations; they do not
  //    have the values and semantics that they have for basic Add and Subtract;
  //    however, their values are demonstrated in some cases and without full coverage,
  //    in the interest of behavioural testing

  // the following set of tests are for: arithmetic incorporating logic: output dependent only on A

  // Notes:
  //
  // 1. these three functions are independent of active-high or active-low data choice

  // Mode = 1'b0;

  // reference test case (same as the larger list of repeated tests to follow)
  Select = 4'b0000;  // function: A PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10110 + 1'b1 == 5'b10111 (no Carry out)
  B_bar = 5'b00011;
  C_in = 1'b0;
#10
  tbassert(F_bar == 5'b10111, "Test 48");
  tbassert(C_out == 1'b1, "Test 48");
  tbassert(CP_bar == 1'b0, "Test 48");
  tbassert(CG_bar == 1'b0, "Test 48");
  // * Note: is not an Equal comparison since operation is not arithmetic: subtract
  tbassert(Equal == 1'b0, "Test 48");
#0
  // reference test case
  Select = 4'b1100;  // function: A PLUS A (SHIFT LEFT) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b01100 + 1'b1 == 5'b01101 (with Carry out)
  B_bar = 5'b00011;
  // C_in = 1'b0;
#10
  tbassert(F_bar == 5'b01101, "Test 49");
  tbassert(C_out == 1'b0, "Test 49");
  tbassert(CP_bar == 1'b1, "Test 49");
  tbassert(CG_bar == 1'b1, "Test 49");
  tbassert(Equal == 1'b0, "Test 49");
#0
  // reference test case
  Select = 4'b1111;  // function: A MINUS 1 PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10110 - 1'b1 + 1'b0 == 5'b10101 (with C_out == 0)
  B_bar = 5'b00011;  //                  (Domain 1: Subtract semantics for the Carry output)
  C_in = 1'b1;
#10
  tbassert(F_bar == 5'b10101, "Test 50");
  tbassert(C_out == 1'b0, "Test 50");
  tbassert(CP_bar == 1'b1, "Test 50");
  tbassert(CG_bar == 1'b1, "Test 50");
  tbassert(Equal == 1'b0, "Test 50");
#0

  // repeat tests: three Select input values

  for (i = 1; i <= 3; i++)
  begin
    case (i)
      1:
      begin
        Select = 4'b0000;  // function: A PLUS Carry
      end
      2:
      begin
        Select = 4'b1100;  // function: A PLUS A (SHIFT LEFT) PLUS Carry
      end
      3:
      begin
        Select = 4'b1111;  // function: A MINUS 1 PLUS Carry
      end
    endcase

    // repeat tests: A input takes a range of representative values

    for (j = 1; j <= 8; j++)
    begin
      case (j)
        1:
        begin
          A_bar = 5'b00001;
        end
        2:
        begin
          A_bar = 5'b00111;
        end
        3:
        begin
          A_bar = 5'b11001;
        end
        4:
        begin
          A_bar = 5'b11110;
        end
        5:
        begin
          A_bar = 5'b00000;
        end
        6:
        begin
          A_bar = 5'b11111;
        end
        7:
        begin
          A_bar = 5'b10101;
        end
        8:
        begin
          A_bar = 5'b01010;
        end
      endcase

      // repeat tests: all B input values

      for (k = 0; k <= 31; k++)
      begin
        B_bar = k;
        C_in = 1'b1;
#10
        case_tbassert2I(Select == 4'b0000, F_bar == A_bar + 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b0000, C_out == 1'b1, "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1100, F_bar == A_bar + A_bar + 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1100, C_out == ~A_bar[WIDTH - 1], "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1111, F_bar == A_bar - 1'b1 + 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1111 && (A_bar == 5'b00000), C_out == 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1111 && (A_bar != 5'b00000), C_out == 1'b0, "Test", j, (50 + i));

        // these tests are unaffected by the Carry input:
        case_tbassert2I(Select == 4'b0000, CP_bar == 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b0000 && (A_bar == 5'b11111), CG_bar == 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b0000 && (A_bar != 5'b11111), CG_bar == 1'b0, "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1100 && (A_bar == 5'b00000), CP_bar == 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1100 && (A_bar != 5'b00000), CP_bar == 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1100, CG_bar == A_bar[WIDTH - 1], "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1111 && (A_bar == 5'b00000), CP_bar == 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1111 && (A_bar != 5'b00000), CP_bar == 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1111, CG_bar == 1'b1, "Test", j, (50 + i));
#0
        C_in = 1'b0;
#10
        // these tests differ from above (affected by the Carry input):
        case_tbassert2I(Select == 4'b0000, F_bar == A_bar + 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b0000 && (A_bar == 5'b11111), C_out == 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b0000 && (A_bar != 5'b11111), C_out == 1'b1, "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1100, F_bar == A_bar + A_bar + 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1100, C_out == ~A_bar[WIDTH - 1], "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1111, F_bar == A_bar - 1'b1 + 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1111, C_out == 1'b0, "Test", j, (50 + i));

        // these tests are identical to above (unaffected by the Carry input):
        case_tbassert2I(Select == 4'b0000, CP_bar == 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b0000 && (A_bar == 5'b11111), CG_bar == 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b0000 && (A_bar != 5'b11111), CG_bar == 1'b0, "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1100 && (A_bar == 5'b00000), CP_bar == 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1100 && (A_bar != 5'b00000), CP_bar == 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1100, CG_bar == A_bar[WIDTH - 1], "Test", j, (50 + i));

        case_tbassert2I(Select == 4'b1111 && (A_bar == 5'b00000), CP_bar == 1'b0, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1111 && (A_bar != 5'b00000), CP_bar == 1'b1, "Test", j, (50 + i));
        case_tbassert2I(Select == 4'b1111, CG_bar == 1'b1, "Test", j, (50 + i));

      end

      // end repeat B input values

    end

    // end repeat A input values

  end

  // end repeat Select input values
#75

  // the following set of tests are for: arithmetic incorporating logic: output independent of A, B

  // Notes:
  //
  // 1. this function is independent of active-high or active-low data choice

  // Mode = 1'b0;

  Select = 4'b0011;  // function: MINUS 1 PLUS Carry

  // reference test case
  A_bar = 5'b10110;  // expected output: 5'b11111 + 1'b0 == 5'b11111 (with C_out == 1)
  B_bar = 5'b00011;  //                  (Domain 2: Subtract semantics for the Carry output)
  C_in = 1'b1;
#10
  tbassert(F_bar == 5'b11111, "Test 54");
  tbassert(C_out == 1'b1, "Test 54");
  tbassert(CP_bar == 1'b0, "Test 54");
  tbassert(CG_bar == 1'b1, "Test 54");
  // * Note: is not an Equal comparison since operation is not arithmetic: subtract
  // * Note: beyond this, the Equal output test will be skipped
  tbassert(Equal == 1'b1, "Test 54");
#0

  // repeat tests: Carry input is set then clear (meaning, respectively, no Carry then Carry)

  for (i = 1; i <= 2; i++)
  begin
    case (i)
      1:
      begin
        C_in = 1'b1;  // expected output: 5'b11111 + 1'b0 == 5'b11111 (with C_out == 1)
      end
      2:
      begin
        C_in = 1'b0;  // expected output: 5'b11111 + 1'b1 == 5'b00000 (with C_out == 0)
      end
    endcase

    // repeat tests: A, B inputs take a range of representative values

    for (j = 1; j <= 10; j++)
    begin
      case (j)
        1:
        begin
          A_bar = 5'b00001;
          B_bar = 5'b00001;
        end
        2:
        begin
          A_bar = 5'b00111;
          B_bar = 5'b00001;
        end
        3:
        begin
          A_bar = 5'b00000;
          B_bar = 5'b00001;
        end
        4:
        begin
          A_bar = 5'b11111;
          B_bar = 5'b00001;
        end
        5:
        begin
          A_bar = 5'b00000;
          B_bar = 5'b00000;
        end
        6:
        begin
          A_bar = 5'b11111;
          B_bar = 5'b11111;
        end
        7:
        begin
          A_bar = 5'b01010;
          B_bar = 5'b11100;
        end
        8:
        begin
          A_bar = 5'b01000;
          B_bar = 5'b11111;
        end
        9:
        begin
          A_bar = 5'b10111;
          B_bar = 5'b00000;
        end
        10:
        begin
          A_bar = 5'b11100;
          B_bar = 5'b11100;
        end
      endcase
#10
      case_tbassert2I(C_in == 1'b1, F_bar == 5'b11111, "Test", j, (54 + i));
      case_tbassert2I(C_in == 1'b0, F_bar == 5'b00000, "Test", j, (54 + i));
      case_tbassert2I(C_in == 1'b1, C_out == 1'b1, "Test", j, (54 + i));
      case_tbassert2I(C_in == 1'b0, C_out == 1'b0, "Test", j, (54 + i));

      // these tests are unaffected by the Carry input:
      tbassert2I(CP_bar == 1'b0, "Test", j, (54 + i));
      tbassert2I(CG_bar == 1'b1, "Test", j, (54 + i));

    end

    // end repeat A, B input values

  end

  // end repeat Carry input values
#75

  // the following set of tests are for: arithmetic incorporating logic: output dependent on A, B

  // Notes:
  //
  // 1. these ten functions are dependent on active-high data choice
  //    (see datasheet for the functions for active-low data)

  // Mode = 1'b0;

  // reference test case (same as the larger list of repeated tests to follow)
  Select = 4'b0001;  // function: A OR B PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10111 + 1'b1 == 5'b11000 (no Carry out)
  B_bar = 5'b00011;
  C_in = 1'b0;
#10
  tbassert(F_bar == 5'b11000, "Test 57");
  tbassert(C_out == 1'b1, "Test 57");
  tbassert(CP_bar == 1'b0, "Test 57");
  tbassert(CG_bar == 1'b0, "Test 57");
#0
  // reference test case
  Select = 4'b0010;  // function: A OR (NOT B) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b11110 + 1'b1 == 5'b11111 (no Carry out)
  B_bar = 5'b00011;
  // C_in = 1'b0;
#7
  tbassert(F_bar == 5'b11111, "Test 58");
  tbassert(C_out == 1'b1, "Test 58");
  tbassert(CP_bar == 1'b0, "Test 58");
  tbassert(CG_bar == 1'b0, "Test 58");
#0
  // reference test case
  Select = 4'b0100;  // function: A PLUS (A AND (NOT B)) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10110 + 5'b10100 + 1'b1 == 5'b01011 (with Carry out)
  B_bar = 5'b00011;
  // C_in = 1'b0;
#7
  tbassert(F_bar == 5'b01011, "Test 59");
  tbassert(C_out == 1'b0, "Test 59");
  tbassert(CP_bar == 1'b1, "Test 59");
  tbassert(CG_bar == 1'b1, "Test 59");
#0
  // reference test case
  Select = 4'b0101;  // function: (A OR B) PLUS (A AND (NOT B)) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10111 + 5'b10100 + 1'b1 == 5'b01100 (with Carry out)
  B_bar = 5'b00011;
  // C_in = 1'b0;
#7
  tbassert(F_bar == 5'b01100, "Test 60");
  tbassert(C_out == 1'b0, "Test 60");
  tbassert(CP_bar == 1'b1, "Test 60");
  tbassert(CG_bar == 1'b1, "Test 60");
#0
  // reference test case
  Select = 4'b0111;  // function: (A AND (NOT B)) MINUS 1 PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10100 - 1'b1 + 1'b0 == 5'b10011 (with C_out == 0)
  B_bar = 5'b00011;  //                  (Domain 1: Subtract semantics for the Carry output)
  C_in = 1'b1;
#7
  tbassert(F_bar == 5'b10011, "Test 61");
  tbassert(C_out == 1'b0, "Test 61");
  tbassert(CP_bar == 1'b1, "Test 61");
  tbassert(CG_bar == 1'b1, "Test 61");
#0
  // reference test case
  Select = 4'b1000;  // function: A PLUS (A AND B) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10110 + 5'b00010 + 1'b0 == 5'b11000 (no Carry out)
  B_bar = 5'b00011;
  // C_in = 1'b1;
#7
  tbassert(F_bar == 5'b11000, "Test 62");
  tbassert(C_out == 1'b1, "Test 62");
  tbassert(CP_bar == 1'b1, "Test 62");
  tbassert(CG_bar == 1'b0, "Test 62");
#0
  // reference test case
  Select = 4'b1010;  // function: (A OR (NOT B)) PLUS (A AND B) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b11110 + 5'b00010 + 1'b0 == 5'b00000 (with Carry out)
  B_bar = 5'b00011;
  // C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00000, "Test 63");
  tbassert(C_out == 1'b0, "Test 63");
  tbassert(CP_bar == 1'b1, "Test 63");
  tbassert(CG_bar == 1'b1, "Test 63");
#0
  // reference test case
  Select = 4'b1011;  // function: (A AND B) MINUS 1 PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b00010 - 1'b1 + 1'b0 == 5'b00001 (with C_out == 0)
  B_bar = 5'b00011;  //                  (Domain 1: Subtract semantics for the Carry output)
  // C_in = 1'b1;
#7
  tbassert(F_bar == 5'b00001, "Test 64");
  tbassert(C_out == 1'b0, "Test 64");
  tbassert(CP_bar == 1'b1, "Test 64");
  tbassert(CG_bar == 1'b1, "Test 64");
#0
  // reference test case
  Select = 4'b1101;  // function: A PLUS (A OR B) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10110 + 5'b10111 + 1'b1 == 5'b01110 (with Carry out)
  B_bar = 5'b00011;
  C_in = 1'b0;
#7
  tbassert(F_bar == 5'b01110, "Test 65");
  tbassert(C_out == 1'b0, "Test 65");
  tbassert(CP_bar == 1'b1, "Test 65");
  tbassert(CG_bar == 1'b1, "Test 65");
#0
  // reference test case
  Select = 4'b1110;  // function: A PLUS (A OR (NOT B)) PLUS Carry
  A_bar = 5'b10110;  // expected output: 5'b10110 + 5'b11110 + 1'b1 == 5'b10101 (with Carry out)
  B_bar = 5'b00011;
  // C_in = 1'b0;
#7
  tbassert(F_bar == 5'b10101, "Test 66");
  tbassert(C_out == 1'b0, "Test 66");
  tbassert(CP_bar == 1'b1, "Test 66");
  tbassert(CG_bar == 1'b1, "Test 66");
#0

  // repeat tests: ten Select input values in binary complementary pairs
  //               (* this completes the set of 16 Select input values for 16 arithmetic operations)

  for (i = 1; i <= 10; i++)
  begin
    case (i)
      1:
      begin
        Select = 4'b0001;  // function: A OR B PLUS Carry
      end
      2:
      begin
        Select = 4'b0010;  // function: A OR (NOT B) PLUS Carry
      end
      3:
      begin
        Select = 4'b0100;  // function: A PLUS (A AND (NOT B)) PLUS Carry
      end
      4:
      begin
        Select = 4'b0101;  // function: (A OR B) PLUS (A AND (NOT B)) PLUS Carry
      end
      5:
      begin
        Select = 4'b0111;  // function: (A AND (NOT B)) MINUS 1 PLUS Carry
      end
      6:
      begin
        Select = 4'b1000;  // function: A PLUS (A AND B) PLUS Carry
      end
      7:
      begin
        Select = 4'b1010;  // function: (A OR (NOT B)) PLUS (A AND B) PLUS Carry
      end
      8:
      begin
        Select = 4'b1011;  // function: (A AND B) MINUS 1 PLUS Carry
      end
      9:
      begin
        Select = 4'b1101;  // function: A PLUS (A OR B) PLUS Carry
      end
      10:
      begin
        Select = 4'b1110;  // function: A PLUS (A OR (NOT B)) PLUS Carry
      end
    endcase

    // repeat tests: all A input values

    for (j = 0; j <= 31; j++)
    begin
      A_bar = j;

      // repeat tests: all B input values

      for (k = 0; k <= 31; k++)
      begin
        B_bar = k;
        C_in = 1'b1;
#10
        case_tbassert2I(Select == 4'b0001, F_bar == (A_bar | B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0001, C_out == 1'b1, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0010, F_bar == (A_bar | ~B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0010, C_out == 1'b1, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0100, F_bar == A_bar + (A_bar & ~B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b0101, F_bar == (A_bar | B_bar) + (A_bar & ~B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b0111, F_bar == (A_bar & ~B_bar) - 1'b1 + 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0111 && ((A_bar & ~B_bar) - 1'b1 == 5'b11111), C_out == 1'b1, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0111 && ((A_bar & ~B_bar) - 1'b1 != 5'b11111), C_out == 1'b0, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b1000, F_bar == A_bar + (A_bar & B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b1010, F_bar == (A_bar | ~B_bar) + (A_bar & B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b1011, F_bar == (A_bar & B_bar) - 1'b1 + 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b1011 && ((A_bar & B_bar) - 1'b1 == 5'b11111), C_out == 1'b1, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b1011 && ((A_bar & B_bar) - 1'b1 != 5'b11111), C_out == 1'b0, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b1101, F_bar == A_bar + (A_bar | B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b1110, F_bar == A_bar + (A_bar | ~B_bar) + 1'b0, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        // these tests are unaffected by the Carry input:
        case_tbassert2I(Select == 4'b0001, CP_bar == 1'b0, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0010, CP_bar == 1'b0, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0111 && ((A_bar & ~B_bar) - 1'b1 == 5'b11111), CP_bar == 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0111 && ((A_bar & ~B_bar) - 1'b1 != 5'b11111), CP_bar == 1'b1, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b1011 && ((A_bar & B_bar) - 1'b1 == 5'b11111), CP_bar == 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b1011 && ((A_bar & B_bar) - 1'b1 != 5'b11111), CP_bar == 1'b1, "Test", (1 + j), (66 + i));
#0
        C_in = 1'b0;
#10
        // these tests differ from above (affected by the Carry input):
        case_tbassert2I(Select == 4'b0001, F_bar == (A_bar | B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0001 && ((A_bar | B_bar) == 5'b11111), C_out == 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0001 && ((A_bar | B_bar) != 5'b11111), C_out == 1'b1, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0010, F_bar == (A_bar | ~B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0010 && ((A_bar | ~B_bar) == 5'b11111), C_out == 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0010 && ((A_bar | ~B_bar) != 5'b11111), C_out == 1'b1, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0100, F_bar == A_bar + (A_bar & ~B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b0101, F_bar == (A_bar | B_bar) + (A_bar & ~B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b0111, F_bar == (A_bar & ~B_bar) - 1'b1 + 1'b1, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0111 && ((A_bar & ~B_bar) != 5'b11111), C_out == 1'b0, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b1000, F_bar == A_bar + (A_bar & B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b1010, F_bar == (A_bar | ~B_bar) + (A_bar & B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b1011, F_bar == (A_bar & B_bar) - 1'b1 + 1'b1, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b1011, C_out == 1'b0, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b1101, F_bar == A_bar + (A_bar | B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        case_tbassert2I(Select == 4'b1110, F_bar == A_bar + (A_bar | ~B_bar) + 1'b1, "Test", (1 + j), (66 + i));
        // tests are left out: Carry output is dependent on the data

        // these tests are identical to above (unaffected by the Carry input):
        case_tbassert2I(Select == 4'b0001, CP_bar == 1'b0, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0010, CP_bar == 1'b0, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b0111 && ((A_bar & ~B_bar) - 1'b1 == 5'b11111), CP_bar == 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b0111 && ((A_bar & ~B_bar) - 1'b1 != 5'b11111), CP_bar == 1'b1, "Test", (1 + j), (66 + i));

        case_tbassert2I(Select == 4'b1011 && ((A_bar & B_bar) - 1'b1 == 5'b11111), CP_bar == 1'b0, "Test", (1 + j), (66 + i));
        case_tbassert2I(Select == 4'b1011 && ((A_bar & B_bar) - 1'b1 != 5'b11111), CP_bar == 1'b1, "Test", (1 + j), (66 + i));

      end

      // end repeat B input values

    end

    // end repeat A input values

  end

  // end repeat Select input values
#75

  // the following set of tests are for: logic

  // Notes:
  //
  // 1. the Carry, Carry Propagate (CP_bar) and Carry Generate (CG_bar) output signal values are not
  //    of consequence for the logic operations;
  //    however, the Carry output value is demonstrated in some cases and without full coverage,
  //    in the interest of behavioural testing
  //
  // 2. the Carry input has no effect on logic operations; this is demonstrated in these tests

  Mode = 1'b1;

  // the following set of tests are for: logic: output dependent only on A

  // Notes:
  //
  // 1. these two functions are independent of active-high or active-low data choice

  // reference test case (same as the larger list of repeated tests to follow)
  Select = 4'b0000;  // function: NOT A
  A_bar = 5'b10110;  // expected output: 5'b01001
  B_bar = 5'b00011;
  C_in = 1'b1;
#10
  tbassert(F_bar == 5'b01001, "Test 77");
  tbassert(C_out == 1'b1, "Test 77");
#0

  // repeat tests: two complementary Select input values

  for (i = 1; i <= 2; i++)
  begin
    case (i)
      1:
      begin
        Select = 4'b0000;  // function: NOT A
      end
      2:
      begin
        Select = 4'b1111;  // function: A
      end
    endcase

    // repeat tests: A input takes a range of representative values

    for (j = 1; j <= 8; j++)
    begin
      case (j)
        1:
        begin
          A_bar = 5'b00001;
        end
        2:
        begin
          A_bar = 5'b00111;
        end
        3:
        begin
          A_bar = 5'b11001;
        end
        4:
        begin
          A_bar = 5'b11110;
        end
        5:
        begin
          A_bar = 5'b00000;
        end
        6:
        begin
          A_bar = 5'b11111;
        end
        7:
        begin
          A_bar = 5'b10101;
        end
        8:
        begin
          A_bar = 5'b01010;
        end
      endcase

      // repeat tests: all B input values

      for (k = 0; k <= 31; k++)
      begin
        B_bar = k;
        C_in = 1'b0;
#7
        case_tbassert2I(Select == 4'b0000, F_bar == ~A_bar, "Test", j, (77 + i));
        case_tbassert2I(Select == 4'b0000 && (~A_bar != 5'b00000), C_out == 1'b1, "Test", j, (77 + i));
        case_tbassert2I(Select == 4'b0000 && (~A_bar == 5'b00000), C_out == C_in, "Test", j, (77 + i));

        case_tbassert2I(Select == 4'b1111, F_bar == A_bar, "Test", j, (77 + i));
        case_tbassert2I(Select == 4'b1111 && (A_bar != 5'b00000), C_out == 1'b0, "Test", j, (77 + i));
        case_tbassert2I(Select == 4'b1111 && (A_bar == 5'b00000), C_out == C_in, "Test", j, (77 + i));
#0
        C_in = 1'b1;
#7
        // these tests are identical to above (unaffected by the Carry input):
        case_tbassert2I(Select == 4'b0000, F_bar == ~A_bar, "Test", j, (77 + i));
        case_tbassert2I(Select == 4'b0000 && (~A_bar != 5'b00000), C_out == 1'b1, "Test", j, (77 + i));

        case_tbassert2I(Select == 4'b1111, F_bar == A_bar, "Test", j, (77 + i));
        case_tbassert2I(Select == 4'b1111 && (A_bar != 5'b00000), C_out == 1'b0, "Test", j, (77 + i));

        // these tests differ from above (affected by the Carry input):
        // * Note: beyond this, tests for Carry output will be skipped
        case_tbassert2I(Select == 4'b0000 && (~A_bar == 5'b00000), C_out == C_in, "Test", j, (77 + i));

        case_tbassert2I(Select == 4'b1111 && (A_bar == 5'b00000), C_out == C_in, "Test", j, (77 + i));

      end

      // end repeat B input values

    end

    // end repeat A input values

  end

  // end repeat Select input values
#75

  // the following set of tests are for: logic: output dependent only on B

  // Notes:
  //
  // 1. these two functions are independent of active-high or active-low data choice

  // Mode = 1'b1;

  // repeat tests: two complementary Select input values

  for (i = 1; i <= 2; i++)
  begin
    case (i)
      1:
      begin
        Select = 4'b0101;  // function: NOT B
      end
      2:
      begin
        Select = 4'b1010;  // function: B
      end
    endcase

    // repeat tests: B input takes a range of representative values

    for (j = 1; j <= 8; j++)
    begin
      case (j)
        1:
        begin
          B_bar = 5'b00001;
        end
        2:
        begin
          B_bar = 5'b00111;
        end
        3:
        begin
          B_bar = 5'b11001;
        end
        4:
        begin
          B_bar = 5'b11110;
        end
        5:
        begin
          B_bar = 5'b00000;
        end
        6:
        begin
          B_bar = 5'b11111;
        end
        7:
        begin
          B_bar = 5'b01010;
        end
        8:
        begin
          B_bar = 5'b10101;
        end
      endcase

      // repeat tests: all A input values

      for (k = 0; k <= 31; k++)
      begin
        A_bar = k;
        C_in = 1'b0;
#7
        case_tbassert2I(Select == 4'b0101, F_bar == ~B_bar, "Test", j, (79 + i));

        case_tbassert2I(Select == 4'b1010, F_bar == B_bar, "Test", j, (79 + i));
#0
        C_in = 1'b1;
#7
        // these tests are identical to above (unaffected by the Carry input):
        case_tbassert2I(Select == 4'b0101, F_bar == ~B_bar, "Test", j, (79 + i));

        case_tbassert2I(Select == 4'b1010, F_bar == B_bar, "Test", j, (79 + i));

      end

      // end repeat A input values

    end

    // end repeat B input values

  end

  // end repeat Select input values
#75

  // the following set of tests are for: logic: output independent of A, B

  // Notes:
  //
  // 1. these two functions are dependent on active-high data choice

  // Mode = 1'b1;

  // repeat tests: two complementary Select input values

  for (i = 1; i <= 2; i++)
  begin
    case (i)
      1:
      begin
        Select = 4'b0011;  // function: 0
      end
      2:
      begin
        Select = 4'b1100;  // function: 1
      end
    endcase

    // repeat tests: A, B inputs take a range of values

    for (j = 1; j <= 11; j++)
    begin
      case (j)
        1:
        begin
          A_bar = 5'b00001;
          B_bar = 5'b00001;
        end
        2:
        begin
          A_bar = 5'b00111;
          B_bar = 5'b00001;
        end
        3:
        begin
          A_bar = 5'b11110;
          B_bar = 5'b00001;
        end
        4:
        begin
          A_bar = 5'b10101;
          B_bar = 5'b00001;
        end
        5:
        begin
          A_bar = 5'b00000;
          B_bar = 5'b00000;
        end
        6:
        begin
          A_bar = 5'b11111;
          B_bar = 5'b11111;
        end
        7:
        begin
          A_bar = 5'b00001;
          B_bar = 5'b10000;
        end
        8:
        begin
          A_bar = 5'b11111;
          B_bar = 5'b11000;
        end
        9:
        begin
          A_bar = 5'b01000;
          B_bar = 5'b11111;
        end
        10:
        begin
          A_bar = 5'b10111;
          B_bar = 5'b00000;
        end
        11:
        begin
          A_bar = 5'b11101;
          B_bar = 5'b11101;
        end
      endcase

      C_in = 1'b0;
#7
      case_tbassert2I(Select == 4'b0011, F_bar == 5'b00000, "Test", j, (81 + i));

      case_tbassert2I(Select == 4'b1100, F_bar == 5'b11111, "Test", j, (81 + i));
#0
      C_in = 1'b1;
#7
      // these tests are identical to above (unaffected by the Carry input):
      case_tbassert2I(Select == 4'b0011, F_bar == 5'b00000, "Test", j, (81 + i));

      case_tbassert2I(Select == 4'b1100, F_bar == 5'b11111, "Test", j, (81 + i));

    end

    // end repeat A, B input values

  end

  // end repeat Select input values
#75

  // the following set of tests are for: logic: output dependent on A, B

  // Notes:
  //
  // 1. these ten functions are dependent on active-high data choice
  //    (see tests below, under "the use of active-low data convention",
  //    that show the functions for active-low data)

  // Mode = 1'b1;

  // repeat tests: ten Select input values in binary complementary pairs
  //               (* this completes the set of 16 Select input values for 16 logic operations)

  for (i = 1; i <= 10; i++)
  begin
    case (i)
      1:
      begin
        Select = 4'b0001;  // function: NOT (A OR B)
      end
      2:
      begin
        Select = 4'b0010;  // function: (NOT A) AND B == NOT (A OR (NOT B)) by DeMorgan's rule
      end
      3:
      begin
        Select = 4'b0100;  // function: NOT (A AND B)
      end
      4:
      begin
        Select = 4'b0110;  // function: A XOR B
      end
      5:
      begin
        Select = 4'b0111;  // function: A AND (NOT B) == NOT ((NOT A) OR B) by DeMorgan's rule
      end
      6:
      begin
        Select = 4'b1000;  // function: (NOT A) OR B
      end
      7:
      begin
        Select = 4'b1001;  // function: NOT (A XOR B)
      end
      8:
      begin
        Select = 4'b1011;  // function: A AND B
      end
      9:
      begin
        Select = 4'b1101;  // function: A OR (NOT B)
      end
      10:
      begin
        Select = 4'b1110;  // function: A OR B
      end
    endcase

    // repeat tests: all A input values

    for (j = 0; j <= 31; j++)
    begin
      A_bar = j;

      // repeat tests: all B input values

      for (k = 0; k <= 31; k++)
      begin
        B_bar = k;
        C_in = 1'b0;
#10
        case_tbassert2I(Select == 4'b0001, F_bar == ~(A_bar | B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0010, F_bar == (~A_bar & B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0100, F_bar == ~(A_bar & B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0110, F_bar ==  (A_bar ^ B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0111, F_bar == (A_bar & ~B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1000, F_bar == (~A_bar | B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1001, F_bar == ~(A_bar ^ B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1011, F_bar ==  (A_bar & B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1101, F_bar == (A_bar | ~B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1110, F_bar ==  (A_bar | B_bar), "Test", (1 + j), (83 + i));
#0
        C_in = 1'b1;
#10
        // these tests are identical to above (unaffected by the Carry input):
        case_tbassert2I(Select == 4'b0001, F_bar == ~(A_bar | B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0010, F_bar == (~A_bar & B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0100, F_bar == ~(A_bar & B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0110, F_bar ==  (A_bar ^ B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b0111, F_bar == (A_bar & ~B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1000, F_bar == (~A_bar | B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1001, F_bar == ~(A_bar ^ B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1011, F_bar ==  (A_bar & B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1101, F_bar == (A_bar | ~B_bar), "Test", (1 + j), (83 + i));

        case_tbassert2I(Select == 4'b1110, F_bar ==  (A_bar | B_bar), "Test", (1 + j), (83 + i));

      end

      // end repeat B input values

    end

    // end repeat A input values

  end

  // end repeat Select input values
#75

  // the following set of tests show the use of active-low data convention
  // for arithmetic Add and Subtract and some logic operations

  // the following set of tests are for: arithmetic: add

  // Notes:
  //
  // 1. this function is independent of active-high or active-low data choice; the behaviour
  //    is identical when the represented numbers are identical but all bits are inverted

  Mode = 1'b0;

  Select = 4'b1001;

  // repeat tests: Carry input values

  for (i = 1; i <= 2; i++)
  begin
    case (i)
      1:
      begin
        C_in = 1'b1;
      end
      2:
      begin
        C_in = 1'b0;
      end
    endcase

    // repeat tests: A input takes a range of representative values

    for (j = 1; j <= 8; j++)
    begin
      case (j)
        1:
        begin
          A_bar = 5'b00001;
        end
        2:
        begin
          A_bar = 5'b00111;
        end
        3:
        begin
          A_bar = 5'b11001;
        end
        4:
        begin
          A_bar = 5'b11110;
        end
        5:
        begin
          A_bar = 5'b00000;
        end
        6:
        begin
          A_bar = 5'b11111;
        end
        7:
        begin
          A_bar = 5'b10101;
        end
        8:
        begin
          A_bar = 5'b01010;
        end
      endcase

      // repeat tests: all B input values

      for (k = 0; k <= 31; k++)
      begin
        B_bar = k;

        A_value = ~A_bar;
        B_value = ~B_bar;
        C_in_value = C_in;  // remove the inversion of the Carry for use in mathematical statement
#10
        F_value = ~F_bar;
        C_out_value = C_out;  //  "  "

        tbassert2I({C_out_value, F_value} == {1'b0, A_value} + {1'b0, B_value} + C_in_value, "Test", j, (93 + i));

      end

      // end repeat B input values

    end

    // end repeat A input values

  end

  // end repeat Carry input values
#45

  // the following set of tests are for: arithmetic: subtract

  // Notes:
  //
  // 1. this function is independent of active-high or active-low data choice; the behaviour
  //    is identical when the represented numbers are identical but all bits are inverted

  // Mode = 1'b0;

  Select = 4'b0110;

  // repeat tests: Carry input values

  for (i = 1; i <= 2; i++)
  begin
    case (i)
      1:
      begin
        C_in = 1'b1;
      end
      2:
      begin
        C_in = 1'b0;
      end
    endcase

    // repeat tests: A input takes a range of representative values

    for (j = 1; j <= 8; j++)
    begin
      case (j)
        1:
        begin
          A_bar = 5'b00001;
        end
        2:
        begin
          A_bar = 5'b00111;
        end
        3:
        begin
          A_bar = 5'b11001;
        end
        4:
        begin
          A_bar = 5'b11110;
        end
        5:
        begin
          A_bar = 5'b00000;
        end
        6:
        begin
          A_bar = 5'b11111;
        end
        7:
        begin
          A_bar = 5'b10101;
        end
        8:
        begin
          A_bar = 5'b01010;
        end
      endcase

      // repeat tests: all B input values

      for (k = 0; k <= 31; k++)
      begin
        B_bar = k;

        A_value = ~A_bar;
        B_value = ~B_bar;
        C_in_value = C_in;  // remove the inversion of the Carry for use in mathematical statement
#10
        F_value = ~F_bar;
        C_out_value = C_out;  //  "  "

        tbassert2I({C_out_value, F_value} == {1'b0, A_value} - {1'b0, B_value} + {WIDTH{1'b1}} + C_in_value, "Test", j, (95 + i));

      end

      // end repeat B input values

    end

    // end repeat A input values

  end

  // end repeat Carry input values
#45

  // the following set of tests are for: logic: output dependent on A, B

  // Notes:
  //
  // 1. these ten functions are dependent on active-low data choice; they are different from
  //    the functions seen above for active-high data (see datasheet)

  Mode = 1'b1;

  // repeat tests: ten Select input values in binary complementary pairs

  for (i = 1; i <= 10; i++)
  begin
    case (i)
      1:
      begin
        Select = 4'b0001;  // function: NOT (A AND B)
      end
      2:
      begin
        Select = 4'b0010;  // function: (NOT A) OR B
      end
      3:
      begin
        Select = 4'b0100;  // function: NOT (A OR B)
      end
      4:
      begin
        Select = 4'b0110;  // function: NOT (A XOR B)
      end
      5:
      begin
        Select = 4'b0111;  // function: A OR (NOT B)
      end
      6:
      begin
        Select = 4'b1000;  // function: (NOT A) AND B == NOT (A OR (NOT B)) by DeMorgan's rule
      end
      7:
      begin
        Select = 4'b1001;  // function: A XOR B
      end
      8:
      begin
        Select = 4'b1011;  // function: A OR B
      end
      9:
      begin
        Select = 4'b1101;  // function: A AND (NOT B) == NOT ((NOT A) OR B) by DeMorgan's rule
      end
      10:
      begin
        Select = 4'b1110;  // function: A AND B
      end
    endcase

    // repeat tests: A, B inputs take a range of representative values

    for (j = 1; j <= 18; j++)
    begin
      case (j)
        1:
        begin
          A_bar = 5'b00001;
          B_bar = 5'b00001;
        end
        2:
        begin
          A_bar = 5'b00111;
          B_bar = 5'b00001;
        end
        3:
        begin
          A_bar = 5'b11001;
          B_bar = 5'b00001;
        end
        4:
        begin
          A_bar = 5'b11110;
          B_bar = 5'b00001;
        end
        5:
        begin
          A_bar = 5'b00000;
          B_bar = 5'b00001;
        end
        6:
        begin
          A_bar = 5'b11111;
          B_bar = 5'b00001;
        end
        7:
        begin
          A_bar = 5'b10101;
          B_bar = 5'b00001;
        end
        8:
        begin
          A_bar = 5'b01010;
          B_bar = 5'b00001;
        end
        9:
        begin
          A_bar = 5'b00000;
          B_bar = 5'b00000;
        end
        10:
        begin
          A_bar = 5'b11111;
          B_bar = 5'b11111;
        end
        11:
        begin
          A_bar = 5'b00001;
          B_bar = 5'b10000;
        end
        12:
        begin
          A_bar = 5'b00111;
          B_bar = 5'b11110;
        end
        13:
        begin
          A_bar = 5'b11110;
          B_bar = 5'b10000;
        end
        14:
        begin
          A_bar = 5'b01010;
          B_bar = 5'b11100;
        end
        15:
        begin
          A_bar = 5'b01000;
          B_bar = 5'b11111;
        end
        16:
        begin
          A_bar = 5'b10111;
          B_bar = 5'b00000;
        end
        17:
        begin
          A_bar = 5'b11100;
          B_bar = 5'b11100;
        end
        18:
        begin
          A_bar = 5'b11011;
          B_bar = 5'b11011;
        end
      endcase

      A_value = ~A_bar;
      B_value = ~B_bar;
#10
      F_value = ~F_bar;

      case_tbassert2I(Select == 4'b0001, F_value == ~(A_value & B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b0010, F_value == (~A_value | B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b0100, F_value == ~(A_value | B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b0110, F_value == ~(A_value ^ B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b0111, F_value == (A_value | ~B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b1000, F_value == (~A_value & B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b1001, F_value ==  (A_value ^ B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b1011, F_value ==  (A_value | B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b1101, F_value == (A_value & ~B_value), "Test", j, (97 + i));

      case_tbassert2I(Select == 4'b1110, F_value ==  (A_value & B_value), "Test", j, (97 + i));

    end

    // end repeat A, B input values

  end

  // end repeat Select input values
#10
  $finish;
end

endmodule
