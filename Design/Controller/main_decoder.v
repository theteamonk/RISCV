/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	main_decoder.v
 *  
 *  Description	:	Main Decoder
 ********************************************************************************************/

 module main_decoder (
    input   [6:0]   op,
    input   [2:0]   funct3,
    input           Zero, ALUR31,
    output  [1:0]   ResultSrc,
    output          MemWrite, Branch, ALUSrc,
    output          RegWrite, Jump, Jalr,
    output  [1:0]   ImmSrc,
    output  [1:0]   ALUOp 
 );

    reg [10:0]  controls;
    reg         TakeBranch;

    parameter LW        =   7'b0000011;
    parameter SW        =   7'b0100011;
    parameter R_TYPE    =   7'b0110011;
    parameter B_TYPE    =   7'b1100011;
    parameter I_TYPE    =   7'b0010011;
    parameter JAL       =   7'b1101111;
    parameter JALR      =   7'b1100111;
    parameter LUI_AUIPC =   7'b0?10011;

    parameter BEQ   =   3'b000;
    parameter BNE   =   3'b001;
    parameter BLT   =   3'b100;
    parameter BGE   =   3'b101;
    parameter BLTU  =   3'b110;
    parameter BGEU  =   3'b111;

    always @(*)
        begin
            TakeBranch = 0;
            casez(op)
                //RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_ALUOp_Jump_Jalr
                LW:         controls    =   11'b1_00_1_0_01_00_0_0;
                SW:         controls    =   11'b0_01_1_1_00_00_0_0;
                R_TYPE:     controls    =   11'b1_xx_0_0_00_10_0_0;
                B_TYPE: begin
                            controls    =   11'b0_10_0_0_00_01_0_0;
                            case(funct3)
                                BEQ:    TakeBranch  =   Zero;
                                BNE:    TakeBranch  =   !Zero;
                                BLT:    TakeBranch  =   ALUR31;     /* signed */
                                BGE:    TakeBranch  =   !ALUR31;    /* signed */
                                BLTU:   TakeBranch  =   ALUR31;     /* unsigned */
                                BGEU:   TakeBranch  =   !ALUR31;    /* unsigned */
                            endcase
                        end
                I_TYPE:     controls    =   11'b1_00_1_0_00_10_0_0;
                JAL:        controls    =   11'b1_11_0_0_10_00_1_0;
                JALR:       controls    =   11'b1_00_1_0_10_00_0_1;
                LUI_AUIPC:  controls    =   11'b1_xx_x_0_11_xx_0_0;
                default:    controls    =   11'bx_xx_x_x_xx_xx_x_x;
            endcase
        end
    
    assign Branch   =   TakeBranch;
    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUOp, Jump, Jalr}   =   controls;

 endmodule