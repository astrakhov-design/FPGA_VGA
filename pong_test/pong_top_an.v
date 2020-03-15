//took from FPGA Prototyping by Verilog Examples
//Author: Pong P. Chu

module pong_top_an(
	input clk, rst,
	input [3:0] btnm,
	output hsync, vsync,
	output [2:0] rgb
	);
	
	wire [9:0] pixel_x, pixel_y;
	wire video_on, pixel_tick;
	reg [2:0] rgb_reg;
	wire [2:0] rgb_next;
	
	//sync reset
	reg reset;
	
	always @ (posedge clk)
	begin
		reset <= ~rst;
	end
	
	wire [3:0] btn;
	assign btn = ~btnm;
	
	//body
	//instatiate VGA sync circuit
	vga_sync v_sync_unit(
		.clk(clk),
		.rst(reset),
		.hsync(hsync),
		.vsync(vsync),
		.video_on(video_on),
		.p_tick(pixel_tick),
		.pixel_x(pixel_x),
		.pixel_y(pixel_y)
	);
	
	//instatiate graphic generator
	pong_graph_animate pong_graph_animate_unit(
		.clk(clk),
		.rst(reset),
		.btnm(btn),
		.video_on(video_on),
		.pix_x(pixel_x),
		.pix_y(pixel_y),
		.graph_rgb(rgb_next)
	);
	
	always @ (posedge clk)
	begin
		if (pixel_tick)
			rgb_reg <= rgb_next;
	end

	assign rgb = rgb_reg;
	
endmodule
