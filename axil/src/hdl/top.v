 `timescale 1 ns / 10 ps
 
module top (
  input     init_clk
  //input     axil_aclk,
  //input     axil_aresetn
);

parameter ADDR_W = 32;
parameter DATA_W = 32;
parameter STRB_W = 4;

// AXIL S00接口
wire              s0_axil_awready;
wire              s0_axil_awvalid;
wire [ADDR_W-1:0] s0_axil_awaddr;
wire              s0_axil_wready;
wire              s0_axil_wvalid;
wire [DATA_W-1:0] s0_axil_wdata;
wire [STRB_W-1:0] s0_axil_wstrb;
wire              s0_axil_bready;
wire              s0_axil_bvalid;
wire        [1:0] s0_axil_bresp;

wire              s0_axil_arready;
wire              s0_axil_arvalid;
wire [ADDR_W-1:0] s0_axil_araddr;
wire              s0_axil_rready;
wire              s0_axil_rvalid;
wire [DATA_W-1:0] s0_axil_rdata;
wire        [1:0] s0_axil_rresp;

// AXIL S01接口
wire        s1_axil_awready;
wire        s1_axil_awvalid;
wire [31:0] s1_axil_awaddr;
wire        s1_axil_wready;
wire        s1_axil_wvalid;
wire [31:0] s1_axil_wdata;
wire        s1_axil_bvalid;
wire  [1:0] s1_axil_bresp;
wire        s1_axil_arready;
wire        s1_axil_arvalid;
wire [31:0] s1_axil_araddr;
wire        s1_axil_rvalid;
wire [31:0] s1_axil_rdata;
wire  [1:0] s1_axil_rresp;
wire        s1_axil_bready;
wire        s1_axil_rready;

wire start1, start2;
wire start3, start4;
wire axil_aclk;
assign axil_aclk = init_clk;
vio vio_i (
  .clk(axil_aclk),
  .probe_out0(axil_aresetn),
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
  .axil_aclk(axil_aclk),
  .axil_aresetn(axil_aresetn),
  .start_write(start1),
  .start_read(start2),

  .s_axil_awready(s0_axil_awready),
  .s_axil_awvalid(s0_axil_awvalid),
  .s_axil_awaddr(s0_axil_awaddr),
  .s_axil_wready(s0_axil_wready),
  .s_axil_wvalid(s0_axil_wvalid),
  .s_axil_wdata(s0_axil_wdata),
  .s_axil_wstrb(s0_axil_wstrb),
  .s_axil_bready(s0_axil_bready),
  .s_axil_bvalid(s0_axil_bvalid),
  .s_axil_bresp(s0_axil_bresp),

  .s_axil_arready(s0_axil_arready),
  .s_axil_arvalid(s0_axil_arvalid),
  .s_axil_araddr(s0_axil_araddr),
  .s_axil_rready(s0_axil_rready),
  .s_axil_rvalid(s0_axil_rvalid),
  .s_axil_rdata(s0_axil_rdata),
  .s_axil_rresp(s0_axil_rresp)
);

axil_wrapper axil_wrapper_i (
  .axil_aclk(axil_aclk),
  .axil_aresetn(axil_aresetn),
  .axil_s0_araddr(s0_axil_araddr),
  .axil_s0_arprot(),
  .axil_s0_arready(s0_axil_arready),
  .axil_s0_arvalid(s0_axil_arvalid),
  .axil_s0_awaddr(s0_axil_awaddr),
  .axil_s0_awprot(),
  .axil_s0_awready(s0_axil_awready),
  .axil_s0_awvalid(s0_axil_awvalid),
  .axil_s0_bready(s0_axil_bready),
  .axil_s0_bresp(s0_axil_bresp),
  .axil_s0_bvalid(s0_axil_bvalid),
  .axil_s0_rdata(s0_axil_rdata),
  .axil_s0_rready(s0_axil_rready),
  .axil_s0_rresp(s0_axil_rresp),
  .axil_s0_rvalid(s0_axil_rvalid),
  .axil_s0_wdata(s0_axil_wdata),
  .axil_s0_wready(s0_axil_wready),
  .axil_s0_wstrb(s0_axil_wstrb),
  .axil_s0_wvalid(s0_axil_wvalid)
);

endmodule
