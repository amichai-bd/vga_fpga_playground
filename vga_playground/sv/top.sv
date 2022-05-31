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

logic [360:0][0:7] PMem ;
logic [8:0]          LineQ0;
logic [8:0]          LineQ1;
logic [15:0]         VAdrsQ0;
logic [15:0]         VAdrsQ1;
logic [15:0]         PAdrsQ1;
logic [15:0]         PAdrsQ2;
logic [15:0]         PAdrsQ3;
logic [13:0]         PAdrsWordQ3;
logic [2:0]          PAdrsBitOffsetQ2;
logic [2:0]          PAdrsBitOffsetQ3;
logic [2:0]          PAdrsBitOffsetQ4;
logic CurentPixelReference;
logic [7:0] PMemByte;
logic CurentPixelReference2;
assign LineQ0   = pixel_y[8:0];
assign VAdrsQ0  = 80*LineQ0 + pixel_x[9:3];  
`MSFF( VAdrsQ1   , VAdrsQ0   , CLK_25)
`MSFF( pixel_xQ1 , pixel_x   , CLK_25)
`MSFF( pixel_xQ2 , pixel_xQ1 , CLK_25)
`MSFF( LineQ1    , LineQ0    , CLK_25)

assign PAdrsQ1 = (LineQ1/4)*320+(VAdrsQ1-(80*LineQ1))*4+(LineQ1%4);  
`MSFF(PAdrsQ2    , PAdrsQ1     , CLK_25)
`MSFF(PAdrsQ3    , PAdrsQ2     , CLK_25)
assign PAdrsWordQ3 = PAdrsQ3[15:2];

assign PAdrsBitOffsetQ2  = pixel_xQ2[2:0];
logic [1:0] PAdrsByteOffsetQ2;
logic [1:0] PAdrsByteOffsetQ3;
logic [1:0] PAdrsByteOffsetQ4;
assign PAdrsByteOffsetQ2 = PAdrsQ2[1:0];
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
assign CurentPixelReference  = PMem[PAdrsQ2][PAdrsBitOffsetQ2];
//assign PMemByte              = PMem[PAdrsQ2];
//assign CurentPixelReference2 = PMemByte[PAdrsBitOffsetQ2];


logic [31:0] WrData;
logic [31:0] RdDataQ4;
logic [13:0] WrAddressQ2;
//assign WrAddressQ2 =   PAdrsQ2[15:2]; 
logic [4:0] State;
logic WrEn;
logic [4:0] SampleReset;
`RST_MSFF(State, State+1, CLK_25, SampleReset[4])
always_comb begin
        WrData      = '0;
        WrAddressQ2 = '0;
        WrEn        = '0;
unique casez (State)
    5'b000 : begin
        WrData      = {PMem[7],PMem[6],PMem[5],PMem[4]};
        WrAddressQ2 = 12'h1;
        WrEn        = 1'b1;
    end
    5'b001 : begin
        WrData      = {PMem[11],PMem[10],PMem[9],PMem[8]};
        WrAddressQ2 = 12'h2;
        WrEn        = 1'b1;
    end
    5'b010 : begin
        WrData      = {PMem[15],PMem[14],PMem[13],PMem[12]};
        WrAddressQ2 = 12'h3;
        WrEn        = 1'b1;
    end
    5'b011 : begin
        WrData      = {PMem[19],PMem[18],PMem[17],PMem[16]};
        WrAddressQ2 = 12'h4;
        WrEn        = 1'b1;
    end
    5'b100 : begin
        WrData      = {PMem[23],PMem[22],PMem[21],PMem[20]};
        WrAddressQ2 = 12'h5;
        WrEn        = 1'b1;
    end
    5'b101 : begin
        WrData      = {PMem[327],PMem[326],PMem[325],PMem[324]};
        WrAddressQ2 = 12'h51;
        WrEn        = 1'b1;
    end
    5'b110 : begin
        WrData      = {PMem[331],PMem[330],PMem[329],PMem[328]};
        WrAddressQ2 = 12'h52;
        WrEn        = 1'b1;
    end
    5'b111 : begin
        WrData      = {PMem[335],PMem[334],PMem[333],PMem[332]};
        WrAddressQ2 = 12'h53;
        WrEn        = 1'b1;
    end
    5'b1000 : begin
        WrData      = {PMem[339],PMem[338],PMem[337],PMem[336]};
        WrAddressQ2 = 12'h54;
        WrEn        = 1'b1;
    end
    5'b1001 : begin
        WrData      = {PMem[343],PMem[342],PMem[341],PMem[340]};
        WrAddressQ2 = 12'h55;
        WrEn        = 1'b1;
    end
    default : begin
        WrData      = '0;
        WrAddressQ2 = '0;
        WrEn        = '0;
    end

endcase 

end

//assign WrData = {PMem[PAdrsQ2+3],PMem[PAdrsQ2+2],PMem[PAdrsQ2+1],PMem[PAdrsQ2+0]};
//assign WrEn = 1'b1;
`ifdef SIMULATION_ON
ram2port_sim ram2port_sim (
`else
ram2port ram2port (
`endif
	.clock     (CLK_25),
    //Write
	.data      (WrData),
	.wraddress (WrAddressQ2),
	.wren      (WrEn),
	//Read
    .rdaddress (PAdrsWordQ3),//Word offset (not Byte)
	.q         (RdDataQ4)
);
`MSFF(PAdrsBitOffsetQ3,  PAdrsBitOffsetQ2,  CLK_50)
`MSFF(PAdrsBitOffsetQ4,  PAdrsBitOffsetQ3,  CLK_50)
`MSFF(PAdrsByteOffsetQ3, PAdrsByteOffsetQ2, CLK_50)
`MSFF(PAdrsByteOffsetQ4, PAdrsByteOffsetQ3, CLK_50)
assign CurentPixel = RdDataQ4[{PAdrsByteOffsetQ4,PAdrsBitOffsetQ4}];


//Only One or the other (FPGA_ON vs SIMULATION_ON )
`ifndef SIMULATION_ON
    `define FPGA_ON    
`endif


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

logic Final;
assign Final = SW[3] ? CurentPixel : CurentPixelReference;
assign NextRED   = (inDisplayArea && SW[0]) ? {4{Final}} : '0;
assign NextGREEN = (inDisplayArea && SW[1]) ? {4{Final}} : '0;
assign NextBLUE  = (inDisplayArea && SW[2]) ? {4{Final}} : '0;

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