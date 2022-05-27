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
 
assign reset = ~BUTTON[0];

  
sync_gen sync_inst(
.clk            (CLK_50),
.Reset          (reset),
.vga_h_sync     (h_sync),
.vga_v_sync     (v_sync),
.CounterX       (pixel_x),
.CounterY       (pixel_y),
.inDisplayArea  (inDisplayArea)
);

assign RED      =  (inDisplayArea && SW[0]) ? 4'b1111 : '0;
assign GREEN    =  (inDisplayArea && SW[1]) ? 4'b1111 : '0;
assign BLUE     =  (inDisplayArea && SW[2]) ? 4'b1111 : '0;

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
