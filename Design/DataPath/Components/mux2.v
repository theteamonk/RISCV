/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	mux2.v
 *  
 *  Description	:	2 input Multiplexer
 ********************************************************************************************/

 module mux2 #(parameter WIDTH = 8)(
    input   [WIDTH-1 : 0]   D0, D1,
    input                   sel,
    output  [WIDTH-1 : 0]   Y
 );

   assign Y   =   sel ?   D1  :   D0;

 endmodule