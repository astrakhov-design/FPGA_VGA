module vga_sync #(
//parameters for horisontal_sync
  parameter H_PIXELS        = 800,
  parameter H_FRONTPORCH    = 40,
  parameter H_SYNCTIME      = 128,
  parameter H_BACKPORCH     = 88,
//parameters for vertical_sync
  parameter V_LINES         = 600,
  parameter V_FRONTPORCH    = 1,
  parameter V_SYNCTIME      = 4,
  parameter V_BACKPORCH     = 23,
//bits of output pixel generator
  parameter PIXEL_GEN_BITS  = 12
)(
  input clk,
  input rst,

  output hsync,
  output vsync,
  output video_on,

  output [PIXEL_GEN_BITS-1:0] pixel_x
);

reg   [PIXEL_GEN_BITS-1:0]    h_count_reg;
wire  [PIXEL_GEN_BITS-1:0]    h_count_next;
reg   [PIXEL_GEN_BITS-1:0]    v_count_reg;
wire  [PIXEL_GEN_BITS-1:0]    v_count_next;

//output buffer
reg v_sync_reg, h_sync_reg;
wire v_sync_next, h_sync_next;

//status signal
wire h_end, v_end;

always @ (posedge clk, posedge rst) begin
  if(rst) begin
    v_count_reg <=  1'b0;
    v_count_reg <=  0;
    h_count_reg <=  0;
    v_sync_reg  <=  1'b0;
    h_sync_reg  <=  1'b0;
  end
  else begin
    v_count_reg <=  v_count_next;
    h_count_reg <=  h_count_next;
    v_sync_reg  <=  v_sync_next;
    h_sync_reg  <=  h_sync_next;
  end
end

assign h_end = (h_count_reg == (H_PIXELS + H_FRONTPORCH + H_SYNCTIME + H_BACKPORCH - 1));
assign v_end = (v_count_reg == (V_LINES + V_FRONTPORCH + V_SYNCTIME + V_BACKPORCH - 1));

assign h_count_next  = h_end ? 0 : h_count_reg + 1'b1;
assign v_count_next  = h_end ? (v_end ? 0 : v_count_reg + 1'b1) : v_count_reg;

assign h_sync_next   = (h_count_reg >= (H_PIXELS + H_FRONTPORCH) &&
                        h_count_reg <= (H_PIXELS + H_FRONTPORCH + H_SYNCTIME - 1));

assign v_sync_next   = (v_count_reg >= (V_LINES + V_BACKPORCH) &&
                        v_count_reg <= (V_LINES + V_BACKPORCH + V_SYNCTIME - 1));

assign video_on = (h_count_reg < H_PIXELS) && (v_count_reg < V_LINES);

assign hsync    = h_sync_reg;
assign vsync    = v_sync_reg;
assign pixel_x  = h_count_reg;

endmodule
