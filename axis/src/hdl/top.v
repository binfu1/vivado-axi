 `timescale 1 ns / 10 ps
 //`define SIM
 `define SYNTH
 
module top (
`ifdef SIM
  input s_axis_aresetn,
  input start_write,
  input start_read,
`endif
  input init_clk
);

// AXIS Slave接口
wire        s_axis_aclk;
wire        s_axis_tvalid;
wire        s_axis_tready;
wire [31:0] s_axis_tdata;
wire [3:0]  s_axis_tkeep;
wire        s_axis_tlast;

// AXIS Master接口
wire        m_axis_tvalid;
wire        m_axis_tready;
wire [31:0] m_axis_tdata;
wire [3:0]  m_axis_tkeep;
wire        m_axis_tlast;

assign s_axis_aclk = init_clk;
`ifdef SYNTH
wire s_axis_aresetn;
wire start_write;
wire start_read;
vio vio_i (
  .clk(s_axis_aclk),
  .probe_out0(s_axis_aresetn),
  .probe_out1(start_write),
  .probe_out2(start_read)
);
`endif

data_gen data_gen_i (
  .axis_aresetn(s_axis_aresetn),
  .axis_aclk(s_axis_aclk),
  .start_write(start_write),
  .axis_tvalid(s_axis_tvalid),
  .axis_tready(s_axis_tready),
  .axis_tdata(s_axis_tdata),
  .axis_tkeep(s_axis_tkeep),
  .axis_tlast(s_axis_tlast)
);

axis_data_fifo axis_data_fifo_i (
  .s_axis_aresetn(s_axis_aresetn),
  .s_axis_aclk(s_axis_aclk),
  .s_axis_tvalid(s_axis_tvalid),
  .s_axis_tready(s_axis_tready),
  .s_axis_tdata(s_axis_tdata),
  .s_axis_tkeep(s_axis_tkeep),
  .s_axis_tlast(s_axis_tlast),
  .m_axis_tvalid(m_axis_tvalid),
  .m_axis_tready(m_axis_tready),
  .m_axis_tdata(m_axis_tdata),
  .m_axis_tkeep(m_axis_tkeep),
  .m_axis_tlast(m_axis_tlast)
);

data_recv data_recv_i (
  .axis_aresetn(s_axis_aresetn),
  .axis_aclk(s_axis_aclk),
  .start_read(start_read),
  .axis_tvalid(m_axis_tvalid),
  .axis_tready(m_axis_tready),
  .axis_tdata(m_axis_tdata),
  .axis_tkeep(m_axis_tkeep),
  .axis_tlast(m_axis_tlast)
);

endmodule
