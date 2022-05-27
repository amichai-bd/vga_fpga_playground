`ifndef macros_vh
`define macros_vh


//==============================================
//      Usful Master Slave FliFlop macros
//==============================================
`define  MSFF(q,i,clk)              \
         always_ff @(posedge clk)   \
            q<=i;

`define  EN_MSFF(q,i,clk,en)        \
         always_ff @(posedge clk)   \
            if(en) q<=i;

`define  RST_MSFF(q,i,clk,rst)          \
         always_ff @(posedge clk) begin \
            if (rst) q <='0;            \
            else     q <= i;            \
         end

`define  EN_RST_MSFF(q,i,clk,en,rst)\
         always_ff @(posedge clk)   \
            if (rst)    q <='0;     \
            else if(en) q <= i;
`define  RST_VAL_MSFF(q,i,clk,rst,val) \
         always_ff @(posedge clk) begin    \
            if (rst) q <= val;             \
            else     q <= i;               \
         end

`endif