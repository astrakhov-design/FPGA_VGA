module VGA_top(
	input clk,
	input rst,
	
	output hsync,
	output vsync,
	output [2:0] rgb
	);
	
	wire reset;
	assign reset = ~rst;
		
	reg [2:0] rgb_reg;
	wire video_on;
	
	wire [9:0] pix_x, pix_y;
		
	vga_sync vsync_uut(
		.clk(clk),
		.rst(reset),
		.hsync(hsync),
		.vsync(vsync),
		.video_on(video_on),
		.p_tick(),
		.pixel_x(pix_x),
		.pixel_y(pix_y)
	);
	
	//create wall
	wire wall_on;
	wire [2:0] wall_rgb;
	localparam WALL_X_L = 32;
	localparam WALL_X_R = 45;
	
	assign wall_on = (WALL_X_L <= pix_x) && (pix_x <= WALL_X_R);
	assign wall_rgb = 3'b001;
	
	//create bar
	localparam BAR_X_L = 450;
	localparam BAR_X_R = 500;
	
	localparam BAR_Y_SIZE = 50;
	localparam BAR_Y_T = 200;
	localparam BAR_Y_B = BAR_Y_T + BAR_Y_SIZE - 1;
	
	wire bar_on;
	wire [2:0] bar_rgb;
	assign bar_rgb = 3'b100;
	assign bar_on = (BAR_X_L <= pix_x) && (pix_x <= BAR_X_R) &&
					(BAR_Y_T <= pix_y) && (pix_y <= BAR_Y_B);
	
	reg [2:0] rgb_graph;
	
	always @*
	begin
		if (~video_on)
			rgb_graph = 3'b000;
		else
			if (wall_on)
				rgb_graph = wall_rgb;
			else if (bar_on)
				rgb_graph = bar_rgb;
			else
				rgb_graph = 3'b011;
	end
	
	assign rgb = rgb_graph;
	
endmodule