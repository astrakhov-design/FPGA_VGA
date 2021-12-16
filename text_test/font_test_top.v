`include "font_test_gen.v"
`include "vga_sync.v"

module font_test_top(
	input clk, rst,
	output hsync, vsync,
	output [2:0] rgb
	);
	
	wire [9:0] pixel_x, pixel_y;
	wire video_on, pixel_tick;
	reg [2:0] rgb_reg;
	wire [2:0] rgb_next;
	
	vga_sync vsync_unit(
		.clk(clk),
		.rst(~rst),
		.hsync(hsync),
		.vsync(vsync),
		.video_on(video_on),
		.p_tick(pixel_tick),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y)
	);
	
	font_test_gen font_gen_unit(
		.clk(clk),
		.video_on(video_on),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y),
		.rgb_text(rgb_next)
	);
	
	always @ (posedge clk)
		if (pixel_tick)
			rgb_reg <= rgb_next;
	
	assign rgb = rgb_reg;
	
endmodule
	