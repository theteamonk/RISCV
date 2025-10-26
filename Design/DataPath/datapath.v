/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	datapath.v
 *  
 *  Description	:	Data Path
 ********************************************************************************************/

 module datapath (
    input           clk, rst,
    input           PCSrc,
    input           ResultSrc,
    input           MemWrite,
    input           ALUSrc,
    input           RegWrite,
    input           Jalr,
    output          Zero, ALUR31,
    input   [3 : 0] ALUControl,
    input   [1 : 0] ImmSrc,
    output  [31: 0] PC,
    output  [31: 0] Instr,
    output  [31: 0] Mem_WrAddr,
    output  [31: 0] Mem_WrData,
    output  [31: 0] ReadData
 );

    wire   [31: 0] PCNext, PCPlus4, PCTarget;
    wire   [31: 0] AuiPC, LAuiPC;
    wire   [31: 0] ImmExt;
    wire   [31: 0] SrcA, SrcB;
    wire   [31: 0] Result;
    wire   [31: 0] WriteData;
    wire   [31: 0] ALUResult;

    /* next PC logic */
    mux2#(32)      PCMux       (.D0(PCPlus4), .D1(Result), .sel(PCSrc), .Y(PCNext));
    mux2#(32)      JalrMux     (.D0(ALUResult), .D1(PCNext), .sel(Jalr), .Y(PCJalr));  /* J-Type Logic */
    pcreg#(32)     PCReg       (.clk(clk), .rst(rst), .D(PCNext), .Q(PC));
    adder#(32)     PCAdd4      (.A(PC), .B(32'd4), .Sum(PCPlus4));
    adder#(32)     PCAddBranch (.A(PC), .B(ImmExt), .Sum(PCTarget));
    
    /* register file logic */
    reg_file       RegFile     (.clk(clk), .wr_en(RegWrite), .rd_addr1(Instr[19:15]), .rd_addr2(Instr[24:20]),
                                .wr_addr(Instr[11:7]), .wr_data(Result), .rd_data1(SrcA), .rd_data2(WriteData));

    extend_unit    Entend      (.instr(Instr[31:7]), .imm_src(ImmSrc), .imm_ext(ImmExt));

    /* ALU Logic */
    mux2#(32)      SrcBMux     (.D0(WriteData), .D1(ImmExt), .sel(ALUSrc), .Y(SrcB));
    ALU            ALU         (.A(SrcA), .B(SrcB), .alu_ctrl(ALUControl), .alu_result(ALUResult), .zero(Zero));

    /* U-Type Logic */
    adder#(32)     AuiPCAdder  (.A({Instr[31:7], 12'b0}), .B(PC), .Sum(AuiPC));
    mux2#(32)      LAuiPCMux   (.D0({Instr[31:7], 12'b0}), .D1(AuiPC), .sel(Instr[5]), .Y(LAuiPC));

    /* Result Logic */
    mux4#(32)      ResultMux   (.D0(ALUResult), .D1(ReadData), .D2(PCPlus4), .D3(LAuiPC), .sel(ResultSrc), .Y(Result));

    /* for blt, bge, bltu, bgeu B-type instructions */
    assign  ALUR31      =   ALUResult[31];

    /* only for naming */
    assign  Mem_WrData  =   WriteData;  
    assign  Mem_WrAddr  =   ALUResult;

 endmodule