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
//Only One or the other (FPGA_ON vs SIMULATION_ON )
`ifndef SIMULATION_ON
    `define FPGA_ON    
`endif
logic        Reset;
assign Reset = ~BUTTON[0];
logic [31:0]    WrData;
logic [31:0]    RdDataQ2;
logic [12:0]    WrAddress;
logic           WrEn;
logic [4:0]     State;
logic [6:0]     HEX;
logic           CLK_25;
logic [4:0] SampleReset;
assign SampleReset[0] = Reset;
`MSFF(SampleReset[4:1], SampleReset[3:0], CLK_50)

`RST_MSFF(State, State+1, CLK_25, SampleReset[4])
always_comb begin
        WrData      = '0;
        WrAddress   = '0;
        WrEn        = '0;
unique casez (State)
    5'b000 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00110011;
        WrData[23:16] = 8'b00110011;
        WrData[31:24] = 8'b00111111;
        WrAddress   = 13'h1;
        WrEn        = 1'b1;
    end
    5'b001 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00111111;
        WrData[23:16] = 8'b00000011;
        WrData[31:24] = 8'b00011111;
        WrAddress   = 13'h2;
        WrEn        = 1'b1;
    end
    5'b010 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00000011;
        WrData[31:24] = 8'b00000011;
        WrAddress   = 13'h3;
        WrEn        = 1'b1;
    end
    5'b011 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00000011;
        WrData[31:24] = 8'b00000011;
        WrAddress   = 13'h4;
        WrEn        = 1'b1;
    end
    5'b100 : begin
        WrData[ 7: 0] = 8'b00000000;
        WrData[15: 8] = 8'b00011110;
        WrData[23:16] = 8'b00110011;
        WrData[31:24] = 8'b00110011;
        WrAddress   = 13'h5;
        WrEn        = 1'b1;
    end
    5'b101 : begin
        WrData[ 7: 0] = 8'b00110011;
        WrData[15: 8] = 8'b00110011;
        WrData[23:16] = 8'b00110011;
        WrData[31:24] = 8'b00000000;
        WrAddress   = 13'h51;
        WrEn        = 1'b1;
    end
    5'b110 : begin
        WrData[ 7: 0] = 8'b00000011;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00111111;
        WrData[31:24] = 8'b00000000;
        WrAddress   = 13'h52;
        WrEn        = 1'b1;
    end
    5'b111 : begin
        WrData[ 7: 0] = 8'b00000011;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00111111;
        WrData[31:24] = 8'b00000000;
        WrAddress   = 13'h53;
        WrEn        = 1'b1;
    end
    5'b1000 : begin
        WrData[ 7: 0] = 8'b00000011;
        WrData[15: 8] = 8'b00000011;
        WrData[23:16] = 8'b00111111;
        WrData[31:24] = 8'b00000000;
        WrAddress   = 13'h54;
        WrEn        = 1'b1;
    end
    5'b1001 : begin
        WrData[ 7: 0] = 8'b00110011;
        WrData[15: 8] = 8'b00110011;
        WrData[23:16] = 8'b00011110;
        WrData[31:24] = 8'b00000000;
        WrAddress   = 13'h55;
        WrEn        = 1'b1;
    end
    default : begin
        WrData      = '0;
        WrAddress   = '0;
        WrEn        = '0;
    end
endcase 
end //always_comb
vga_ctrl vga_ctrl(
    .CLK_50     (CLK_50),    //input  logic        
    .CLK_25     (CLK_25),    //input  logic        
    .Reset      (Reset),    //input  logic        
    .WrData     (WrData),    //input  logic [31:0] 
    .WrAddress  (WrAddress), //input  logic [12:0] 
    .WrEn       (WrEn),      //input  logic        
    //VGA Output
    .RED        (RED),       //output logic [3:0]
    .GREEN      (GREEN),     //output logic [3:0]
    .BLUE       (BLUE),      //output logic [3:0]
    .h_sync     (h_sync),    //output logic      
    .v_sync     (v_sync )    //output logic      
);


//=========================
//Other FPGA Output
//=========================
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
