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

//logic [360:0][0:7] PMem ;
logic [8:0]          LineQ0;
logic [8:0]          LineQ1;
logic [15:0]         VAdrsQ0;
logic [15:0]         VAdrsQ1;
logic [15:0]         PAdrsQ1;
logic [15:0]         PAdrsQ2;
logic [15:0]         PAdrsQ3;
logic [12:0]         PAdrsWordQ3;
logic [2:0]          PAdrsBitOffsetQ2;
logic [2:0]          PAdrsBitOffsetQ3;
logic [2:0]          PAdrsBitOffsetQ4;
logic CurentPixelReference;
logic [7:0] PMemByte;
logic CurentPixelReference2;
logic [1:0] PAdrsByteOffsetQ2;
logic [1:0] PAdrsByteOffsetQ3;
logic [1:0] PAdrsByteOffsetQ4;
logic [31:0] WrData;
logic [31:0] RdDataQ4;
logic [12:0] WrAddressQ2;
logic [4:0] State;
logic WrEn;
logic [4:0] SampleReset;
logic Final;
logic [6:0] HEX; 


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
assign PAdrsByteOffsetQ2 = PAdrsQ2[1:0];
assign CurentPixelReference  ='0;// PMem[PAdrsQ2][PAdrsBitOffsetQ2];



`RST_MSFF(State, State+1, CLK_25, SampleReset[4])
always_comb begin
        WrData      = '0;
        WrAddressQ2 = '0;
        WrEn        = '0;
unique casez (State)
    5'b000 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00110011;
        WrData[23:16] = 8'b00110011;
        WrData[31:24] = 8'b00111111;
        WrAddressQ2 = 13'h1;
        WrEn        = 1'b1;
    end
    5'b001 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00111111;
        WrData[23:16] = 8'b00000011;
        WrData[31:24] = 8'b00011111;
        WrAddressQ2 = 13'h2;
        WrEn        = 1'b1;
    end
    5'b010 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00000011;
        WrData[31:24] = 8'b00000011;
        WrAddressQ2 = 13'h3;
        WrEn        = 1'b1;
    end
    5'b011 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00000011;
        WrData[31:24] = 8'b00000011;
        WrAddressQ2 = 13'h4;
        WrEn        = 1'b1;
    end
    5'b100 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00011110;
        WrData[23:16] = 8'b00110011;
        WrData[31:24] = 8'b00110011;
        WrAddressQ2 = 13'h5;
        WrEn        = 1'b1;
    end
    5'b101 : begin
        WrData[ 7: 0] = 8'b00110011;
        WrData[15: 8] = 8'b00110011;
        WrData[23:16] = 8'b00110011;
        WrData[31:24] = 8'b00000000;
        WrAddressQ2 = 13'h51;
        WrEn        = 1'b1;
    end
    5'b110 : begin
        WrData[ 7: 0] = 8'b00000011;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00111111;
        WrData[31:24] = 8'b00000000;
        WrAddressQ2 = 13'h52;
        WrEn        = 1'b1;
    end
    5'b111 : begin
        WrData[ 7: 0] = 8'b00000011;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00111111;
        WrData[31:24] = 8'b00000000;
        WrAddressQ2 = 13'h53;
        WrEn        = 1'b1;
    end
    5'b1000 : begin
        WrData[ 7: 0] = 8'b00000011;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00111111;
        WrData[31:24] = 8'b00000000;
        WrAddressQ2 = 13'h54;
        WrEn        = 1'b1;
    end
    5'b1001 : begin
        WrData[ 7: 0] = 8'b00110011;
        WrData[15: 8] = 8'b00110011;
        WrData[23:16] = 8'b00011110;
        WrData[31:24] = 8'b00000000;
        WrAddressQ2 = 13'h55;
        WrEn        = 1'b1;
    end
    default : begin
        WrData      = '0;
        WrAddressQ2 = '0;
        WrEn        = '0;
    end

endcase 

end

logic [12:0]WordOffset;
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
    ///.rdaddress (PAdrsWordQ3),//Word offset (not Byte)
    .rdaddress (WordOffset),//Word offset (not Byte)
	.q         (RdDataQ4)
);
`MSFF(PAdrsBitOffsetQ3,  PAdrsBitOffsetQ2,  CLK_25)
`MSFF(PAdrsBitOffsetQ4,  PAdrsBitOffsetQ3,  CLK_25)
`MSFF(PAdrsByteOffsetQ3, PAdrsByteOffsetQ2, CLK_25)
`MSFF(PAdrsByteOffsetQ4, PAdrsByteOffsetQ3, CLK_25)
//assign CurentPixel = RdDataQ4[{PAdrsByteOffsetQ4,PAdrsBitOffsetQ4}];

logic [2:0] CountBitOffset, CountBitOffsetQ2 ;
logic [1:0] CountByteOffset, CountByteOffsetQ2;
logic [7:0] CountWordOffset;
logic       EnCountBitOffset,  EnCountByteOffset,  EnCountWordOffset ;
logic       RstCountBitOffset, RstCountByteOffset, RstCountWordOffset;

assign EnCountBitOffset   = 1'b1;
assign EnCountByteOffset  = ((CountWordOffset == 79) && EnCountWordOffset);
assign EnCountWordOffset  = (CountBitOffset == 3'b111);
assign RstCountBitOffset  = SampleReset[4] || (!inDisplayArea);
assign RstCountByteOffset = SampleReset[4];
assign RstCountWordOffset = SampleReset[4] || ((CountWordOffset == 79) && EnCountWordOffset);
`EN_RST_MSFF(CountBitOffset , (CountBitOffset +1), CLK_25, EnCountBitOffset , RstCountBitOffset )
`EN_RST_MSFF(CountByteOffset, (CountByteOffset+1), CLK_25, EnCountByteOffset, RstCountByteOffset)
`EN_RST_MSFF(CountWordOffset, (CountWordOffset+1), CLK_25, EnCountWordOffset, RstCountWordOffset)
assign WordOffset = ((LineQ1[8:2])*80 + CountWordOffset);
`MSFF(CountBitOffsetQ2,  CountBitOffset,  CLK_25)
`MSFF(CountByteOffsetQ2, CountByteOffset, CLK_25)

assign CurentPixel = RdDataQ4[{CountByteOffsetQ2,CountBitOffsetQ2}];



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
