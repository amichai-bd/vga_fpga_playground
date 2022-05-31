//-----------------------------------------------------------------------------
// Title            : VGA memory - Behavioral
//-----------------------------------------------------------------------------
// File             : .sv
// Original Author  : Amichai Ben-David
// Created          : 
//-----------------------------------------------------------------------------
// Description :
//------------------------------------------------------------------------------
// Modification history :
//------------------------------------------------------------------------------
`include "definitions.sv"
module ram2port_sim (
    input  logic        clock    ,
    //Write
    input  logic [13:0] wraddress,
    input  logic [31:0] data     ,
    input  logic        wren     ,
    //Read
    input  logic [13:0] rdaddress,
    output logic [31:0] q
    );
logic [7:0]  mem     [38400-1:0];
logic [7:0]  next_mem[38400-1:0];
logic [31:0] pre_q;  
logic [15:0] RdAddressByteAl;
logic [15:0] WrAddressByteAl;
assign  WrAddressByteAl = {wraddress,2'b00};
assign  RdAddressByteAl = {rdaddress,2'b00};
//=======================================
//          Writing to memory
//=======================================
logic [7:0] Byte0;
logic [7:0] Byte1;
logic [7:0] Byte2;
logic [7:0] Byte3;
logic [7:0] RdByte0;
logic [7:0] RdByte1;
logic [7:0] RdByte2;
logic [7:0] RdByte3;
assign Byte0 = data[7:0];
assign Byte1 = data[15:8];
assign Byte2 = data[23:16];
assign Byte3 = data[31:24];
always_comb begin
    next_mem = mem;
    if(wren) begin
        next_mem[WrAddressByteAl+0]= Byte0;
        next_mem[WrAddressByteAl+1]= Byte1;
        next_mem[WrAddressByteAl+2]= Byte2;
        next_mem[WrAddressByteAl+3]= Byte3; 
    end
end 
//=======================================
//          the memory Array
//=======================================
`MSFF(mem, next_mem, clock)
//=======================================
//          reading the memory
//=======================================
assign RdByte0 = mem[RdAddressByteAl+0];
assign RdByte1 = mem[RdAddressByteAl+1];
assign RdByte2 = mem[RdAddressByteAl+2];
assign RdByte3 = mem[RdAddressByteAl+3];
assign pre_q= {RdByte3, RdByte2, RdByte1, RdByte0};
// sample the read - synchorus read
`MSFF(q, pre_q, clock)

endmodule