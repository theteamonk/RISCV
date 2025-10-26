# Register File
    INPUT:
    clk                    -> A clock signal that synchronizes write operation.
    wr_en                  -> Write enable
    rd_addr1, rd_addr2     -> Read address ports of 5 bit 
    wr_addr                -> Wrte address port of 5 bit
    wr_data                -> 32 bit Write data port

    OUTPUT:
    rd_data1, rd_data2     -> 32 bit Read data port

| Parameters | Description |
| :---: | :--- |
| DATA_WIDTH | Width of data being stored, 32 bits wide.
| REG_ADDR | 5-bit address for 2<sup>5</sup> = 32 registers|
| REG_CNT | Number of registers |

<p align="center">
<img width="442" height="402" alt="Project-Register file drawio" src="https://github.com/user-attachments/assets/178c03b5-4f3d-4a0a-bd5a-28aef247279c" />
</p>

```verilog
reg [DATA_WIDTH-1 : 0] reg_file [0 : REG_CNT];
```
Creating Register File with 32 register of 32-bit wide for RV32I. <br/>

## 

```verilog
initial
		begin
			for(i = 0; i < REG_CNT; i = i+1)
				reg_file[i] = 0;
		end
```
Initializing every register to 0. <br/>

```verilog
always @(posedge clk)
		begin
			if(wr_en)
				reg_file[wr_addr] <= wr_data;
		end
```
When write enable `wr_en` is asserted, then the register file `reg_file` writes the data into the specified register on the positive edge of clock. <br/>

```verilog
assign rd_data1 = (rd_addr1 != 0) ? reg_file[rd_addr1] : 0;
assign rd_data2 = (rd_addr2 != 0) ? reg_file[rd_addr2] : 0;
```
Whatever data is there at that read address `rd_data1` or `rd_data2` that will be loaded at that respective registers. <br/>
