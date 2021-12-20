module top (
  input CLK,
  input RESET,

  output        HSYNC,
  output        VSYNC,
  output [4:0]  RED_OUT,
  output [5:0]  GREEN_OUT,
  output [4:0]  BLUE_OUT
);

wire clk_pll;

//insert here PLL module definition
/* pll_module pll_dut(
    .CLK(CLK),
    .CLK_OUT(clk_pll)
); */

//insert here parameter settings
//parameters for horisontal_sync
  localparam H_PIXELS          = 800;
  localparam H_FRONTPORCH      = 40;
  localparam H_SYNCTIME        = 128;
  localparam H_BACKPORCH       = 88;
//localparams for vertical_sync
  localparam V_LINES           = 600;
  localparam V_FRONTPORCH      = 1;
  localparam V_SYNCTIME        = 4;
  localparam V_BACKPORCH       = 23;
//bits of output pixel generator
  localparam PIXEL_GEN_BITS    = 12;
//number of output lines
  localparam NUMBER_OF_COLUMNS = 8;

//inplement vga_top module
  vga_top # (
    .H_PIXELS(H_PIXELS),
    .H_FRONTPORCH(H_FRONTPORCH),
    .H_SYNCTIME(H_SYNCTIME),
    .H_BACKPORCH(H_BACKPORCH),
    .V_LINES(V_LINES),
    .V_FRONTPORCH(V_FRONTPORCH),
    .V_SYNCTIME(V_SYNCTIME),
    .V_BACKPORCH(V_BACKPORCH),
    .PIXEL_GEN_BITS(PIXEL_GEN_BITS),
    .NUMBER_OF_COLUMNS(NUMBER_OF_COLUMNS)
  ) vga_top_module (
    .clk_pll(clk_pll),
    .rst(RESET),
    .HSYNC(HSYNC),
    .VSYNC(VSYNC),
    .RED_OUT(RED_OUT),
    .GREEN_OUT(GREEN_OUT),
    .BLUE_OUT(BLUE_OUT)
  );

endmodule //top
