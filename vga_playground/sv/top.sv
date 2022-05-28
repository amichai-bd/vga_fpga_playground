`include "definitions.sv"
module top(
        input  logic        CLK_50,
        input  logic [3:0]  SW,
        input  logic [1:0]  BUTTON,

        output logic [6:0]  HEX0,
        output logic [6:0]  HEX1,
        output logic [6:0]  HEX2,
        output logic [6:0]  HEX3,
        output logic [6:0]  HEX4,
        output logic [6:0]  HEX5,
        output logic [9:0]  LED,

        output logic [3:0]  RED,
        output logic [3:0]  GREEN,
        output logic [3:0]  BLUE,
        output logic        h_sync,
        output logic        v_sync
    );

logic [9:0]  pixel_x;
logic [9:0]  pixel_y;
logic        Reset;
logic        CLK_25;
logic        inDisplayArea;
logic        next_h_sync;
logic        next_v_sync;
logic [3:0]  NextRED;
logic [3:0]  NextGREEN;
logic [3:0]  NextBLUE;
logic        CurentPixel;
 
assign Reset = ~BUTTON[0];
//    Y(480)   X(640)
logic [479:0] [0:639] Display;
always_comb begin   
    Display     = '0;
                    //         H          E          L            L           O          -           W           O           R           L           D           !        
    Display[100] = {8'b0,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
    Display[101] = {8'b0,8'b11001100,8'b11111100,8'b11000000,8'b11000000,8'b01111000,8'b00000000,8'b11000110,8'b01111000,8'b11111000,8'b11000000,8'b11110000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
    Display[102] = {8'b0,8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b00000000,8'b11000110,8'b11001100,8'b11001100,8'b11000000,8'b11001000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
    Display[103] = {8'b0,8'b11111100,8'b11111000,8'b11000000,8'b11000000,8'b11001100,8'b11111100,8'b11000110,8'b11001100,8'b11111000,8'b11000000,8'b11000100,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
    Display[104] = {8'b0,8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b11111100,8'b11010110,8'b11001100,8'b11010000,8'b11000000,8'b11000100,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
    Display[105] = {8'b0,8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b00000000,8'b11101110,8'b11001100,8'b11011000,8'b11000000,8'b11001000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
    Display[106] = {8'b0,8'b11001100,8'b11111100,8'b11111100,8'b11111100,8'b01111000,8'b00000000,8'b11000110,8'b01111000,8'b11001100,8'b11111100,8'b11110000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
    Display[107] = {8'b0,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
end

//ram2port ram2port (
//	.clock     (CLK_25),
//	.data      (),
//	.rdaddress (),
//	.wraddress (),
//	.wren      (),
//	.q         ()
//);

assign CurentPixel = Display[pixel_y[8:0]][pixel_x[9:0]];

//Only One or the other (FPGA_ON vs SIMULATION_ON )
`define FPGA_ON    
//`define SIMULATION_ON


//gen Clock 25Mhz
`ifdef SIMULATION_ON
    `RST_MSFF(CLK_25, !CLK_25, CLK_50, Reset)
`elsif FPGA_ON
pll_2 pll_2 (
    .inclk0 (CLK_50),    // input
    .c0     (CLK_25)     // output
); 
`endif

sync_gen sync_inst(
.CLK_25         (CLK_25),       //input
.Reset          (Reset),        //input
.vga_h_sync     (next_h_sync),  //output
.vga_v_sync     (next_v_sync),  //output
.CounterX       (pixel_x),      //output
.CounterY       (pixel_y),      //output
.inDisplayArea  (inDisplayArea) //output
);

assign NextRED   = (inDisplayArea && SW[0]) ? {4{CurentPixel}} : '0;
assign NextGREEN = (inDisplayArea && SW[1]) ? {4{CurentPixel}} : '0;
assign NextBLUE  = (inDisplayArea && SW[2]) ? {4{CurentPixel}} : '0;

`MSFF(RED    , NextRED     , CLK_25)
`MSFF(GREEN  , NextGREEN   , CLK_25)
`MSFF(BLUE   , NextBLUE    , CLK_25)
`MSFF(h_sync , next_h_sync , CLK_25)
`MSFF(v_sync , next_v_sync , CLK_25)



//Other FPGA Output
logic [6:0] HEX; 
seg7 seg7(
        .input_dig  (SW),
        .output_seg (HEX)
    );
assign HEX0 = HEX;
assign HEX1 = HEX;
assign HEX2 = HEX;
assign HEX3 = HEX;
assign HEX4 = HEX;
assign HEX5 = HEX;

always_comb begin
    LED = '0;
    LED[SW[2:0]] = 1'b1;
end

endmodule
