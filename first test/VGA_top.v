module VGA_top(
	input clk,
	input rst,
	
	input red_btnm,
	input green_btnm,
	input blue_btnm,
	
	output hsync,
	output vsync,
	output [2:0] rgb
	);
	
	wire reset;
	assign reset = ~rst;
	
	wire red_inv, green_inv, blue_inv;
	assign red_inv = red_btnm;
	assign green_inv = green_btnm;
	assign blue_inv = blue_btnm;
	
	reg [2:0] rgb_reg;
	wire video_on;
	
	vga_sync vsync_uut(
		.clk(clk),
		.rst(reset),
		.hsync(hsync),
		.vsync(vsync),
		.video_on(video_on),
		.p_tick(),
		.pixel_x(),
		.pixel_y()
	);
	
	
	always @ (posedge clk, posedge reset)
		begin
			if(reset)
				rgb_reg <= 0;
			else
				rgb_reg <= {red_inv, green_inv, blue_inv};
		end
		
	assign rgb = (video_on) ? rgb_reg : 3'b0;
	
endmodule