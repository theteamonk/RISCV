/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	mux4.v
 *  
 *  Description	:	4 input Multiplexer
 ********************************************************************************************/

 module mux2 #(parameter WIDTH = 8)(
    input   [WIDTH-1 : 0]   D0, D1, D2, D3
    input   [1:0]           sel,
    output  [WIDTH-1 : 0]   Y
 );

  assign Y   =   sel[1]  ?   (sel[0]  ?   D3  :   D2)  :   (sel[0]  ?   D1  :   D0);

 endmodule