 `timescale 1 ns / 10 ps
 
module top (
  input     init_clk
  //input     axi_aclk,
  //input     axi_aresetn
);

parameter ADDR_W = 32;
parameter DATA_W = 32;
parameter STRB_W = 4;

// AXI S00接口
wire              s0_axi_awready;
wire              s0_axi_awvalid;
wire [ADDR_W-1:0] s0_axi_awaddr;
wire        [1:0] s0_axi_awburst;
wire        [3:0] s0_axi_awcache;
wire        [7:0] s0_axi_awlen;
wire        [2:0] s0_axi_awsize;
wire              s0_axi_wready;
wire              s0_axi_wvalid;
wire [DATA_W-1:0] s0_axi_wdata;
wire [STRB_W-1:0] s0_axi_wstrb;
wire              s0_axi_wlast;
wire              s0_axi_bready;
wire              s0_axi_bvalid;
wire        [1:0] s0_axi_bresp;

wire              s0_axi_arready;
wire              s0_axi_arvalid;
wire [ADDR_W-1:0] s0_axi_araddr;
wire        [1:0] s0_axi_arburst;
wire        [3:0] s0_axi_arcache;
wire        [7:0] s0_axi_arlen;
wire        [2:0] s0_axi_arsize;
wire              s0_axi_rready;
wire              s0_axi_rvalid;
wire [DATA_W-1:0] s0_axi_rdata;
wire              s0_axi_rlast;
wire        [1:0] s0_axi_rresp;

wire start1, start2;
wire start3, start4;
wire axi_aclk;
assign axi_aclk = init_clk;
vio vio_i (
  .clk(axi_aclk),
  .probe_out0(axi_aresetn),
  .probe_out1(start1),
  .probe_out2(start2),
  .probe_out3(start3),
  .probe_out4(start4)
);

procvter #(
  .ADDR_W(ADDR_W),
  .DATA_W(DATA_W),
  .STRB_W(STRB_W)
) procvter_i (
  .axi_aclk(axi_aclk),
  .axi_aresetn(axi_aresetn),
  .start_write(start1),
  .start_read(start2),

  .s_axi_awready(s0_axi_awready),
  .s_axi_awvalid(s0_axi_awvalid),
  .s_axi_awaddr(s0_axi_awaddr),
  .s_axi_awburst(s0_axi_awburst),
  .s_axi_awcache(s0_axi_awcache),
  .s_axi_awlen(s0_axi_awlen),
  .s_axi_awsize(s0_axi_awsize),
  .s_axi_wready(s0_axi_wready),
  .s_axi_wvalid(s0_axi_wvalid),
  .s_axi_wdata(s0_axi_wdata),
  .s_axi_wstrb(s0_axi_wstrb),
  .s_axi_wlast(s0_axi_wlast),
  .s_axi_bready(s0_axi_bready),
  .s_axi_bvalid(s0_axi_bvalid),
  .s_axi_bresp(s0_axi_bresp),

  .s_axi_arready(s0_axi_arready),
  .s_axi_arvalid(s0_axi_arvalid),
  .s_axi_araddr(s0_axi_araddr),
  .s_axi_arburst(s0_axi_arburst),
  .s_axi_arcache(s0_axi_arcache),
  .s_axi_arlen(s0_axi_arlen),
  .s_axi_arsize(s0_axi_arsize),
  .s_axi_rready(s0_axi_rready),
  .s_axi_rvalid(s0_axi_rvalid),
  .s_axi_rdata(s0_axi_rdata),
  .s_axi_rlast(s0_axi_rlast),
  .s_axi_rresp(s0_axi_rresp)
);

axi_wrapper axi_wrapper_i (
  .axi_aclk(axi_aclk),
  .axi_aresetn(axi_aresetn),
  .axi_s0_araddr(s0_axi_araddr),
  .axi_s0_arburst(s0_axi_arburst),
  .axi_s0_arcache(s0_axi_arcache),
  .axi_s0_arlen(s0_axi_arlen),
  .axi_s0_arlock(),
  .axi_s0_arprot(),
  .axi_s0_arready(s0_axi_arready),
  .axi_s0_arsize(s0_axi_arsize),
  .axi_s0_arvalid(s0_axi_arvalid),
  .axi_s0_awaddr(s0_axi_awaddr),
  .axi_s0_awburst(s0_axi_awburst),
  .axi_s0_awcache(s0_axi_awcache),
  .axi_s0_awlen(s0_axi_awlen),
  .axi_s0_awlock(),
  .axi_s0_awprot(),
  .axi_s0_awready(s0_axi_awready),
  .axi_s0_awsize(s0_axi_awsize),
  .axi_s0_awvalid(s0_axi_awvalid),
  .axi_s0_bready(s0_axi_bready),
  .axi_s0_bresp(s0_axi_bresp),
  .axi_s0_bvalid(s0_axi_bvalid),
  .axi_s0_rdata(s0_axi_rdata),
  .axi_s0_rlast(s0_axi_rlast),
  .axi_s0_rready(s0_axi_rready),
  .axi_s0_rresp(s0_axi_rresp),
  .axi_s0_rvalid(s0_axi_rvalid),
  .axi_s0_wdata(s0_axi_wdata),
  .axi_s0_wlast(s0_axi_wlast),
  .axi_s0_wready(s0_axi_wready),
  .axi_s0_wstrb(s0_axi_wstrb),
  .axi_s0_wvalid(s0_axi_wvalid)
);

endmodule
