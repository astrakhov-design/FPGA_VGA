`include "LCD_character_bitmap.v"

module font_test_gen(
	input clk,
	input video_on,
	input [9:0] pixel_x, pixel_y,

	output reg [2:0] rgb_text
	);

	wire [9:0] rom_addr;
	wire [6:0] char_addr;
	wire [3:0] row_addr;
	wire [2:0] bit_addr;
	wire [7:0] font_word;
	wire font_bit, text_bit_on;

	LCD_character_bitmap font_unit(
		.clk(clk),
		.addr(rom_addr),
		.data(font_word));

	assign char_addr = {pixel_y[5:4], pixel_x[7:4]};
	assign row_addr = pixel_y[3:0];
	assign rom_addr = {char_addr, row_addr};
	assign bit_addr = pixel_x[2:0];

	assign font_bit = font_word[~bit_addr];
	assign text_bit_on = (pixel_x[9:8] == 0 && pixel_y[9:6] ==0) ?
							font_bit : 1'b0;

	always @*
		if(~video_on)
			rgb_text = 3'b000;
		else
			if (text_bit_on)
				rgb_text = 3'b111;
			else
				rgb_text = 3'b000;

endmodule
