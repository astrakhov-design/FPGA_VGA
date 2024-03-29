module vga_sync(
	input clk,
	input rst,
	
	output hsync,
	output vsync,
	output video_on,
	output p_tick,
	
	output wire [9:0] pixel_x,
	output wire [9:0] pixel_y
	);
	
	//VGA 640x480 sync parameters
	localparam HD = 640; // horizontal display area
	localparam HF = 48; // h. front border
	localparam HB = 16; // h. back border
	localparam HR = 96; // h. retrace
	localparam VD = 480; // vertical display area
	localparam VF = 10; // v. front border
	localparam VB = 33; // v. back border
	localparam VR = 2;	// v. retrace
	
	// mod-2 counter
	reg mod2_reg;
	wire mod2_next;
	
	reg [9:0] h_count_reg, h_count_next;
	reg [9:0] v_count_reg, v_count_next;
	
	//output buffer
	reg v_sync_reg, h_sync_reg;
	wire v_sync_next, h_sync_next;
	
	//status signal
	wire h_end, v_end, pixel_tick;
	
	always @ (posedge clk, posedge rst)
		begin
			if (rst)
				begin
					mod2_reg <= 1'b0;
					v_count_reg <= 0;
					h_count_reg <= 0;
					v_sync_reg <= 1'b0;
					h_sync_reg <= 1'b0;
				end
			else
				begin
					mod2_reg <= mod2_next;
					v_count_reg <= v_count_next;
					h_count_reg <= h_count_next;
					v_sync_reg <= v_sync_next;
					h_sync_reg <= h_sync_next;
				end
		end
		
	assign mod2_next = ~mod2_reg;
	assign pixel_tick = mod2_reg;
	
	//799
	assign h_end = (h_count_reg == (HD + HF + HB + HR - 1));
	//524
	assign v_end = (v_count_reg == (VD + VF + VB + VR - 1));
	
	always @*
	begin
		if (pixel_tick)
			if (h_end)
				h_count_next = 0;
			else
				h_count_next = h_count_reg + 1'b1;
		else
			h_count_next = h_count_reg;
	end
	
	always @ *
		begin
			if (pixel_tick & h_end)
				if (v_end)
					v_count_next = 0;
				else
					v_count_next = v_count_reg + 1'b1;
			else
				v_count_next = v_count_reg;
		end
		
	assign h_sync_next = (h_count_reg >= (HD + HB) &&
						  h_count_reg <= (HD + HB + HR - 1));
						  
	assign v_sync_next = (v_count_reg >= (VD + VB) &&
						  v_count_reg <= (VD + VB + VR - 1));
						  
	assign video_on = (h_count_reg < HD) && (v_count_reg < VD);
	
	assign hsync = h_sync_reg;
	assign vsync = v_sync_reg;
	assign pixel_x = h_count_reg;
	assign pixel_y = v_count_reg;
	assign p_tick = pixel_tick;
	
endmodule
		
	
	
	