 `timescale 1 ns / 10 ps
 
module procvter #(
  parameter ADDR_W = 32,
  parameter DATA_W = 32,
  parameter STRB_W = 4
)(
  input               axi_aclk,
  input               axi_aresetn,
  input               start_write,
  input               start_read,

  input               s_axi_awready,
  output              s_axi_awvalid,
  output [ADDR_W-1:0] s_axi_awaddr,
  output        [1:0] s_axi_awburst,
  output        [3:0] s_axi_awcache,
  output        [7:0] s_axi_awlen,
  output        [2:0] s_axi_awsize,
  input               s_axi_wready,
  output              s_axi_wvalid,
  output [DATA_W-1:0] s_axi_wdata,
  output [STRB_W-1:0] s_axi_wstrb,
  output              s_axi_wlast,
  output              s_axi_bready,
  input               s_axi_bvalid,
  input         [1:0] s_axi_bresp,

  input               s_axi_arready,
  output              s_axi_arvalid,
  output [ADDR_W-1:0] s_axi_araddr,
  output        [1:0] s_axi_arburst,
  output        [3:0] s_axi_arcache,
  output        [7:0] s_axi_arlen,
  output        [2:0] s_axi_arsize,
  output              s_axi_rready,
  input               s_axi_rvalid,
  input  [DATA_W-1:0] s_axi_rdata,
  input               s_axi_rlast,
  input         [1:0] s_axi_rresp
);

// axi接口
wire              awready;
reg               awvalid;
reg  [ADDR_W-1:0] awaddr;
reg         [1:0] awburst;
reg         [3:0] awcache;
reg         [7:0] awlen;
reg         [2:0] awsize;
wire              wready;
reg               wvalid;
reg  [DATA_W-1:0] wdata;
reg  [STRB_W-1:0] wstrb;
reg               wlast;
reg               bready;
wire              bvalid;
wire        [1:0] bresp;

wire              arready;
reg               arvalid;
reg  [ADDR_W-1:0] araddr;
reg         [1:0] arburst;
reg         [3:0] arcache;
reg         [7:0] arlen;
reg         [2:0] arsize;
reg               rready;
wire              rvalid;
wire [DATA_W-1:0] rdata;
wire              rlast;
wire        [1:0] rresp;

assign awready       = s_axi_awready;
assign s_axi_awvalid = awvalid;
assign s_axi_awaddr  = awaddr;
assign s_axi_awburst = awburst;
assign s_axi_awcache = awcache;
assign s_axi_awlen   = awlen;
assign s_axi_awsize  = awsize;
assign wready        = s_axi_wready;
assign s_axi_wvalid  = wvalid;
assign s_axi_wdata   = wdata;
assign s_axi_wstrb   = wstrb;
assign s_axi_wlast   = wlast;
assign bvalid        = s_axi_bvalid;
assign bresp         = s_axi_bresp;
assign s_axi_bready  = bready;

assign arready        = s_axi_arready;
assign s_axi_arvalid  = arvalid;
assign s_axi_araddr   = araddr;
assign s_axi_arburst  = arburst;
assign s_axi_arcache  = arcache;
assign s_axi_arlen    = arlen;
assign s_axi_arsize   = arsize;
assign rvalid         = s_axi_rvalid;
assign rdata          = s_axi_rdata;
assign rlast          = s_axi_rlast;
assign rresp          = s_axi_rresp;
assign s_axi_rready  = rready;

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

always @(posedge axi_aclk) begin
  if (!axi_aresetn) begin
    wch_state <= WCH_IDLE;
    awvalid   <= 1'b0;
    awaddr    <= 32'd0;
    awburst   <= 2'd1;
    awcache   <= 4'd3;
    awlen     <= 8'd0;
    awsize    <= 3'd6;
    wvalid    <= 1'b0;
    wdata     <= 32'd0;
    wstrb     <= {STRB_W{1'b0}};
    wlast     <= 1'b0;
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
          wlast     <= 1'b1;
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
          wlast     <= 1'b0;
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
          wlast     <= 1'b1;
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

always @(posedge axi_aclk) begin
  if (!axi_aresetn) begin
    rch_state <= RCH_IDLE;
    arvalid   <= 1'b0;
    araddr    <= 32'd0;
    arburst   <= 2'd1;
    arcache   <= 4'd3;
    arlen     <= 8'd0;
    arsize    <= 3'd6;
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
  .clk(axi_aclk),
  .probe0(awready),
  .probe1(awvalid),
  .probe2(awaddr),
  .probe3(awburst),
  .probe4(awcache),
  .probe5(awlen),
  .probe6(awsize),
  .probe7(wready),
  .probe8(wvalid),
  .probe9(wdata),
  .probe10(wstrb),
  .probe11(wlast),
  .probe12(bready),
  .probe13(bvalid),
  .probe14(bresp),
  .probe15(arready),
  .probe16(arvalid),
  .probe17(araddr),
  .probe18(arburst),
  .probe19(arcache),
  .probe20(arlen),
  .probe21(arsize),
  .probe22(rready),
  .probe23(rvalid),
  .probe24(rdata),
  .probe25(rlast),
  .probe26(rresp),
  .probe27(wch_cnt),
  .probe28(wch_state),
  .probe29(rch_cnt),
  .probe30(rch_state)
);

endmodule
