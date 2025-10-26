/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	pcreg.v
 *  
 *  Description	:	Program Counter register
 ********************************************************************************************/

 module pcreg #(parameter WIDTH = 8)(
    input                       clk, rst,
    input       [WIDTH-1 : 0]   D,
    output reg  [WIDTH-1 : 0]   Q
 );

    always @(posedge clk or posedge rst)
        begin
            if(rst)
                Q   <=  0;
            else
                Q   <=  D;
        end

endmodule