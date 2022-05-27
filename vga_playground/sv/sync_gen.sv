`include "definitions.sv"
module sync_gen(
        input  logic        clk,
        input  logic        Reset,
        output logic        vga_h_sync,
        output logic        vga_v_sync,
        output logic        inDisplayArea,
        output logic  [9:0] CounterX,
        output logic  [9:0] CounterY
    );
    
//=======================================//
//				  Clock Divider				  //
//=======================================//
//VGA @ 640x480 resolution @ 60Hz requires a pixel clock of 25.175Mhz.
//The Kiwi has an Onboard 50Mhz oscillator, we can divide it and get a 25Mhz clock.
//It's not the exact frequency required for the VGA standard, but it works fine and it saves us the use of a PLL.
logic clkdiv;
logic h_sync, v_sync;
logic next_h_sync, next_v_sync;
logic CounterXmaxed, CounterYmaxed;
logic NextinDisplayArea;
//gen Clock 25Mhz
`RST_MSFF(clkdiv, !clkdiv, clk, Reset)
assign CounterXmaxed = (CounterX == 800); // 16 + 48 + 96 + 640
assign CounterYmaxed = (CounterY == 525); // 10 + 2 + 33 + 480

//x and y counters
`RST_MSFF   (CounterX, (CounterX+1'b1), clkdiv, CounterXmaxed)
`EN_RST_MSFF(CounterY, (CounterY+1'b1), clkdiv, CounterXmaxed, (CounterXmaxed && CounterYmaxed) )

assign next_h_sync = (CounterX >= (640 + 16) && (CounterX < (640 + 16 + 96)));   // active for 96 clocks
assign next_v_sync = (CounterY >= (480 + 10) && (CounterY < (480 + 10 + 2)));   // active for 2 clocks
`MSFF(h_sync, next_h_sync, clkdiv)
`MSFF(v_sync, next_v_sync, clkdiv)

//Indication that we must not send Data in VGA RGB
assign NextinDisplayArea = ((CounterX < 640) && (CounterY < 480));
`MSFF(inDisplayArea, NextinDisplayArea, clkdiv)

assign vga_h_sync = ~h_sync;
assign vga_v_sync = ~v_sync;

endmodule
