 `timescale 1 ns / 10 ps
 `define SYNTH
 
module data_gen (
  input         axis_aresetn,
  input         axis_aclk,
  input         start_write,
  output        axis_tvalid,
  input         axis_tready,
  output [31:0] axis_tdata,
  output [3:0]  axis_tkeep,
  output        axis_tlast
);

wire aclk, aresetn, tready;
reg tvalid, tlast;
reg [31:0] tdata;
reg [3:0]  tkeep;
assign aclk = axis_aclk;
assign aresetn = axis_aresetn;
assign tready = axis_tready;
assign axis_tvalid = tvalid;
assign axis_tdata = tdata;
assign axis_tkeep = tkeep;
assign axis_tlast = tlast;

reg  start_write_dly1;
wire start_write_arise;
always @(posedge aclk) begin
  if (!aresetn) begin
    start_write_dly1 <= 1'd0;
  end
  else begin
    start_write_dly1 <= start_write;
  end
end
assign start_write_arise = ({start_write, start_write_dly1} == {2'b10}) ? 1'b1 : 1'b0;

reg [1:0] wch_state;
reg [3:0] wch_cnt;
localparam WCH_IDLE  = 2'd0;
localparam WCH_READY = 2'd1;
localparam WCH_SUSP  = 2'd2;
localparam WCH_LAST  = 2'd3;

always @(posedge aclk) begin
  if (!aresetn) begin
    wch_state <= WCH_IDLE;
    tvalid    <= 1'b0;
    tdata     <= 32'd0;
    tkeep     <= 4'b0;
    tlast     <= 1'd0;
    wch_cnt   <= 4'd0;
  end
  else begin
    case (wch_state)
      WCH_IDLE: begin
        if (start_write && tready) begin
          wch_state <= WCH_READY;
          tvalid    <= 1'b1;
          tdata     <= 32'd1;
          tkeep     <= 4'b1111;
          tlast     <= 1'd0;
          wch_cnt   <= wch_cnt + 4'd1;
        end
        else begin
          wch_state <= WCH_IDLE;
          tvalid    <= 1'b0;
          tdata     <= 32'd0;
          tkeep     <= 4'b0000;
          tlast     <= 1'd0;
          wch_cnt   <= 1'd0;
        end
      end
      WCH_READY: begin
        if (tready && wch_cnt < 4'd10) begin
          wch_state <= WCH_READY;
          tvalid    <= 1'b1;
          tdata     <= tdata + 32'd1;
          tkeep     <= 4'b1111;
          tlast     <= 1'd0;
          wch_cnt   <= wch_cnt + 4'd1;
        end
        else if (tready && wch_cnt >= 4'd10)begin
          wch_state <= WCH_LAST;
          tvalid    <= 1'b1;
          tdata     <= tdata + 32'd1;
          tkeep     <= 4'b1111;
          tlast     <= 1'd1;
          wch_cnt   <= wch_cnt + 4'd1;
        end
        else if (!tready && wch_cnt < 4'd10)begin
          wch_state <= WCH_SUSP;
          tvalid    <= 1'b0;
          tdata     <= tdata;
          tkeep     <= 4'b0000;
          tlast     <= 1'd0;
          wch_cnt   <= 1'd0;
        end
      end
      WCH_SUSP: begin
        if (tready && wch_cnt < 4'd10) begin
          wch_state <= WCH_READY;
          tvalid    <= 1'b1;
          tdata     <= tdata + 32'd1;
          tkeep     <= 4'b1111;
          tlast     <= 1'd0;
          wch_cnt   <= wch_cnt + 4'd1;
        end
        else if (tready && wch_cnt >= 4'd10)begin
          wch_state <= WCH_LAST;
          tvalid    <= 1'b1;
          tdata     <= tdata + 32'd1;
          tkeep     <= 4'b1111;
          tlast     <= 1'd0;
          wch_cnt   <= wch_cnt + 4'd1;
        end
        else if (!tready && wch_cnt < 4'd10)begin
          wch_state <= WCH_SUSP;
          tvalid    <= 1'b0;
          tdata     <= tdata;
          tkeep     <= 4'b0000;
          tlast     <= 1'd1;
          wch_cnt   <= 1'd0;
        end
      end
      WCH_LAST: begin
        wch_state <= WCH_IDLE;
        tvalid    <= 1'b0;
        tdata     <= 32'd0;
        tkeep     <= 4'b0000;
        tlast     <= 1'd0;
        wch_cnt   <= 4'd0;
      end
      default: begin
        wch_state <= WCH_IDLE;
        tvalid    <= 1'b0;
        tdata     <= 32'd0;
        tkeep     <= 4'b0000;
        tlast     <= 1'd0;
        wch_cnt   <= 4'd0;
      end
    endcase
  end
end

`ifdef SYNTH
ila_data_gen ila_data_gen_i (
  .clk(aclk),
  .probe0(tready),
  .probe1(tvalid),
  .probe2(tdata),
  .probe3(tkeep),
  .probe4(tlast),
  .probe5(start_write),
  .probe6(wch_cnt),
  .probe7(wch_state)
);
`endif

endmodule
