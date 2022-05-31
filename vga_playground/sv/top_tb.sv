`include "definitions.sv"
module top_tb ();
    logic Clock;
    logic Reset;
// clock generation
initial begin: clock_gen
    forever begin
        #5 Clock = 1'b0;
        #5 Clock = 1'b1;
    end
end: clock_gen

// reset generation
initial begin: reset_gen
    Reset = 1'b1;
#40 Reset = 1'b0;
#1000000 $finish;
end: reset_gen

logic [1:0] BUTTON;
assign BUTTON = {2{~Reset}};
top top (
        .CLK_50(Clock),   //input  logic        CLK_50,
        .SW('1),      //input  logic [3:0]  SW,
        .BUTTON(BUTTON),  //input  logic [1:0]  BUTTON,
        .HEX0(),        //output logic [6:0]  HEX0,
        .HEX1(),        //output logic [6:0]  HEX1,
        .HEX2(),        //output logic [6:0]  HEX2,
        .HEX3(),        //output logic [6:0]  HEX3,
        .HEX4(),        //output logic [6:0]  HEX4,
        .HEX5(),        //output logic [6:0]  HEX5,
        .LED(),        //output logic [9:0]  LED,
        .RED(),        //output logic [3:0]  RED,
        .GREEN(),        //output logic [3:0]  GREEN,
        .BLUE(),        //output logic [3:0]  BLUE,
        .h_sync(),        //output logic        h_sync,
        .v_sync()         //output logic        v_sync
    );

endmodule
