//vga_top file
`include "vga_sync.v"
`include "vga_pixels.v"

module vga_top #(
//parameters for horisontal_sync
  parameter H_PIXELS          = 800,
  parameter H_FRONTPORCH      = 40,
  parameter H_SYNCTIME        = 128,
  parameter H_BACKPORCH       = 88,
//parameters for vertical_sync
  parameter V_LINES           = 600,
  parameter V_FRONTPORCH      = 1,
  parameter V_SYNCTIME        = 4,
  parameter V_BACKPORCH       = 23,
//bits of output pixel generator
  parameter PIXEL_GEN_BITS    = 12,
//number of output lines
  parameter NUMBER_OF_COLUMNS = 8
) (
  input clk_pll,
  input rst,

  output        HSYNC,
  output        VSYNC,
  output [4:0]  RED_OUT,
  output [5:0]  GREEN_OUT,
  output [4:0]  BLUE_OUT
);

wire [PIXEL_GEN_BITS-1:0] pixel_x;
wire                      video_on;

  vga_sync #(
    .H_PIXELS(H_PIXELS),
    .H_FRONTPORCH(H_FRONTPORCH),
    .H_SYNCTIME(H_SYNCTIME),
    .H_BACKPORCH(H_BACKPORCH),
    .V_LINES(V_LINES),
    .V_FRONTPORCH(V_FRONTPORCH),
    .V_SYNCTIME(V_SYNCTIME),
    .V_BACKPORCH(V_BACKPORCH),
    .PIXEL_GEN_BITS(PIXEL_GEN_BITS)
  ) vga_sync_mod (
    .clk(clk_pll),
    .rst(rst),
    .hsync(HSYNC),
    .vsync(VSYNC),
    .video_on(video_on),
    .pixel_x(pixel_x)
  );

  vga_pixels #(
    .H_PIXELS(H_PIXELS),
    .NUMBER_OF_COLUMNS(NUMBER_OF_COLUMNS),
    .PIXEL_GEN_BITS(PIXEL_GEN_BITS)
  ) vga_pixels_mod (
    .clk(clk_pll),
    .rst(rst),
    .pixel_x(pixel_x),
    .video_on(video_on),
    .RED_OUT(RED_OUT),
    .GREEN_OUT(GREEN_OUT),
    .BLUE_OUT(BLUE_OUT)
  );

endmodule
