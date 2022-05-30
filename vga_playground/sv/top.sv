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

logic [9:0]  pixel_x, pixel_xQ1, pixel_xQ2;
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

logic [38399:0][0:7] PMem ;
logic [8:0]          LineQ0;
logic [8:0]          LineQ1;
logic [15:0]         VAdrsQ0;
logic [15:0]         VAdrsQ1;
logic [15:0]         PAdrsQ1;
logic [15:0]         PAdrsQ2;
logic [2:0]          PAdrsOffsetQ2;

assign LineQ0   = pixel_y[8:0];
assign VAdrsQ0  = 80*LineQ0 + pixel_x[9:3];  
`MSFF( VAdrsQ1   , VAdrsQ0   , CLK_25)
`MSFF( pixel_xQ1 , pixel_x   , CLK_25)
`MSFF( pixel_xQ2 , pixel_xQ1 , CLK_25)
`MSFF( LineQ1    , LineQ0    , CLK_25)

assign PAdrsQ1 = (LineQ1/4)*320+(VAdrsQ1-(80*LineQ1))*4+(LineQ1%4);  
`MSFF(PAdrsQ2    , PAdrsQ1     , CLK_25)

assign PAdrsOffsetQ2  =  pixel_xQ2[2:0];
always_comb begin
    PMem          = '0;
    PMem[4   + 0] = 8'b00000000;
    PMem[5   + 0] = 8'b11001100;
    PMem[6   + 0] = 8'b11001100;
    PMem[7   + 0] = 8'b11111100;
    PMem[324 + 0] = 8'b11001100;
    PMem[325 + 0] = 8'b11001100;
    PMem[326 + 0] = 8'b11001100;
    PMem[327 + 0] = 8'b00000000;
    PMem[4   + 4] = 8'b00000000;
    PMem[5   + 4] = 8'b11111100;
    PMem[6   + 4] = 8'b11000000;
    PMem[7   + 4] = 8'b11111000;
    PMem[324 + 4] = 8'b11000000;
    PMem[325 + 4] = 8'b11000000;
    PMem[326 + 4] = 8'b11111100;
    PMem[327 + 4] = 8'b00000000;
    PMem[4   + 8] = 8'b00000000;
    PMem[5   + 8] = 8'b11000000;
    PMem[6   + 8] = 8'b11000000;
    PMem[7   + 8] = 8'b11000000;
    PMem[324 + 8] = 8'b11000000;
    PMem[325 + 8] = 8'b11000000;
    PMem[326 + 8] = 8'b11111100;
    PMem[327 + 12]= 8'b00000000;
    PMem[4   + 12]= 8'b00000000;
    PMem[5   + 12]= 8'b11000000;
    PMem[6   + 12]= 8'b11000000;
    PMem[7   + 12]= 8'b11000000;
    PMem[324 + 12]= 8'b11000000;
    PMem[325 + 12]= 8'b11000000;
    PMem[326 + 12]= 8'b11111100;
    PMem[327 + 12]= 8'b00000000;
    PMem[4   + 16]= 8'b00000000;
    PMem[5   + 16]= 8'b01111000;
    PMem[6   + 16]= 8'b11001100;
    PMem[7   + 16]= 8'b11001100;
    PMem[324 + 16]= 8'b11001100;
    PMem[325 + 16]= 8'b11001100;
    PMem[326 + 16]= 8'b01111000;
    PMem[327 + 16]= 8'b00000000;
end

assign CurentPixel = PMem[PAdrsQ2][PAdrsOffsetQ2];

//ram2port ram2port (
//	.clock     (CLK_25),
//	.data      (),
//	.rdaddress (),
//	.wraddress (),
//	.wren      (),
//	.q         ()
//);


//Only One or the other (FPGA_ON vs SIMULATION_ON )
`ifndef SIMULATION_ON
    `define FPGA_ON    
`endif


logic [4:0] SampleReset;
assign SampleReset[0] = Reset;
`MSFF(SampleReset[4:1], SampleReset[3:0], CLK_50)
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
.Reset          (SampleReset[4]),//input
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
////    Y(480)   X(640)
//logic [479:0] [0:639] Display;
//always_comb begin   
//    Display     = '0;
//                    //         H          E          L            L           O          -           W           O           R           L           D           !        
//    Display[0] = {8'b0,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//    Display[1] = {8'b0,8'b11001100,8'b11111100,8'b11000000,8'b11000000,8'b01111000,8'b00000000,8'b11000110,8'b01111000,8'b11111000,8'b11000000,8'b11110000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//    Display[2] = {8'b0,8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b00000000,8'b11000110,8'b11001100,8'b11001100,8'b11000000,8'b11001000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//    Display[3] = {8'b0,8'b11111100,8'b11111000,8'b11000000,8'b11000000,8'b11001100,8'b11111100,8'b11000110,8'b11001100,8'b11111000,8'b11000000,8'b11000100,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//    Display[4] = {8'b0,8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b11111100,8'b11010110,8'b11001100,8'b11010000,8'b11000000,8'b11000100,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//    Display[5] = {8'b0,8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b00000000,8'b11101110,8'b11001100,8'b11011000,8'b11000000,8'b11001000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//    Display[6] = {8'b0,8'b11001100,8'b11111100,8'b11111100,8'b11111100,8'b01111000,8'b00000000,8'b11000110,8'b01111000,8'b11001100,8'b11111100,8'b11110000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//    Display[7] = {8'b0,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,512'b0};
//end