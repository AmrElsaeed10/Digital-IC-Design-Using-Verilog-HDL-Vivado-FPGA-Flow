module Spartan #(
parameter A0REG = 0,
parameter A1REG = 1,
parameter B0REG = 0,
parameter B1REG = 1,
parameter CREG = 1,
parameter DREG = 1,
parameter PREG = 1,
parameter MREG = 1,
parameter CARRYINREG = 1,
parameter CARRYOUTREG = 1,
parameter OPMODEREG = 1,
parameter CARRYINSEL = "OPMODE5",
parameter B_INPUT = "DIRECT",
parameter RSTTYPE = "SYNC"
)(
input [17:0] A, B, D, BCIN,
input [47:0] C, PCIN,
input [7:0] OPMODE,
input CARRYIN, CLK, CEA, CEB, CEC, CED, CEP, CEM, CECARRYIN, CEOPMODE,
input RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE,
output [47:0] P, PCOUT,
output [35:0] M,
output CARRYOUT, CARRYOUTF, 
output [17:0] BCOUT
);

// Internal Signals
reg [17:0] B_mux;
wire [17:0] pre_mux, D_mux, B0_mux, A0_mux, B1_mux, A1_mux;
wire [47:0] C_mux;
wire [35:0] M_mux;
wire [7:0] OPMODE_mux;
wire CYO_mux;
wire [17:0] pre_out;
wire [47:0] post_out;
wire post_cyo;
wire [35:0] multiply_out;
reg [47:0] x_out, z_out;
reg carry_mux;

// B_INPUT Mux Logic
always @(*) begin
if (B_INPUT == "DIRECT")
B_mux = B;
else if (B_INPUT == "CASCADE")
B_mux = BCIN;
else
B_mux = 18'b0;
end

// CARRYINSEL Logic
always @(*) begin
if (CARRYINSEL == "OPMODE5")
carry_mux = OPMODE_mux[5];  
else if (CARRYINSEL == "CARRYIN")
carry_mux = CARRYIN;  
else
carry_mux = 1'b0;  
end

// Pre-Adder/Subtracter Logic
assign pre_out = (OPMODE_mux[6]) ? (D_mux - B0_mux) : (D_mux + B0_mux);
assign pre_mux = (OPMODE_mux[4]) ? pre_out : B0_mux;

// Multiplier Logic
assign multiply_out = A1_mux * B1_mux;

// X Multiplexer Logic
always @(*) begin
case(OPMODE_mux[1:0])
2'b00: x_out = 48'b0;
2'b01: x_out = M_mux;
2'b10: x_out = P;
2'b11: x_out = {D_mux[11:0], A1_mux[17:0], B1_mux[17:0]};
endcase
end

// Z Multiplexer Logic
always @(*) begin
case(OPMODE_mux[3:2])
2'b00: z_out = 48'b0;
2'b01: z_out = PCIN;
2'b10: z_out = P;
2'b11: z_out = C_mux;
endcase
end

// Post-Adder/Subtracter Logic
assign {post_cyo, post_out} = (OPMODE_mux[7]) ? (z_out - (x_out + CYO_mux)) : (z_out + x_out);

// Output Assignments
assign PCOUT = P;
assign M = M_mux;
assign CARRYOUTF = CARRYOUT;
assign BCOUT = B1_mux;

// Instantiation of Registers
InstaSpartan #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(DREG)
) D_REG (
    .in(D),
    .clk(CLK),
    .rst(RSTD),
    .CE(CED),
    .mux_out(D_mux)
);

InstaSpartan #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(B0REG)
) B0_REG (
    .in(B_mux),
    .clk(CLK),
    .rst(RSTB),
    .CE(CEB),
    .mux_out(B0_mux)
);

InstaSpartan #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(A0REG)
) A0_REG (
    .in(A),
    .clk(CLK),
    .rst(RSTA),
    .CE(CEA),
    .mux_out(A0_mux)
);

InstaSpartan #(
    .IO_WIDTH(48),
    .RSTTYPE(RSTTYPE),
    .REG_E(CREG)
) C_REG (
    .in(C),
    .clk(CLK),
    .rst(RSTC),
    .CE(CEC),
    .mux_out(C_mux)
);

InstaSpartan #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(B1REG)
) B1_REG (
    .in(pre_mux),
    .clk(CLK),
    .rst(RSTB),
    .CE(CEB),
    .mux_out(B1_mux)
);

InstaSpartan #(
    .IO_WIDTH(18),
    .RSTTYPE(RSTTYPE),
    .REG_E(A1REG)
) A1_REG (
    .in(A0_mux),
    .clk(CLK),
    .rst(RSTA),
    .CE(CEA),
    .mux_out(A1_mux)
);

InstaSpartan #(
    .IO_WIDTH(36),
    .RSTTYPE(RSTTYPE),
    .REG_E(MREG)
) M_REG (
    .in(multiply_out),
    .clk(CLK),
    .rst(RSTM),
    .CE(CEM),
    .mux_out(M_mux)
);

InstaSpartan #(
    .IO_WIDTH(8),
    .RSTTYPE(RSTTYPE),
    .REG_E(OPMODEREG)
) OPMODE_REG (
    .in(OPMODE),
    .clk(CLK),
    .rst(RSTOPMODE),
    .CE(CEOPMODE),
    .mux_out(OPMODE_mux)
);

InstaSpartan #(
    .IO_WIDTH(1),
    .RSTTYPE(RSTTYPE),
    .REG_E(CARRYINREG)
) CYI (
    .in(carry_mux),
    .clk(CLK),
    .rst(RSTCARRYIN),
    .CE(CECARRYIN),
    .mux_out(CYO_mux)
);

InstaSpartan #(
    .IO_WIDTH(48),
    .RSTTYPE(RSTTYPE),
    .REG_E(PREG)
) P_REG (
    .in(post_out),
    .clk(CLK),
    .rst(RSTP),
    .CE(CEP),
    .mux_out(P)
);

InstaSpartan #(
    .IO_WIDTH(1),
    .RSTTYPE(RSTTYPE),
    .REG_E(CARRYOUTREG)
) CYO (
    .in(post_cyo),
    .clk(CLK),
    .rst(RSTCARRYIN),
    .CE(CECARRYIN),
    .mux_out(CARRYOUT)
);

endmodule
