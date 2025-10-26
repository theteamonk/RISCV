/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	alu_decoder.v
 *  
 *  Description	:	ALU Decoder
 ********************************************************************************************/

 module alu_decoder(
    input               opb5,
    input       [2:0]   funct3,
    input               funct7b5,
    input       [1:0]   ALUOp,
    output reg  [3:0]   ALUControl
 );

    parameter ADD           =   4'b0000;
    parameter SUB           =   4'b0001;
    parameter AND           =   4'b0010;
    parameter OR            =   4'b0011;
    parameter SLL_SLLI      =   4'b0100;
    parameter SLT_SLTI      =   4'b0101;
    parameter SLTU_SLTUI    =   4'b0110;
    parameter XOR_XORI      =   4'b0111;
    parameter SRL_SRLI      =   4'b1000;
    parameter SRA_SRAI      =   4'b1001;
    parameter UNDEFINED     =   4'bxxxx;

    always @(*)
        begin
            case (ALUOp)
                2'b00:      ALUControl  =   ADD;
                2'b01:      ALUControl  =   SUB;
                default:    begin
                                case(funct3)
                                    3'b000: begin
                                                if(funct7b5 & op5)
                                                    ALUControl  =   SUB;
                                                else
                                                    ALUControl  =   ADD;
                                            end
                                    3'b001: ALUControl  =   SLL_SLLI;
                                    3'b010: ALUControl  =   SLT_SLTI;
                                    3'b011: ALUControl  =   SLTU_SLTUI;
                                    3'b100: ALUControl  =   XOR_XORI;
                                    3'b101: begin
                                                if(funct7b5)
                                                    ALUControl  =   SRA_SRAI;
                                                else
                                                    ALUControl  =   SRL_SRLI;
                                            end
                                    3'b110:     ALUControl  =   OR;
                                    3'b111:     ALUControl  =   AND;
                                    default:    ALUControl  =   UNDEFINED;
                                endcase
                            end
            endcase
        end

 endmodule