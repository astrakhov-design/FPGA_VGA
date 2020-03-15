//took from FPGA Prototyping By Verilog Examples
//Author: Pong P. Chu

//modified for two players

module pong_graph_animate(
	input clk, rst,
	input video_on,
	input [3:0] btnm,
	input [9:0] pix_x, pix_y,
	
	output reg [2:0] graph_rgb
	);
	
	localparam MAX_X = 640;
	localparam MAX_Y = 480;
	wire refr_tick;
	
	//left bar, right boundary
	localparam LEFT_BAR_X_L = 32;
	localparam LEFT_BAR_X_R = 35;
	wire [9:0] left_bar_y_t, left_bar_y_b;
	
	//right vertical bar
	//----------------------------
	
	//bar left, right boundary
	localparam RIGHT_BAR_X_L = 600;
	localparam RIGHT_BAR_X_R = 603;
	//bar top, bottom boundary
	wire [9:0] right_bar_y_t, right_bar_y_b;
	localparam BAR_Y_SIZE = 72;
	
	// register to track top boundary (x position is fixed)
	reg [9:0] right_bar_y_reg, right_bar_y_next;
	reg [9:0] left_bar_y_reg, left_bar_y_next;
	// bar moving velocity when a button is pressed
	localparam BAR_V = 4;
	
	//--------------------------------
	//square ball
	//--------------------------------
	
	localparam BALL_SIZE = 8;
	//ball left, right boundary
	wire [9:0] ball_x_l, ball_x_r;
	//ball top, bottom boundary
	wire [9:0] ball_y_t, ball_y_b;
	//reg to track left, top position
	reg [9:0] ball_x_reg, ball_y_reg;
	wire [9:0] ball_x_next, ball_y_next;
	//reg to track ball speed
	reg [9:0] x_delta_reg, x_delta_next;
	reg [9:0] y_delta_reg, y_delta_next;
	//ball velocity can be positive or negative
	localparam BALL_V_P = 1;
	localparam BALL_V_N = -1;
	
	//--------------------------------
	//round ball
	//--------------------------------
	wire [2:0] rom_addr, rom_col;
	reg [7:0] rom_data;
	wire rom_bit;
	
	//--------------------------------
	// object output signals
	//--------------------------------
	wire left_bar_on, right_bar_on, sq_ball_on, rd_ball_on;
	wire [2:0] left_bar_rgb, right_bar_rgb, ball_rgb;
	
	//main body
	//--------------------------------
	//round ball image ROM
	//--------------------------------
	always @*
	case(rom_addr)
		3'h0:	rom_data	= 8'b00_1111_00; //  ****
		3'h1:	rom_data	= 8'b01_1111_10; // ******
		3'h2:	rom_data	= 8'b11_1111_11; //********
		3'h3:	rom_data	= 8'b11_1111_11; //********
		3'h4:	rom_data	= 8'b11_1111_11; //********
		3'h5:	rom_data	= 8'b11_1111_11; //********
		3'h6:	rom_data	= 8'b01_1111_10; // ******
		3'h7:	rom_data	= 8'b00_1111_00; //  ****
	endcase
	
	//registers
	always @ (posedge clk, posedge rst)
	begin
		if(rst)
			begin
				left_bar_y_reg <= 0;
				right_bar_y_reg	<= 0;
				ball_x_reg	<= 0;
				ball_y_reg	<= 0;
				x_delta_reg	<= 10'h004;
				y_delta_reg <= 10'h004;
			end
		else
			begin
				left_bar_y_reg <= left_bar_y_next;
				right_bar_y_reg	<= right_bar_y_next;
				ball_x_reg	<= ball_x_next;
				ball_y_reg	<= ball_y_next;
				x_delta_reg <= x_delta_next;
				y_delta_reg <= y_delta_next;
			end
	end
	
	//refr_tick: l-clock tick asserted at start of v-sync
	//		i.e., when the screen is refteshed (60 Hz)
	assign refr_tick  = (pix_y == 481) && (pix_x == 0);
	
	//---------------------------
	// left vertical bar
	//---------------------------
	assign left_bar_y_t = left_bar_y_reg;
	assign left_bar_y_b = left_bar_y_t + BAR_Y_SIZE - 1;
	//pixel within left bar
	assign left_bar_on = (LEFT_BAR_X_L <= pix_x) && (pix_x <= LEFT_BAR_X_R) &&
					(left_bar_y_t <= pix_y) && (pix_y <= left_bar_y_b);
	//left bar rgb output
	assign left_bar_rgb = 3'b001; //blue
	
	//--------------------------
	//right vertical bar
	//--------------------------
	//boundary
	assign right_bar_y_t = right_bar_y_reg;
	assign right_bar_y_b = right_bar_y_t + BAR_Y_SIZE - 1;
	//pixel within right bar
	assign right_bar_on = (RIGHT_BAR_X_L <= pix_x) && (pix_x <= RIGHT_BAR_X_R) &&
					(right_bar_y_t <= pix_y) && (pix_y <= right_bar_y_b);
	//right bar rgb output
	assign right_bar_rgb = 3'b010;	//green
	
	//new left bar y-position
	always @*
	begin
		left_bar_y_next = left_bar_y_reg; //no move
		if (refr_tick)
			if (btnm[3] & (left_bar_y_b < (MAX_Y - 1 - BAR_V)))
				left_bar_y_next = left_bar_y_reg + BAR_V; // move down left bar
			else if (btnm[2] & (left_bar_y_t > BAR_V))
				left_bar_y_next = left_bar_y_reg - BAR_V; // move up left bar
	end
	
	//new right bar y-position
	always @*
	begin
		right_bar_y_next = right_bar_y_reg; //no move
		if (refr_tick)
			if (btnm[1] & (right_bar_y_b < (MAX_Y - 1 - BAR_V)))
				right_bar_y_next = right_bar_y_reg + BAR_V; //move down
			else if (btnm[0] & (right_bar_y_t > BAR_V))
				right_bar_y_next = right_bar_y_reg - BAR_V; //move up
	end
	
	//------------------------
	//square ball
	//------------------------
	//boundary
	assign ball_x_l = ball_x_reg;
	assign ball_y_t = ball_y_reg;
	assign ball_x_r = ball_x_l + BALL_SIZE - 1;
	assign ball_y_b = ball_y_t + BALL_SIZE - 1;
	//pixel within ball
	assign sq_ball_on = 
				(ball_x_l <= pix_x) && (pix_x <= ball_x_r) &&
				(ball_y_t <= pix_y) && (pix_y <= ball_y_b);
	//map current pixel location to ROM address/column
	assign rom_addr = pix_y[2:0] - ball_y_t[2:0];
	assign rom_col = pix_x[2:0] - ball_x_l[2:0];
	assign rom_bit = rom_data[rom_col];
	//pixel within ball
	assign rd_ball_on = sq_ball_on & rom_bit;
	//ball rgb output
	assign ball_rgb = 3'b100;
	//new ball position
	assign ball_x_next = (refr_tick) ? ball_x_reg + x_delta_reg :
						ball_x_reg;
	assign ball_y_next = (refr_tick) ? ball_y_reg + y_delta_reg :
						ball_y_reg;
	//new ball belocity
	always @*
	begin
		x_delta_next = x_delta_reg;
		y_delta_next = y_delta_reg;
		if (ball_y_t < 1) // reach top
			y_delta_next = BALL_V_P;
		else if (ball_y_b > (MAX_Y - 1))
			y_delta_next = BALL_V_N;
		else if ((LEFT_BAR_X_L <= ball_x_r) && (ball_x_r <= LEFT_BAR_X_R) &&
				(left_bar_y_t <= ball_y_b) && (ball_y_t <= left_bar_y_b))
			x_delta_next = BALL_V_P;
		//reach x of left bar and hit, ball bounce back
		else if ((RIGHT_BAR_X_L <= ball_x_r) && (ball_x_r <= RIGHT_BAR_X_R) &&
				(right_bar_y_t <= ball_y_b) && (ball_y_t <= right_bar_y_b))
		//reach x of right bar and hit, ball bounce back
			x_delta_next = BALL_V_N;
	end
	
	//---------------------------
	//rgb multiplexing circuit
	//---------------------------
	always @*
		if (~video_on)
			graph_rgb = 3'b000; // blank
		else
			if (left_bar_on)
				graph_rgb = left_bar_rgb;
			else if (right_bar_on)
				graph_rgb = right_bar_rgb;
			else if (rd_ball_on)
				graph_rgb = ball_rgb;
			else
				graph_rgb = 3'b111; //white background

endmodule
	
	
	
	