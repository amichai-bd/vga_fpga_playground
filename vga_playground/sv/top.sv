`include "definitions.sv"
module top(
        input  logic        CLK_50,
        input  logic [3:0]  SW,
        input  logic [1:0]  BUTTON,

        output logic [6:0]  HEX0,
        output logic [6:0]  HEX1,
        output logic [6:0]  HEX2,
        output logic [9:0]  LED,

        output logic [3:0]  RED,
        output logic [3:0]  GREEN,
        output logic [3:0]  BLUE,
        output logic        h_sync,
        output logic        v_sync
    );

logic [9:0]             pixel_x;
logic [9:0]             pixel_y;
logic                   reset;
logic                   inDisplayArea;
 
assign reset = ~BUTTON[0];

logic [15:0] [0:127] Display;
always_comb begin   //  0 H        1 E          2 L         3 L         4 O         5 -         6 W         7 O         8 R         9 L         10 D        11 !         12          13          14          15
    Display[0] = {8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b0000000,8'b000000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    Display[1] = {8'b11001100,8'b11111100,8'b11000000,8'b11000000,8'b01111000,8'b0000000,8'b110001100,8'b01111000,8'b11111000,8'b11000000,8'b11110000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    Display[2] = {8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b0000000,8'b110001100,8'b11001100,8'b11001100,8'b11000000,8'b11001000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    Display[3] = {8'b11111100,8'b11111000,8'b11000000,8'b11000000,8'b11001100,8'b1111100,8'b110001100,8'b11001100,8'b11111000,8'b11000000,8'b11000100,8'b11000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    Display[4] = {8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b1111100,8'b110101100,8'b11001100,8'b11010000,8'b11000000,8'b11000100,8'b11000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    Display[5] = {8'b11001100,8'b11000000,8'b11000000,8'b11000000,8'b11001100,8'b0000000,8'b111011100,8'b11001100,8'b11001000,8'b11000000,8'b11001000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    Display[6] = {8'b11001100,8'b11111100,8'b11111100,8'b11111100,8'b01111000,8'b0000000,8'b110001100,8'b01111000,8'b11000100,8'b11111100,8'b11110000,8'b11000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    Display[7] = {8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b0000000,8'b000000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000};
    //
    Display[8]  = '0;
    Display[9]  = '0;
    Display[10] = '0;
    Display[11] = '0;
    Display[12] = '0;
    Display[13] = '0;
    Display[14] = '0;
    Display[15] = '0;
end
sync_gen sync_inst(
.clk            (CLK_50),
.Reset          (reset),
.vga_h_sync     (h_sync),
.vga_v_sync     (v_sync),
.CounterX       (pixel_x),
.CounterY       (pixel_y),
.inDisplayArea  (inDisplayArea)
);

assign RED      =  (inDisplayArea && SW[0]) ? {4{Display[pixel_y[3:0]][pixel_x[6:0]]}} : '0;
assign GREEN    =  (inDisplayArea && SW[1]) ? {4{Display[pixel_y[3:0]][pixel_x[6:0]]}} : '0;
assign BLUE     =  (inDisplayArea && SW[2]) ? {4{Display[pixel_y[3:0]][pixel_x[6:0]]}} : '0;


logic [6:0] HEX; 
seg7 seg7(
        .input_dig  (SW),
        .output_seg (HEX)
    );
assign HEX0 = HEX;
assign HEX1 = HEX;
assign HEX2 = HEX;

always_comb begin
   LED = '0;
   LED[SW[2:0]] = 1'b1;
end

endmodule
