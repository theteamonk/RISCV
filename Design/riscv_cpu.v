/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	controller.v
 *  
 *  Description	:	Controller
 ********************************************************************************************/

 module riscv_cpu (
    input           clk, reset,
    output  [31:0]  PC,
    input   [31:0]  Instr,
    output          MemWrite,
    output  [31:0]  Mem_WrAddr, Mem_WrData,
    input   [31:0]  ReadData,
    output  [31:0]  Result
 );

    wire            ALUSrc, RegWrite, PCSrc, Jump, Jalr, Zero, ALUR31;
    wire    [1:0]   ResultSrc, ImmSrc;
    wire    [3:0]   ALUControl;

    controller  CONTROLLER  (.op(Instr[6:0]), .funct3(Instr[14:12]), .funct7b5(Instr[30]), .Zero(Zero), 
                            .ALUR31(ALUR31), .ResultSrc(ResultSrc), .MemWrite(MemWrite), 
                            .PCSrc(), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .Jump(Jump), .Jalr(Jalr), 
                            .ImmSrc(ImmSrc), .ALUControl(ALUControl));

    datapath    DATA_PATH   (.clk(clk), .rst(rst), .PCSrc(PCSrc), .ResultSrc(ResultSrc), 
                             .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .Jalr(Jalr), 
                             .Zero(Zero), .ALUR31(ALUR31), .ALUControl(ALUControl), .ImmSrc(ImmSrc),
                             .PC(PC), .Instr(Instr), .Mem_WrAddr(Mem_WrAddr), .Mem_WrData(Mem_WrData),
                             .ReadData(ReadData));

 endmodule