# Instruction Memory

    INPUT:
    PC (Program Counter)    ->		A 32-bit input that serves as the address forfetching an instruction.
    
    OUTPUT:
    instr                   ->		A 32-bit output that provides the fetched instruction.

| parameters | description|
| :---: | :--- |
| DATA_WIDTH | Each instruction is 32 bits wide. |
| ADDR_WIDTH | Address bus is 32 bits wide, allowing access to a large memory space. |
| MEM_SIZE | The memory itself contains 512 locations, each capable of holding a 32-bit instruction. |

##
Declares an array of 512 registers, where each register is 32 bits wide. This array represents the instruction memory. The initial block loads the memory contents from a file named <>.hex. This file contains the machine code (instructions) that the processor will execute.<br/>
 ```
reg [DATA_WIDTH-1 : 0] instr_ram [0 : MEM_SIZE-1];
```
 
## How Instructions Are Stored in Byte-Sized Memory
<ins>Example</ins>: <br/>
I-type instruction to explain how it's stored and fetched. A typical I-type instruction in RISC-V is `addi x5, x5, 4`, which adds the immediate value `4` to the value in register `x5` and stores the result back in `x5`. <br/>
This instruction, when converted to its 32-bit machine code representation, is 0x00428293.<br/>
Memory is organized in individual bytes, not 32-bit words. A 32-bit instruction (0x00428293) takes up four consecutive bytes in memory. The way these bytes are arranged depends on the system's endianness. Most systems for RISC-V are little-endian, meaning the least significant byte of the instruction is stored at the lowest memory address.<br/>

Here's how the addi instruction would be stored in memory starting at address 0x00000004:<br/>

| Memory Address | Byte Content |
| :---: | :---: |
| `0x00000004` | `0x93` (Least significant byte) |
| `0x00000005` | `0x82` |
| `0x00000006` | `0x42` |
| `0x00000007` | `0x00` (Most significant byte) |

## How Instructions Are Fetched

The processor doesn't fetch one byte at a time; it fetches the entire 32-bit word in a single operation. This is where word-aligned access is critical. The processor provides the starting address of the word (0x00000004) to the instruction memory module. <br/>
Using the Verilog code, the fetch process works like this:
- The `PC` (Program Counter) holds the address of the next instruction to be executed, which in this case is 0x00000004.
- The `PC`'s value is sent to the `instr_addr` input of the `instr_mem` module.
- The Verilog code uses the expression `instr_addr[31:2]` to get the word index.
  - instr_addr = 0x00000004
  - In binary, this is 0000_0000 ... 0000_0100.
  - Slicing off the last two bits gives us 0000_0000 ... 0000_0001, which is a decimal value of 1.
  - The instruction memory module then accesses its internal array at this index: `instr_ram[1]`.
  - instr_ram[1] contains the 32-bit instruction `0x00428293`.
  - This value is assigned to the `instr` output of the module and sent to the next stage of the processor (the instruction decoder). <br/>

| Byte Address (`instr_addr`)	| Word Address (Array Index: `instr_addr[31:2]`) | Location in `instr_ram` | Instruction Retrieved |
| :---: | :---: | :---: | :--- |
| `0x0000_0000` |	`0x0000_0000` | `instr_ram[0]` | Instruction at byte address 0 |
| `0x0000_0004` |	`0x0000_0001` |	`instr_ram[1]` | Instruction at byte address 4 |
| `0x0000_0008`	| `0x0000_0002`	| `instr_ram[2]` |	Instruction at byte address 8 |
| `0x0000_000C`	| `0x0000_0003`	| `instr_ram[3]` |	Instruction at byte address 12 |

> [!NOTE]
> RISC-V, like most modern architectures, uses byte addressing. This means each byte in memory has a unique address. This is crucial for handling variable-length data types like characters (1 byte), half-words (2 bytes), and words (4 bytes) efficiently.
