/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	reg_file.v
 *  
 *  Description	:	Register File
 ********************************************************************************************/
 
module register_file #(parameter DATA_WIDTH = 32, REG_ADDR = 5, REG_CNT = 32) (
					input						clk,
					input						wr_en,
					input	[REG_ADDR-1 : 0] 	rd_addr1, rd_addr2, wr_addr,
					input	[DATA_WIDTH-1 : 0] 	wr_data,
					output	[DATA_WIDTH-1 : 0] 	rd_data1, rd_data2);
					
	reg [DATA_WIDTH-1 : 0] reg_file [0 : REG_CNT];
	
	integer i;
	
	initial
		begin
			for(i = 0; i < REG_CNT; i = i+1)
				reg_file[i] = 0;
		end
		
	//write logic - sysnchronous
	always @(posedge clk)
		begin
			if(wr_en)
				reg_file[wr_addr] <= wr_data;
		end
	
	//read logic - combinational
	assign rd_data1 = (rd_addr1 != 0) ? reg_file[rd_addr1] : 0;
	assign rd_data2 = (rd_addr2 != 0) ? reg_file[rd_addr2] : 0;
	
endmodule