/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	controller.v
 *  
 *  Description	:	Controller
 ********************************************************************************************/

 module controller (
    input   [6:0]   op,
    input   [2:0]   funct3,
    input           funct7b5,
    input           Zero, ALUR31,
    output  [1:0]   ResultSrc,
    output          MemWrite,
    output          PCSrc, ALUSrc,
    output          RegWrite, Jump, Jalr,
    output  [1:0]   ImmSrc,
    output  [3:0]   ALUControl
 );

    wire   [1:0]   ALUOp;
    wire           Branch;

    main_decoder    MAIN_DECODER    (.op(op), .funct3(funct3), .Zero(Zero), .ALUR31(ALUR31), .ResultSrc(ResultSrc), 
                                    .MemWrite(MemWrite), .Branch(Branch), .ALUSrc(ALUSrc), .RegWrite(RegWrite), 
                                    .Jump(Jump), .Jalr(Jalr), .ImmSrc(ImmSrc), .ALUOp(ALUOp));

    alu_decoder     ALU_DECODER     (.opb5(opb[5]), .funct3(funct3), .funct7b5(funct7b5), .ALUOp(ALUOp), .ALUControl(ALUControl));

    assign PCSrc    =   Branch  | Jump;

 endmodule