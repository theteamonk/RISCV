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
```verilog
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

# MAIN DECODER 

					INPUT:
					[6:0] op            ->	Opcode field from instruction (Instr[6:0]) — identifies instruction type (R, I, S, B, U, J).
					[2:0] funct3        ->	Mid-field used for further branch condition decoding.
					Zero            	->	ALU’s Zero flag used for BEQ/BNE decisions.
					ALUR31         		->	ALU’s sign/compare flag (e.g., less-than comparison). Used for BLT, BGE, etc.
					
					OUTPUT:
					RegWrite    		->	Enables register file write for instructions like ADD, LW, JAL, etc.
					ImmSrc				->	Selects which immediate type to sign-extend (I, S, B, J, or U).
					ALUSrc				->	Chooses between register or immediate as second ALU operand.
					MemWrite			->	Enables writing data to memory (SW).
					[1:0] ResultSrc		->	Selects what data is written back to register file — from ALU, memory, or PC+4.
					[1:0] ALUOp			->	High-level ALU operation control sent to ALU Decoder.
					Branch				->	Activated when a branch condition is satisfied.
					Jump				->	Activated for jal instruction.
					Jalr				->	Activated for jalr instruction (register-based jump).

					Internal Signals:
					[10:0] controls		->	Encodes all control signals in one register.
					TakeBranch			->	Temporary register to determine branch condition truth.

## Control Encoding Format

Each case in the code sets the following fields:
```
RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_ALUOp_Jump_Jalr
```
```verilog
11'b1_00_1_0_01_00_0_0  → lw instruction
```

## Opcode decoding logic

| `op` (7b) |           Instruction / type           | `RegWrite` | `ImmSrc` | `ALUSrc` | `MemWrite` | `ResultSrc` |       `ALUOp`      | `Jump` | `Jalr` | Notes                                                                             |
| :-------: | :------------------------------------: | :--------: | :------: | :------: | :--------: | :---------: | :----------------: | :----: | :----: | :-------------------------------------------------------------------------------- |
| `0000011` |           `lw` (I-type load)           |      1     |   `00`   |     1    |      0     |  `01` (mem) |        `00`        |    0   |    0   | load: ALU performs ADD (base+offset); write memory data back.                     |
| `0100011` |           `sw` (S-type store)          |      0     |   `01`   |     1    |      1     |     `xx`    |        `00`        |    0   |    0   | store: ALU computes address; writes RD2 to memory.                                |
| `0110011` |     R-type (add,sub,and,or,slt,...)    |      1     |   `xx`   |     0    |      0     |  `00` (ALU) |        `10`        |    0   |    0   | ALUDecoder uses `funct3`/`funct7b5` to choose operation.                          |
| `1100011` |  Branches (beq,bne,blt,bge,bltu,bgeu)  |      0     |   `10`   |     0    |      0     |     `xx`    |        `01`        |    0   |    0   | Branch taken when `TakeBranch` true (see branch table).                           |
| `0010011` |   I-type ALU (addi,andi,ori,slti,...)  |      1     |   `00`   |     1    |      0     |  `00` (ALU) |        `10`        |    0   |    0   | I-type arithmetic: immediate supplied as SrcB; ALUOp=10 so decoder uses `funct3`. |
| `1101111` |      `jal` (J-type jump-and-link)      |      1     |   `11`   |    `x`   |      0     | `10` (PC+4) | `00` (`x` in code) |    1   |    0   | Writes PC+4 to rd; PC ← PC + imm(J).                                              |
| `1100111` | `jalr` (I-type jump-and-link register) |      1     |   `00`   |     1    |      0     | `10` (PC+4) |        `00`        |    0   |    1   | PC computed via ALU (rs1 + imm); writes PC+4 to rd.                               |
| `0?10111` |   `lui` / `auipc` (pattern `0?10111`)  |      1     |   `xx`   |    `x`   |      0     |     `11`    |        `xx`        |    0   |    0   | `ResultSrc=11` used to route immediate/PC+imm as result (AUIPC/LUI).              |
| `default` |           undefined / illegal          |     `x`    |   `xx`   |    `x`   |     `x`    |     `xx`    |        `xx`        |   `x`  |   `x`  | fallback — all controls are don't-care / X in your code.                          |

## Branch Evaluation Truth Table

When opcode = `1100011` (branch), the code sets controls for branch and computes TakeBranch according to funct3, Zero, and ALUR31:
| `funct3` | Branch mnemonic | Condition used in code | Meaning                                                            |
| :------: | :-------------: | :--------------------: | :----------------------------------------------------------------- |
|   `000`  |      `BEQ`      |   `TakeBranch = Zero`  | take if ALU result == 0                                            |
|   `001`  |      `BNE`      |  `TakeBranch = !Zero`  | take if ALU result != 0                                            |
|   `100`  |      `BLT`      |  `TakeBranch = ALUR31` | signed less-than → take if ALU indicates negative (ALUR31=1)       |
|   `101`  |      `BGE`      | `TakeBranch = !ALUR31` | signed greater-or-equal → take if ALUR31==0                        |
|   `110`  |      `BLTU`     |  `TakeBranch = ALUR31` | unsigned less-than → uses same ALUR31 flag (implementation detail) |
|   `111`  |      `BGEU`     | `TakeBranch = !ALUR31` | unsigned greater-or-equal → !ALUR31                                |

- Branch (module output) = TakeBranch.

> [!NOTE]
> ALUR31 in your design is the flag used for signed/unsigned comparison results coming from ALU (e.g., set-less-than logic). Ensure the ALU sets ALUR31 consistently for signed vs unsigned ops.

## 
> [!NOTE]
> - `ALUOp` = 00 → ALU should do ADD (addresses: lw/sw).
> - `ALUOp` = 01 → ALU should do SUB (branch comparisons).
> - `ALUOp` = 10 → ALU Decoder must inspect `funct3` (and `funct7b5` / `op[5]`) to choose operation.
> - `ResultSrc` lets a single RegWrite path handle: ALU result (00), memory data (01), or PC+4 (10) (and 11 for LUI/AUIPC immediate behavior).
> - The `casez` in your code and pattern `0?10111` lets you match both `lui` and `auipc` opcodes with a single pattern — handy for compact control.

## Key Roles in DataPath
- Drives multiplexers:
  - ALUSrc → selects between register or immediate input to ALU.
  - ResultSrc → selects ALUResult, ReadData (memory), or PC+4 for register write-back.
- Enables or disables register/memory write operations.
- Controls branch and jump PC selection logic via Branch, Jump, and Jalr.
- Sends simplified ALUOp to ALU Decoder, reducing logic complexity.
