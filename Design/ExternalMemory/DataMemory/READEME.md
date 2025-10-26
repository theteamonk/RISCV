# Data Memory

					INPUT:
					clk          ->	A clock signal that synchronizes all memory operations.
					wr_en        ->	A write enable signal. When wr_en is high (1), data is written to memory at positive edge of the clock
					wr_addr      ->	The 32-bit address where data will be written.
					wr_data      ->	The 32-bit data to be written into memory.
					
					OUTPUT:
					rd_data_mem  ->	32-bit output that provides the data read from memory.

| Parameters | Description |
| :---: | :--- |
| DATA_WIDTH | Width of data being stored, 32 bits wide. |
| ADDR_WIDTH | Width of address used to access memory, 32 bits wide. |
| MEM_SIZE | Size of memory, which can hold 64 32-bit words. <br/> - this size usually depends on the controller that is used <br/> - and for writing optimized program. |

##

<p align="center">
<img width="650" height="662" alt="Project-Data Memory drawio" src="https://github.com/user-attachments/assets/f9cef407-89f7-4dc9-bec7-83dc5494d896" />
</p>

```
data_ram [wr_addr[DATA_WIDTH-1 : 2] % MEM_SIZE]
```

The expression `% MEM_SIZE` or `% 64` in the Verilog code is used to wrap the memory address around, effectively mapping a potentially large 32-bit address space to the smaller, fixed-size memory array of 64 words. This is a common technique used in memory modeling to handle addresses that may exceed the physical memory size.
- **Bit Selection**: `wr_addr[DATA_WIDTH-1:2]` selects the upper 30 bits of the 32-bit address. This is done because RISC-V is a byte-addressable architecture, and a 32-bit word requires 4 bytes. The lower two bits of the address (`wr_addr[1:0]`) specify the byte within a word, not the word itself. Therefore, to get the word address, the address must be right-shifted by two bits, which is equivalent to dividing by 4. This is implicitly handled by selecting bits `[31:2]`.
  - For example, if `wr_addr` is `0x0000000C`, the word address is `0x00000003` (12/4). The selected bits `wr_addr[31:2]` would be `0x00000003`.
  - For more information: [Instruction Memory](../InstructionMemory#how-instructions-are-fetched)
- **Modulo Operation**: The result of the bit selection is then divided by 64, and the remainder is taken. The `% 64` operation ensures that the resulting `wr_addr` is always in the range of 0 to 63, which are the valid indices for the `data_ram` array.
  - For example, if the *word address* is `70`, the modulo operation `70 % 64` will result in `6`. The data will be written to or read from `data_ram[6]` and if the *word address* is `6`, the modulo operation `6 % 64` will result in `6`, so the data will be written to or read from `data_ram[6]`, so this demonstrates "wrap-around".
 
##

- If write enable (`wr_en`) is asserted, data_mem writes data (`wr_data`) into address (`wr_addr`) (word aligned access) at positive edge of clock
  
```
always @(posedge clk) 
		begin
			if(wr_en)
				data_ram [wr_addr[DATA_WIDTH-1 : 2] % MEM_SIZE] <= wr_data;
		end
```

- Else, if write enable (`wr_en`) is 0, it reads from address (`wr_addr`) (word aligned access) <br/>
- The read operation from data memory is typically asynchronous with respect to the clock edge, meaning it does not strictly happen on a rising or falling edge of the clock. Instead, the data is expected to become available combinatorially after the address is presented to the memory, within the same clock cycle. <br/>

```
assign rd_data_mem = data_ram [wr_addr[DATA_WIDTH-1 : 2] % MEM_SIZE];
```
