/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	data_mem.v
 *	
 *	Description	:	Data Memory
 
					DATA_WIDTH	->	Width of data being stored, 32 bits wide.
					ADDR_WIDTH	->	Width of address used to access memory, 32 bits wide.
					MEM_SIZE	->	Size of memory, which can hold 64 32-bit words.
									this size usually depends on the controller that is used
									and for writing optimized program
					
					Input
					clk			->	A clock signal that synchronizes all memory operations.
					wr_en		->	A write enable signal. When wr_en is high (1), 
									data is written to memory at positive edge of the clock
					wr_addr		->	The 32-bit address where data will be written.
					wr_data		->	The 32-bit data to be written into memory.
					
					Output
					rd_data_mem	->	32-bit output that provides the data read from memory.
********************************************************************************************/

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64)(
					input 						clk, wr_en,
					input	[ADDR_WIDTH-1 : 0] 	wr_addr,
					input	[DATA_WIDTH-1 : 0] 	wr_data,
					output	[DATA_WIDTH-1 : 0] 	rd_data_mem);
					
	reg [DATA_WIDTH-1 : 0] data_ram [0 : MEM_SIZE-1];
	
	wire [ADDR_WIDTH-1 : 0] word_addr = wr_addr[DATA_WIDTH-1 : 2] % MEM_SIZE;
	
	assign rd_data_mem = data_ram [word_addr];
	
	always @(posedge clk) 
		begin
			if(wr_en)
				data_ram [word_addr] <= wr_data;
		end
		
endmodule