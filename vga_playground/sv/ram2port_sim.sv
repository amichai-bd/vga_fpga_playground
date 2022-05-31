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
    input  logic [12:0] wraddress,
    input  logic [31:0] data     ,
    input  logic        wren     ,
    //Read
    input  logic [12:0] rdaddress,
    output logic [31:0] q
    );
logic [7:0]  mem     [38400-1:0];
logic [7:0]  next_mem[38400-1:0];
logic [31:0] pre_q;  
//=======================================
//          Writing to memory
//=======================================
always_comb begin
    next_mem = mem;
    if(wren) begin
        next_mem[wraddress+0]= data[7:0];
        next_mem[wraddress+1]= data[15:8];
        next_mem[wraddress+2]= data[23:16];
        next_mem[wraddress+3]= data[31:24]; 
    end
end 
//=======================================
//          the memory Array
//=======================================
`MSFF(mem, next_mem, clock)
//=======================================
//          reading the memory
//=======================================
assign pre_q= {mem[rdaddress+3], mem[rdaddress+2], mem[rdaddress+1], mem[rdaddress+0]};
// sample the read - synchorus read
`MSFF(q, pre_q, clock)

endmodule