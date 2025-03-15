module Spartan_tb ();
    // Parameters Declaration
    parameter A0REG = 0;
    parameter A1REG = 1;
    parameter B0REG = 0; 
    parameter B1REG = 1;
    parameter CREG = 1;
    parameter DREG = 1;
    parameter MREG = 1;
    parameter PREG = 1;
    parameter CARRYINREG = 1;
    parameter CARRYOUTREG = 1;
    parameter OPMODEREG = 1;
    parameter CARRYINSEL = "OPMODE5";
    parameter B_INPUT = "DIRECT";
    parameter RSTTYPE = "SYNC";

    // Signals Declaration
    reg [17:0] A, B, D, BCIN;
    reg [47:0] C, PCIN;
    reg [7:0] OPMODE;
    reg CLK, CARRYIN;
    reg RSTA, RSTB, RSTC, RSTD, RSTM, RSTP, RSTCARRYIN, RSTOPMODE;
    reg CEA, CEB, CEC, CED, CEM, CEP, CECARRYIN, CEOPMODE;
    wire [47:0] PCOUT, P;
    wire [35:0] M;
    wire [17:0] BCOUT;
    wire CARRYOUT, CARRYOUTF;

    // DUT Instantiation
    Spartan #(
        .A0REG(A0REG), .A1REG(A1REG), .B0REG(B0REG), .B1REG(B1REG),
        .CREG(CREG), .DREG(DREG), .MREG(MREG), .PREG(PREG),
        .CARRYINREG(CARRYINREG), .CARRYOUTREG(CARRYOUTREG),
        .OPMODEREG(OPMODEREG), .CARRYINSEL(CARRYINSEL),
        .B_INPUT(B_INPUT), .RSTTYPE(RSTTYPE)
    ) Du1 (
        .A(A), .B(B), .D(D), .BCIN(BCIN),
        .C(C), .PCIN(PCIN), .OPMODE(OPMODE),
        .CARRYIN(CARRYIN), .CLK(CLK),
        .CEA(CEA), .CEB(CEB), .CEC(CEC), .CED(CED),
        .CEP(CEP), .CEM(CEM), .CECARRYIN(CECARRYIN), .CEOPMODE(CEOPMODE),
        .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTD(RSTD),
        .RSTM(RSTM), .RSTP(RSTP), .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE),
        .P(P), .PCOUT(PCOUT), .M(M),
        .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF), .BCOUT(BCOUT)
    );

    // Clock Generation
    initial begin
        CLK = 0;
        forever #1 CLK = ~CLK;
    end

    // Test Stimulus Generator
    initial begin
        // Initialize inputs
        A = 18'd5;  B = 18'd10;  D = 18'd18;  BCIN = 18'd6;  
        C = 48'd40;  PCIN = 48'd55;  OPMODE = 8'd7;  CARRYIN = 0;

        // Reset all
        RSTA = 1; RSTB = 1; RSTC = 1; RSTD = 1;
        RSTM = 1; RSTP = 1; RSTCARRYIN = 1; RSTOPMODE = 1;
        CEA = 0; CEB = 0; CEC = 0; CED = 0; CEM = 0; CEP = 0;
        CECARRYIN = 0; CEOPMODE = 0;
        
        repeat (4) @(negedge CLK);
        
        // Release reset
        RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0;
        RSTM = 0; RSTP = 0; RSTCARRYIN = 0; RSTOPMODE = 0;
        CEA = 1; CEB = 1; CEC = 1; CED = 1; CEM = 1; CEP = 1; 
        CECARRYIN = 1; CEOPMODE = 1;
        
        // Test 1: Simple Multiply A * B
        OPMODE = 8'b00000001; // Corresponds to multiply
        repeat (4) @(negedge CLK);
        if (P != A * B) begin
            $display("Error - Test 1: P = %d, Expected = %d", P, A * B);
            $stop;
        end
        
        // Test 2: Reset behavior
        RSTP = 1;
        repeat (4) @(negedge CLK);
        if (P != 0) begin
            $display("Error - Test 2: P = %d, Expected = 0", P);
            $stop;
        end

        // Test 3: Multiplication with Registers
        RSTP = 0;
        A = 18'd3;
        B = 18'd7;
        repeat (4) @(negedge CLK);
        if (P != A * B) begin
            $display("Error - Test 3: P = %d, Expected = %d", P, A * B);
            $stop;
        end

        // Additional Tests...
        
        $stop;
    end

endmodule // Spartan_tb
