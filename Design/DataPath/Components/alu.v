/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	alu.v
 *  
 *  Description	:	Arithmetic Logic Unit
 ********************************************************************************************/

 module alu #(parameter WIDTH = 32)(
    input       [WIDTH-1 : 0]   A, B,
    input       [3:0]           alu_ctrl,
    output reg  [WIDTH-1 : 0]   alu_result,
    output                      zero            
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

    always @(A, B, alu_ctrl) 
        begin
            case (alu_ctrl)
                ADD:        alu_result  <=  A + B;
                SUB:        alu_result  <=  A + ~B + 1;
                AND:        alu_result  <=  A & B;
                OR:         alu_result  <=  A | B;
                SLL_SLLI:   alu_result  <=  A << B;
                SLT_SLTI:   alu_result  <=  ($signed(A) < $signed(B)) ? 1 : 0;
                SLTU_SLTUI: alu_result  <=  (A < B) ? 1 : 0;
                XOR_XORI:   alu_result  <=  A ^ B;
                SRL_SRLI:   alu_result  <=  A >> B;
                SRA_SRAI:   alu_result  <=  $signed(A) >>> B[4:0];
                default:    alu_result  <=  0;
            endcase
        end

    assign zero = (alu_result = 0) ? 1d'1 : 1'd0;

endmodule
