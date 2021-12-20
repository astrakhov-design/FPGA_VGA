`timescale 1ns / 1ns

module tb;

reg clk = 1'b0;
reg rst = 1'b0;

always #5 clk = ~clk;

wire        HSYNC;
wire        VSYNC;
wire [4:0]  RED_OUT;
wire [5:0]  GREEN_OUT;
wire [4:0]  BLUE_OUT;

vga_top #(
  .H_PIXELS(),
  .H_FRONTPORCH(),
  .H_SYNCTIME(),
  .H_BACKPORCH(),
  .V_LINES(),
  .V_FRONTPORCH(),
  .V_SYNCTIME(),
  .V_BACKPORCH(),
  .PIXEL_GEN_BITS(),
  .NUMBER_OF_COLUMNS()
  ) vga_top_dut (
    .clk_pll(clk),
    .rst(rst),
    .HSYNC(HSYNC),
    .VSYNC(VSYNC),
    .RED_OUT(RED_OUT),
    .GREEN_OUT(GREEN_OUT),
    .BLUE_OUT(BLUE_OUT)
  );

initial begin
  repeat(5) @ (posedge clk);
  rst = 1'b1;
  repeat(5) @ (posedge clk);
  rst = 1'b0;
  repeat(25_000_000) @ (posedge clk);
  $stop;
end

endmodule
