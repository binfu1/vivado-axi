 `timescale 1 ns / 10 ps
 `define SYNTH
 
module data_recv (
  input         axis_aresetn,
  input         axis_aclk,
  input         start_read,
  input         axis_tvalid,
  output        axis_tready,
  input [31:0]  axis_tdata,
  input [3:0]   axis_tkeep,
  input         axis_tlast
);

wire aclk, aresetn;
reg  tready;
wire tvalid, tlast;
wire [31:0] tdata;
wire [3:0]  tkeep;
assign aclk = axis_aclk;
assign aresetn = axis_aresetn;
assign axis_tready = tready;
assign tvalid = axis_tvalid;
assign tdata = axis_tdata;
assign tkeep = axis_tkeep;
assign tlast = axis_tlast;

reg  start_read_dly1;
wire start_read_arise;
always @(posedge aclk) begin
  if (!aresetn) begin
    start_read_dly1 <= 1'd0;
  end
  else begin
    start_read_dly1 <= start_read;
  end
end
assign start_read_arise = ({start_read, start_read_dly1} == {2'b10}) ? 1'b1 : 1'b0;

reg [1:0] rch_state;
reg [3:0] rch_cnt;
localparam RCH_IDLE  = 2'd0;
localparam RCH_READY = 2'd1;
localparam RCH_LAST  = 2'd3;

always @(posedge aclk) begin
  if (!aresetn) begin
    rch_state <= RCH_IDLE;
    tready    <= 1'b0;
  end
  else begin
    case (rch_state)
      RCH_IDLE: begin
        if (start_read_arise) begin
          rch_state <= RCH_READY;
          tready    <= 1'b1;
          rch_cnt   <= rch_cnt + 4'd1;
        end
        else begin
          rch_state <= RCH_IDLE;
          tready    <= 1'b0;
          rch_cnt   <= 1'd0;
        end
      end
      RCH_READY: begin
        if (rch_cnt < 4'd10) begin
          rch_state <= RCH_READY;
          rch_cnt   <= rch_cnt + 4'd1;
        end
        else if (rch_cnt >= 4'd10)begin
          rch_state <= RCH_LAST;
          tready    <= 1'b1;
          rch_cnt   <= rch_cnt + 4'd1;
        end
      end
      RCH_LAST: begin
        rch_state <= RCH_IDLE;
        tready    <= 1'b0;
        rch_cnt   <= 4'd0;
      end
      default: begin
        rch_state <= RCH_IDLE;
        rch_cnt   <= 4'd0;
      end
    endcase
  end
end

`ifdef SYNTH
ila_data_recv ila_data_recv_i (
  .clk(aclk),
  .probe0(tready),
  .probe1(tvalid),
  .probe2(tdata),
  .probe3(tkeep),
  .probe4(tlast),
  .probe5(start_read),
  .probe6(rch_cnt),
  .probe7(rch_state)
);
`endif

endmodule
