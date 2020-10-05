// 4-bit arithmetic logic unit

// Notes:
//
// - can be used with active-high or active-low data convention (see datasheet);
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
// * refer to test bench file 74181-tb.v that comes with your 74181 device for notes
//   and functional specs, before you attempt to create a fully working circuit

module ttl_74181 #(parameter WIDTH = 4, DELAY_RISE = 0, DELAY_FALL = 0)
(
  input [3:0] Select,
  input Mode,
  input C_in,
  input [WIDTH-1:0] A_bar,
  input [WIDTH-1:0] B_bar,
  output CP_bar,
  output CG_bar,
  output Equal,
  output C_out,
  output [WIDTH-1:0] F_bar
);

//------------------------------------------------//
reg CP_computed;
reg CG_computed;
wire Equal_computed;
reg C_in_bar;
reg C_computed_bar;
reg C_computed;
reg [WIDTH-1:0] F_computed;
wire [WIDTH-1:0] P_internal;
wire [WIDTH-1:0] G_internal;
wire [WIDTH-1:0] CG_internal;

generate
  genvar i;
  for (i = 0; i < WIDTH; i = i + 1)
  begin: gen_internals
    // first layer: internal propagate and generate signals from each A, B bit pair
    //              used for carry output C (in the logic section), and used for
    //              carry lookahead outputs CP and CG
    //
    assign P_internal[i] = ~(A_bar[i] & ~B_bar[i] & Select[2] | A_bar[i] & B_bar[i] & Select[3]);
    assign G_internal[i] = ~(A_bar[i] | B_bar[i] & Select[0] | ~B_bar[i] & Select[1]);

    // second layer: internal carry generate signals from the propagate and generate signals,
    //               used for carry lookahead output CG
    //
    // the generated code has this structure (terms are then joined by |):
    // CG_internal[0] = P_internal[1] & P_internal[2] & P_internal[3] & G_internal[0];
    // CG_internal[1] =                 P_internal[2] & P_internal[3] & G_internal[1];
    // CG_internal[2] =                                 P_internal[3] & G_internal[2];
    // CG_internal[3] =                                                 G_internal[3];
    //
    if (i < WIDTH - 1)
    begin
      assign CG_internal[i] = (&P_internal[(WIDTH - 1):(i + 1)]) & G_internal[i];
    end
    else
    begin
      assign CG_internal[i] = G_internal[i];
    end
  end
endgenerate

always @(*)
begin
  if (!Mode)
  begin
    // arithmetic

    C_in_bar = ~C_in;

    // add (A PLUS B PLUS Carry)
    if (Select == 4'b1001)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} + {1'b0, B_bar} + C_in_bar;
    end

    // subtract (A MINUS B MINUS 1 PLUS Carry)
    if (Select == 4'b0110)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} - {1'b0, B_bar} + {WIDTH{1'b1}} + C_in_bar;
    end

    // other arithmetic incorporating logic

    // A PLUS Carry
    if (Select == 4'b0000)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} + C_in_bar;
    end

    // A OR B PLUS Carry
    if (Select == 4'b0001)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar | B_bar} + C_in_bar;
    end

    // A OR (NOT B) PLUS Carry
    if (Select == 4'b0010)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar | ~B_bar} + C_in_bar;
    end

    // MINUS 1 PLUS Carry
    if (Select == 4'b0011)
    begin
      {C_computed_bar, F_computed} = {WIDTH{1'b1}} + C_in_bar;
    end

    // A PLUS (A AND (NOT B)) PLUS Carry
    if (Select == 4'b0100)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} + {1'b0, A_bar & ~B_bar} + C_in_bar;
    end

    // (A OR B) PLUS (A AND (NOT B)) PLUS Carry
    if (Select == 4'b0101)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar | B_bar} + {1'b0, A_bar & ~B_bar} + C_in_bar;
    end

    // (A AND (NOT B)) MINUS 1 PLUS Carry
    if (Select == 4'b0111)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar & ~B_bar} + {WIDTH{1'b1}} + C_in_bar;
    end

    // A PLUS (A AND B) PLUS Carry
    if (Select == 4'b1000)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} + {1'b0, A_bar & B_bar} + C_in_bar;
    end

    // (A OR (NOT B)) PLUS (A AND B) PLUS Carry
    if (Select == 4'b1010)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar | ~B_bar} + {1'b0, A_bar & B_bar} + C_in_bar;
    end

    // (A AND B) MINUS 1 PLUS Carry
    if (Select == 4'b1011)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar & B_bar} + {WIDTH{1'b1}} + C_in_bar;
    end

    // A PLUS A (SHIFT LEFT) PLUS Carry
    if (Select == 4'b1100)
    begin: sum_block
      reg [WIDTH:0] extra_width_sum;

      extra_width_sum = A_bar << 1;

      {C_computed_bar, F_computed} = extra_width_sum + C_in_bar;
    end

    // A PLUS (A OR B) PLUS Carry
    if (Select == 4'b1101)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} + {1'b0, A_bar | B_bar} + C_in_bar;
    end

    // A PLUS (A OR (NOT B)) PLUS Carry
    if (Select == 4'b1110)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} + {1'b0, A_bar | ~B_bar} + C_in_bar;
    end

    // A MINUS 1 PLUS Carry
    if (Select == 4'b1111)
    begin
      {C_computed_bar, F_computed} = {1'b0, A_bar} + {WIDTH{1'b1}} + C_in_bar;
    end

    C_computed = ~C_computed_bar;
  end
  else
  begin
    // logic

    // NOT A
    if (Select == 4'b0000)
    begin
      F_computed = ~A_bar;
    end

    // NOT (A OR B)
    if (Select == 4'b0001)
    begin
      F_computed = ~(A_bar | B_bar);
    end

    // (NOT A) AND B
    if (Select == 4'b0010)
    begin
      F_computed = ~A_bar & B_bar;
    end

    // 0
    if (Select == 4'b0011)
    begin
      F_computed = {WIDTH{1'b0}};
    end

    // NOT (A AND B)
    if (Select == 4'b0100)
    begin
      F_computed = ~(A_bar & B_bar);
    end

    // NOT B
    if (Select == 4'b0101)
    begin
      F_computed = ~B_bar;
    end

    // A XOR B
    if (Select == 4'b0110)
    begin
      F_computed = A_bar ^ B_bar;
    end

    // A AND (NOT B)
    if (Select == 4'b0111)
    begin
      F_computed = A_bar & ~B_bar;
    end

    // (NOT A) OR B
    if (Select == 4'b1000)
    begin
      F_computed = ~A_bar | B_bar;
    end

    // NOT (A XOR B)
    if (Select == 4'b1001)
    begin
      F_computed = ~(A_bar ^ B_bar);
    end

    // B
    if (Select == 4'b1010)
    begin
      F_computed = B_bar;
    end

    // A AND B
    if (Select == 4'b1011)
    begin
      F_computed = A_bar & B_bar;
    end

    // 1
    if (Select == 4'b1100)
    begin
      F_computed = {WIDTH{1'b1}};
    end

    // A OR (NOT B)
    if (Select == 4'b1101)
    begin
      F_computed = A_bar | ~B_bar;
    end

    // A OR B
    if (Select == 4'b1110)
    begin
      F_computed = A_bar | B_bar;
    end

    // A
    if (Select == 4'b1111)
    begin
      F_computed = A_bar;
    end

    // third layer: carry bit
    C_computed = C_in & (&P_internal) | (|CG_internal);
  end

  // third layer: carry lookahead bits aggregated from the above terms
  CP_computed = ~(&P_internal);
  CG_computed = ~(|CG_internal);
end

// output
assign Equal_computed = &F_computed;

//------------------------------------------------//

assign #(DELAY_RISE, DELAY_FALL) CP_bar = CP_computed;
assign #(DELAY_RISE, DELAY_FALL) CG_bar = CG_computed;
assign #(DELAY_RISE, DELAY_FALL) Equal = Equal_computed;
assign #(DELAY_RISE, DELAY_FALL) C_out = C_computed;
assign #(DELAY_RISE, DELAY_FALL) F_bar = F_computed;

endmodule
