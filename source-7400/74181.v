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
reg C_computed;
reg [WIDTH-1:0] F_computed;
wire [WIDTH-1:0] P_internal;
wire [WIDTH-1:0] G_internal;
wire [WIDTH-1:0] C_internal;
wire [WIDTH-1:0] CG_internal;

// structural declaration using gates and wires (see datasheet for the schematic):

generate
  genvar i;
  for (i = 0; i < WIDTH; i = i + 1)
  begin: gen_internals
    wire [WIDTH-1:0] C_and_P_term;
    wire [WIDTH-1:0] P_and_G_term;
    wire [WIDTH-1:0] G_term;

    // first layer: internal propagate and generate signals from each A, B bit pair
    //              used for all further computations (function output F, carry output C,
    //              carry lookahead outputs CP and CG)
    //
    assign P_internal[i] = ~(A_bar[i] & ~B_bar[i] & Select[2] | A_bar[i] & B_bar[i] & Select[3]);
    assign G_internal[i] = ~(A_bar[i] | B_bar[i] & Select[0] | ~B_bar[i] & Select[1]);

    // second layer: internal carry signals from the carry in and propagate and generate signals,
    //               used for computation of F bits (these are for arithmetic functions only;
    //               for logic functions the Mode signal inhibits all C_internal outputs)
    //
    // the generated code has this structure:
    // C_internal[0] = ~(C_in);
    // C_internal[1] = ~(C_in & P_internal[0] |
    //                          G_internal[0]);
    // C_internal[2] = ~(C_in & P_internal[0] & P_internal[1] |
    //                                          P_internal[1] & G_internal[0] |
    //                                                          G_internal[1]);
    // C_internal[3] = ~(C_in & P_internal[0] & P_internal[1] & P_internal[2] |
    //                                          P_internal[1] & P_internal[2] & G_internal[0] |
    //                                                          P_internal[2] & G_internal[1] |
    //                                                                          G_internal[2]);
    //
    if (i == 0)
    begin
      assign C_and_P_term[i] = C_in & !Mode;
    end
    else
    begin
      localparam i_minus_1 = i - 1;

      assign C_and_P_term[i] = C_in & (&P_internal[i_minus_1:0]) & !Mode;

      assign G_term[i] = G_internal[i_minus_1] & !Mode;

      if (i > 1)
      begin
        genvar j;
        for (j = 0; j < i_minus_1; j = j + 1)
        begin: gen_P_and_G_term
          localparam j_plus_one = j + 1;

          // these terms will be joined by | below:
          assign P_and_G_term[j] = (&P_internal[i_minus_1:j_plus_one]) & G_internal[j] & !Mode;
        end
      end
    end

    // internal carry signals aggregated from the above terms
    if (i == 0)
    begin
      assign C_internal[i] = ~C_and_P_term[i];
    end
    else if (i == 1)
    begin
      assign C_internal[i] = ~(C_and_P_term[i] | G_term[i]);
    end
    else
    begin
      assign C_internal[i] = ~(C_and_P_term[i] | (|P_and_G_term[(i - 2):0]) | G_term[i]);
    end

    // second layer, separate section: internal carry generate signals from the
    //                                 propagate and generate signals, used for computation of:
    //                                 carry output C, carry lookahead output CG
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
  // third layer: carry lookahead bits aggregated from the above terms
  CP_computed = ~(&P_internal);
  CG_computed = ~(|CG_internal);

  // third layer: carry bit
  C_computed = C_in & (&P_internal) | (|CG_internal);

  // third layer: F bits
  F_computed = P_internal ^ G_internal ^ C_internal;
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
