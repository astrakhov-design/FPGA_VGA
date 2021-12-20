module vga_pixels #(
//monitor resolution (need only HORISONTAL)
  parameter H_PIXELS  =  800,
//number of output lines
  parameter NUMBER_OF_COLUMNS = 8,
//bits of output pixel generator
  parameter PIXEL_GEN_BITS  = 12
) (
  input clk,
  input rst,

//input signals from vga_sync module
  input [PIXEL_GEN_BITS-1:0]  pixel_x,
  input                       video_on,

//output RGB signals
  output [4:0]  RED_OUT,
  output [5:0]  GREEN_OUT,
  output [4:0]  BLUE_OUT
);

//set border of each column
localparam COLOR_BORDER = H_PIXELS / NUMBER_OF_COLUMNS;

//RGB code of colors
//  RED   GREEN  BLUE
// xxxxx_xxxxxx_xxxxx
localparam [15:0] WHITE       = 16'hFFFF;
localparam [15:0] BLACK       = 16'h0000;
localparam [15:0] RED         = 16'hF800;
localparam [15:0] GREEN       = 16'h07E0;
localparam [15:0] BLUE        = 16'h001F;
localparam [15:0] YELLOW      = 16'hFFE0;
localparam [15:0] VIOLET      = 16'hF81F;
localparam [15:0] GREY        = 16'h8BEF;
localparam [15:0] DARK_RED    = 16'h8800;
localparam [15:0] DARK_GREEN  = 16'h0380;
localparam [15:0] DARK_BLUE   = 16'h000F;

reg [PIXEL_GEN_BITS-1:0] border_cntr;
reg [15:0]               rgb_reg;

always @ (posedge clk, posedge rst) begin
  if(rst)
    border_cntr <=  0;
  else if(video_on && ((pixel_x % COLOR_BORDER) == 0))
    border_cntr <=  border_cntr + 1'b1;
  else if(!video_on)
    border_cntr <=  0;
end

//color of columns
//defines by user
always @ * begin
  case(border_cntr)
    0:  rgb_reg = WHITE;
    1:  rgb_reg = BLACK;
    2:  rgb_reg = RED;
    3:  rgb_reg = GREEN;
    4:  rgb_reg = GREY;
    5:  rgb_reg = VIOLET;
    6:  rgb_reg = DARK_RED;
    default:  rgb_reg = BLACK;
  endcase
end

assign RED_OUT    = rgb_reg[15:11];
assign GREEN_OUT  = rgb_reg[10:5];
assign BLUE_OUT   = rgb_reg[4:0];

endmodule
