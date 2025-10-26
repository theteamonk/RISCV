/********************************************************************************************
 *	Project		:	RISC V Single Cycle Processor
 *
 *	Author		:	Chaitra	
 *
 *	File Name	:	adder.v
 *  
 *  Description	:	Adder
 ********************************************************************************************/

 module adder #(parameter WIDTH = 32)(
    input   [WIDTH-1 : 0]   A, B,
    output   [WIDTH-1 : 0]   Sum 
 );

   assign Sum = A + B;

 endmodule