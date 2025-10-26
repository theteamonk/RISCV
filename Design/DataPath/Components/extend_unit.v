/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	extended_unit.v
 *  
 *  Description	:	Extended Unit
 ********************************************************************************************/

 module extend_unit (
    input       [31 : 7]    instr,      /* receives 12-bit signed immediate */
    input       [ 1 : 0]    imm_src,
    output reg  [31 : 0]    imm_ext
 );

    parameter I_TYPE = 2'b00;
    parameter S_TYPE = 2'b01;
    parameter B_TYPE = 2'b10;
    parameter J_TYPE = 2'b11;

    always @(*)
        begin
            case (imm_src)
                I_TYPE:     imm_ext =   {{20{instr[31]}},   instr[31:20]};
                S_TYPE:     imm_ext =   {{20{instr[31]}},    instr[31:25],   instr[11:7]};
                B_TYPE:     imm_ext =   {{20{instr[31]}},    instr[7],       instr[30:25],   instr[11:8],    1'b0};
                J_TYPE:     imm_ext =   {{20{instr[31]}},    instr[19:12],   instr[20],      instr[30:21],   1'b0};
                default:    imm_ext =   32'bx;
            endcase
        end

endmodule