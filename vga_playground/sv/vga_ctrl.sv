`include "definitions.sv"
module vga_ctrl(
        input  logic        CLK_50,
        output logic        CLK_25,
        input  logic        Reset,
        //VGA RAM Access
        input  logic [31:0] WrData,
        input  logic [12:0] WrAddress,
        input  logic        WrEn,
        //VGA Output
        output logic [3:0]  RED,
        output logic [3:0]  GREEN,
        output logic [3:0]  BLUE,
        output logic        h_sync,
        output logic        v_sync
    );
//Only One or the other (FPGA_ON vs SIMULATION_ON )
`ifndef SIMULATION_ON
    `define FPGA_ON    
`endif
logic [9:0]  pixel_y;
//logic        CLK_25;
logic        inDisplayArea;
logic        next_h_sync;
logic        next_v_sync;
logic [3:0]  NextRED;
logic [3:0]  NextGREEN;
logic [3:0]  NextBLUE;
logic        CurentPixelQ2;
//logic [360:0][0:7] PMem ;
logic [8:0]          LineQ0, LineQ1;
logic [31:0] RdDataQ2;
logic [4:0] SampleReset;
logic [6:0] HEX; 
logic [12:0]WordOffsetQ1;
logic [2:0] CountBitOffsetQ1, CountBitOffsetQ2 ;
logic [1:0] CountByteOffsetQ1, CountByteOffsetQ2;
logic [7:0] CountWordOffsetQ1;
logic       EnCountBitOffset,  EnCountByteOffset,  EnCountWordOffset ;
logic       RstCountBitOffset, RstCountByteOffset, RstCountWordOffset;

//=========================
//Reset For Clk Simulation 
//=========================
assign SampleReset[0] = Reset;
`MSFF(SampleReset[4:1], SampleReset[3:0], CLK_50)
//=========================
//gen Clock 25Mhz
//=========================
`ifdef SIMULATION_ON
    `RST_MSFF(CLK_25, !CLK_25, CLK_50, Reset)
`elsif FPGA_ON
pll_2 pll_2 (
    .inclk0 (CLK_50),    // input
    .c0     (CLK_25)     // output
); 
`endif //FPGA_ON

//=========================
// VGA sync Machine
//=========================
sync_gen sync_inst(
    .CLK_25         (CLK_25),       //input
    .Reset          (SampleReset[4]),//input
    .vga_h_sync     (next_h_sync),  //output
    .vga_v_sync     (next_v_sync),  //output
    .CounterX       (),      //output
    .CounterY       (pixel_y),      //output
    .inDisplayArea  (inDisplayArea) //output
);
//=========================
// VGA Display Line #
//=========================
assign LineQ0   = pixel_y[8:0];
`MSFF( LineQ1    , LineQ0    , CLK_25)

//=========================
// Read CurentPixelQ2 using VGA Virtual Address -> Phisical Address in RAM
//=========================
assign EnCountBitOffset   = 1'b1;
assign EnCountByteOffset  = ((CountWordOffsetQ1 == 79) && EnCountWordOffset);
assign EnCountWordOffset  = (CountBitOffsetQ1 == 3'b111);
assign RstCountBitOffset  = SampleReset[4] || (!inDisplayArea);
assign RstCountByteOffset = SampleReset[4];
assign RstCountWordOffset = SampleReset[4] || ((CountWordOffsetQ1 == 79) && EnCountWordOffset);
`EN_RST_MSFF(CountBitOffsetQ1 , (CountBitOffsetQ1 +1), CLK_25, EnCountBitOffset , RstCountBitOffset )
`EN_RST_MSFF(CountByteOffsetQ1, (CountByteOffsetQ1+1), CLK_25, EnCountByteOffset, RstCountByteOffset)
`EN_RST_MSFF(CountWordOffsetQ1, (CountWordOffsetQ1+1), CLK_25, EnCountWordOffset, RstCountWordOffset)

assign WordOffsetQ1 = ((LineQ1[8:2])*80 + CountWordOffsetQ1);
//align latency
`MSFF(CountBitOffsetQ2,  CountBitOffsetQ1,  CLK_25)
`MSFF(CountByteOffsetQ2, CountByteOffsetQ1, CLK_25)

assign CurentPixelQ2 = RdDataQ2[{CountByteOffsetQ2,CountBitOffsetQ2}];


//=========================
// VGA RAM
//=========================
`ifdef SIMULATION_ON
ram2port_sim ram2port_sim (
`else
ram2port ram2port (
`endif
	.clock     (CLK_25),
    //Write
	.data      (WrData),
	.wraddress (WrAddress),
	.wren      (WrEn),
	//Read
    .rdaddress (WordOffsetQ1),//Word offset (not Byte)
	.q         (RdDataQ2)
);

assign NextRED   = (inDisplayArea) ? {4{CurentPixelQ2}} : '0;
assign NextGREEN = (inDisplayArea) ? {4{CurentPixelQ2}} : '0;
assign NextBLUE  = (inDisplayArea) ? {4{CurentPixelQ2}} : '0;
`MSFF(RED    , NextRED     , CLK_25)
`MSFF(GREEN  , NextGREEN   , CLK_25)
`MSFF(BLUE   , NextBLUE    , CLK_25)
`MSFF(h_sync , next_h_sync , CLK_25)
`MSFF(v_sync , next_v_sync , CLK_25)

endmodule
