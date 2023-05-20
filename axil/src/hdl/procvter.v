 `timescale 1 ns / 10 ps
 
module procvter #(
  parameter ADDR_W = 32,
  parameter DATA_W = 32,
  parameter STRB_W = 4
)(
  input               axil_aclk,
  input               axil_aresetn,
  input               start_write,
  input               start_read,

  input               s_axil_awready,
  output              s_axil_awvalid,
  output [ADDR_W-1:0] s_axil_awaddr,
  input               s_axil_wready,
  output              s_axil_wvalid,
  output [DATA_W-1:0] s_axil_wdata,
  output [STRB_W-1:0] s_axil_wstrb,
  output              s_axil_bready,
  input               s_axil_bvalid,
  input         [1:0] s_axil_bresp,

  input               s_axil_arready,
  output              s_axil_arvalid,
  output [ADDR_W-1:0] s_axil_araddr,
  output              s_axil_rready,
  input               s_axil_rvalid,
  input  [DATA_W-1:0] s_axil_rdata,
  input         [1:0] s_axil_rresp
);

// axil接口
reg               awvalid;
reg  [ADDR_W-1:0] awaddr;
wire              awready;
wire              wready;
reg               wvalid;
reg  [DATA_W-1:0] wdata;
reg  [STRB_W-1:0] wstrb;
reg               bready;
wire              bvalid;
wire        [1:0] bresp;

wire              arready;
reg               arvalid;
reg  [ADDR_W-1:0] araddr;
reg               rready;
wire              rvalid;
wire [DATA_W-1:0] rdata;
wire        [1:0] rresp;

assign awready       = s_axil_awready;
assign s_axil_awvalid = awvalid;
assign s_axil_awaddr  = awaddr;
assign wready        = s_axil_wready;
assign s_axil_wvalid  = wvalid;
assign s_axil_wdata   = wdata;
assign s_axil_wstrb   = wstrb;
assign s_axil_bready  = bready;
assign bvalid        = s_axil_bvalid;
assign bresp         = s_axil_bresp;

assign arready        = s_axil_arready;
assign s_axil_arvalid = arvalid;
assign s_axil_araddr  = araddr;
assign rvalid         = s_axil_rvalid;
assign rdata          = s_axil_rdata;
assign rresp          = s_axil_rresp;
assign s_axil_rready  = rready;

// 写寄存器控制
wire [15:0] frame_size;
reg  [15:0] wch_cnt;
assign frame_size = 16'd2048;
assign wch_tlast = (wch_cnt == frame_size);

reg [2:0] wch_state;
localparam WCH_IDLE  = 3'd0;
localparam WCH_READY = 3'd1;
localparam WCH_WADDR = 3'd2;
localparam WCH_WDATA = 3'd3;
localparam WCH_RESP  = 3'd4;
localparam WCH_SUSP  = 3'd5;

always @(posedge axil_aclk) begin
  if (!axil_aresetn) begin
    wch_state <= WCH_IDLE;
    awvalid   <= 1'b0;
    awaddr    <= 32'd0;
    wvalid    <= 1'b0;
    wdata     <= 32'd0;
    wstrb     <= {STRB_W{1'b0}};
    bready    <= 1'b0;
    wch_cnt   <= 16'd0;
  end
  else begin
    case (wch_state)
      WCH_IDLE: begin
        if (start_write) begin
          wch_state <= WCH_READY;
          awvalid   <= 1'b1;
          wvalid    <= 1'b1;
          wstrb     <= {STRB_W{1'b1}};
          wch_cnt   <= wch_cnt + 16'd32;
        end
        else begin
          wch_state <= WCH_IDLE;
        end
      end
      WCH_READY: begin
        if (awready && wready) begin
          wch_state <= WCH_RESP;
          awvalid   <= 1'b0;
          wvalid    <= 1'b0;
          bready    <= 1'b1;
        end
        else if (awready && !wready)begin
          wch_state <= WCH_WDATA;
          awvalid   <= 1'b0;
        end
        else if (!awready && wready)begin
          wch_state <= WCH_WADDR;
          wvalid    <= 1'b0;
        end
        else
          wch_state <= WCH_READY;
      end
      WCH_WADDR: begin
        if (awready) begin
          wch_state <= WCH_RESP;
          awvalid   <= 1'b0;
          bready    <= 1'b1;
        end
        else
          wch_state <= WCH_WADDR;
      end
      WCH_WDATA: begin
        if (wready) begin
          wch_state <= WCH_RESP;
          wvalid    <= 1'b0;
          bready    <= 1'b1;
        end
        else
          wch_state <= WCH_WDATA;
      end
      WCH_RESP: begin
        if (bvalid) begin
          wch_state <= WCH_SUSP;
          bready    <= 1'b0;
          wstrb     <= {STRB_W{1'b0}};
        end
        else
          wch_state <= WCH_RESP;
      end
      WCH_SUSP: begin
        if (wch_tlast) begin
          wch_state <= WCH_IDLE;
          awvalid   <= 1'b0;
          awaddr    <= 32'd0;
          wvalid    <= 1'b0;
          wdata     <= 32'd0;
          wstrb     <= {STRB_W{1'b0}};
          bready    <= 1'b0;
          wch_cnt   <= 16'd0;
        end
        else begin
          wch_state <= WCH_READY;
          awvalid   <= 1'b1;
          awaddr    <= awaddr + 3'd4;
          wvalid    <= 1'b1;
          wdata     <= wdata + 1'b1;
          wstrb     <= {STRB_W{1'b1}};
          bready    <= 1'b0;
          wch_cnt   <= wch_cnt + 16'd32;
        end
      end
      default: begin
        wch_state <= WCH_IDLE;
        awvalid   <= 1'b0;
        awaddr    <= 32'd0;
        wvalid    <= 1'b0;
        wdata     <= 32'd0;
        bready    <= 1'b0;
        wch_cnt   <= 16'd0;
      end
    endcase
  end
end

// 读寄存器控制
reg  [15:0] rch_cnt;
assign rch_tlast = (rch_cnt == frame_size);

reg [2:0] rch_state;
localparam RCH_IDLE  = 3'd0;
localparam RCH_READY = 3'd1;
localparam RCH_RDATA = 3'd2;
localparam RCH_SUSP  = 3'd3;
reg [31:0] data;

always @(posedge axil_aclk) begin
  if (!axil_aresetn) begin
    rch_state <= RCH_IDLE;
    arvalid   <= 1'b0;
    araddr    <= 32'd0;
    rready    <= 1'b0;
    rch_cnt   <= 16'd0;
  end
  else begin
    case (rch_state)
      RCH_IDLE: begin
        if (start_read) begin
          rch_state <= RCH_READY;
          arvalid   <= 1'b1;
          rch_cnt   <= rch_cnt + 16'd32;
        end
        else begin
          rch_state <= RCH_IDLE;
        end
      end
      RCH_READY: begin
        if (arready) begin
          rch_state <= RCH_RDATA;
          arvalid   <= 1'b0;
          rready    <= 1'b1;
        end
        else
          rch_state <= RCH_READY;
      end
      RCH_RDATA: begin
        if (rvalid) begin
          rch_state <= RCH_SUSP;
          data      <= rdata;
        end
        else
          rch_state <= RCH_RDATA;
      end
      RCH_SUSP: begin
        if (rch_tlast) begin
          rch_state <= RCH_IDLE;
          arvalid   <= 1'b0;
          araddr    <= 32'd0;
          rready    <= 1'b0;
          rch_cnt   <= 16'd0;
        end
        else begin
          rch_state <= RCH_READY;
          arvalid   <= 1'b1;
          araddr    <= araddr + 3'd4;
          rready    <= 1'b0;
          rch_cnt   <= rch_cnt + 16'd32;
        end
      end
      default: begin
        rch_state <= RCH_IDLE;
        arvalid   <= 1'b0;
        araddr    <= 32'd0;
        rready    <= 1'b0;
        rch_cnt   <= 16'd0;
      end
    endcase
  end
end

ila_procvter ila_procvter_i (
  .clk(axil_aclk),
  .probe0(awready),
  .probe1(awvalid),
  .probe2(awaddr),
  .probe3(wready),
  .probe4(wvalid),
  .probe5(wdata),
  .probe6(wch_cnt),
  .probe7(wch_state),
  .probe8(arready),
  .probe9(arvalid),
  .probe10(araddr),
  .probe11(rready),
  .probe12(rvalid),
  .probe13(rdata),
  .probe14(rch_cnt),
  .probe15(rch_state),
  .probe16(bready),
  .probe17(bvalid),
  .probe18(bresp),
  .probe19(rresp),
  .probe20(wstrb)
);

endmodule
