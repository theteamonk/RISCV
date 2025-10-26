/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	instr_mem.v
 *  
 *  Description	:	Instruction Memory
 
					DATA_WIDTH				->		Each instruction is 32 bits wide.
					ADDR_WIDTH				->		Address bus is 32 bits wide, allowing access to 
													a large memory space.
					MEM_SIZE				->		The memory itself contains 512 locations, each capable 
													of holding a 32-bit instruction.
					PC (Program Counter)	->		(Input)	A 32-bit input that serves as the address for 
													fetching an instruction.
					instr					->		(Output) A 32-bit output that provides the fetched 
													instruction.
									
					Word-Aligned Access: The code uses PC[31:2] to index the 
					memory array. This is a common practice in RISC-V and other architectures 
					for word-aligned memory access.
					
					Since each instruction is 32 bits (4 bytes), and memory is addressed 
					in bytes, the lowest two bits of the address (PC[1:0]) are 
					always 0 for a word-aligned instruction fetch. By ignoring these two bits, 
					the address is effectively shifted right by two, converting a byte address 
					into a word address (index). For example, 0x00000004 (byte address) becomes 
					index 1 (0x00000001) in the instr_ram array.
					
					The address PC[31:2] is used as the index to access the instr_ram 
					array. The instruction stored at that index is then assigned to the 
					instr output. This simulates a lookup where the processor provides an 
					address and the memory provides the instruction at that location.
 ********************************************************************************************/
 
module instr_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 512)(
					input	[ADDR_WIDTH-1 : 0] PC,
					output	[DATA_WIDTH-1 : 0] instr);

	/*Declares an array of 512 registers, where each register is 32 bits wide. 
	This array represents the instruction memory. The initial block loads the memory contents 
	from a file named <>.hex. This file contains the machine code (instructions) that 
	the processor will execute.*/
	reg [DATA_WIDTH-1 : 0] instr_ram [0 : MEM_SIZE-1];
	
	/*
	initial begin
		$readmemh(".hex", instr_ram);
	end
	*/
	
	//word aligned access
	//combinational read logic between state elements
	assign instr = instr_ram[PC[31:2]];

endmodule