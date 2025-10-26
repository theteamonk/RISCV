# ALU DECODER

					INPUT:
					opb5                ->	Bit 5 of opcode (Instr[5]), used to distinguish between R-type and I-type arithmetic instructions.
					[2:0] funct3        ->	Middle bits of the instruction encoding, determining specific ALU function (e.g., AND, OR, SLT, etc.)
					funct7b5            ->	The 5th bit of the funct7 field (Instr[30]), used to distinguish ADD/SUB or SRL/SRA.
					[1:0] ALUOp         ->	2-bit control signal from the Main Decoder that indicates the type of ALU operation:
                                  00 → ADD (e.g., for load/store)
                                  01 → SUB (e.g., for branch)
                                  10 → Use funct3/funct7 to determine operation (for R-type/I-type ALU instructions)
					
					OUTPUT:
					[3:0] ALUControl    ->	A 4-bit control code that selects the ALU operation.


| ALUControl | Operation | Instruction   |
| :---: | :---: | :---: |
| `0000`     | ADD       | add, lw, sw   |
| `0001`     | SUB       | sub, beq      |
| `0010`     | AND       | and, andi     |
| `0011`     | OR        | or, ori       |
| `0100`     | SLL       | sll, slli     |
| `0101`     | SLT       | slt, slti     |
| `0110`     | SLTU      | sltu, sltui   |
| `0111`     | XOR       | xor, xori     |
| `1000`     | SRL       | srl, srli     |
| `1001`     | SRA       | sra, srai     |
| `xxxx`     | Undefined | default/error |

##
- The ALU Decoder is a part of the control unit in a RISC-V single-cycle processor.
- It translates intermediate control signals (ALUOp, funct3, funct7b5, and sometimes opb5) into a specific ALUControl output, which tells the ALU what operation to perform (ADD, SUB, AND, OR, etc.).
- It acts as a secondary decoder, working alongside the Main Decoder, which classifies the instruction type (R-type, I-type, load, store, branch).

##
```
case (ALUOp)
                2'b00:      ALUControl  =   ADD;
                2'b01:      ALUControl  =   SUB;
                default:    begin
                                case(funct3)
                                    3'b000: begin
                                                if(funct7b5 & op5)
                                                    ALUControl  =   SUB;
                                                else
                                                    ALUControl  =   ADD;
                                            end
                                    3'b001: ALUControl  =   SLL_SLLI;
                                    3'b010: ALUControl  =   SLT_SLTI;
                                    3'b011: ALUControl  =   SLTU_SLTUI;
                                    3'b100: ALUControl  =   XOR_XORI;
                                    3'b101: begin
                                                if(funct7b5)
                                                    ALUControl  =   SRA_SRAI;
                                                else
                                                    ALUControl  =   SRL_SRLI;
                                            end
                                    3'b110:     ALUControl  =   OR;
                                    3'b111:     ALUControl  =   AND;
                                    default:    ALUControl  =   UNDEFINED;
                                endcase
                            end
            endcase
```

If `ALUOp` = 00:
- Always perform ADD (for load/store address calculations).

If `ALUOp` = 01:
- Always perform SUB (for branch comparisons).

If `ALUOp` = 10:
- Instruction is R-type or I-type → ALU Decoder must check:
  - `funct3` to determine the operation type (ADD, AND, OR, etc.)
  - For ambiguous `funct3` = 000 or 101:
    Use `funct7b5` and sometimes opb5:
    - `funct3` = 000, `funct7b5` & `opb5` = 1 → SUB
    - `funct3` = 000, else → ADD
    - `funct3` = 101, `funct7b5` = 1 → SRA
    - `funct3` = 101, `funct7b5` = 0 → SRL

##
- The Main Decoder looks at the opcode (`Instr [6:0]`) and generates signals such as:
  - `RegWrite`, `ALUSrc`, `MemWrite`, `ResultSrc`, `Branch`, `ALUOp`
- The ALU Decoder uses the `ALUOp` from the Main Decoder and the function fields to determine the actual ALU control bits.

