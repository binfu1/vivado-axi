module top (
  input s_axis_aclk,
  input s_axis_aresetn,

  output      s_axis_tready,
  input       s_axis_tvalid,
  input [7:0] s_axis_tdata,
  input       s_axis_tkeep,
  input       s_axis_tlast,
  input [1:0] s_axis_tdest,

  input        m0_axis_tready,
  output       m0_axis_tvalid,
  output [7:0] m0_axis_tdata,
  output       m0_axis_tkeep,
  output       m0_axis_tlast,
  output [1:0] m0_axis_tdest,

  input        m1_axis_tready,
  output       m1_axis_tvalid,
  output [7:0] m1_axis_tdata,
  output       m1_axis_tkeep,
  output       m1_axis_tlast,
  output [1:0] m1_axis_tdest,

  input        m2_axis_tready,
  output       m2_axis_tvalid,
  output [7:0] m2_axis_tdata,
  output       m2_axis_tkeep,
  output       m2_axis_tlast,
  output [1:0] m2_axis_tdest
);

axis_interconnect axis_interconnect_i (
  .ACLK(s_axis_aclk),
  .ARESETN(s_axis_aresetn),
  .S00_AXIS_ACLK(s_axis_aclk),
  .S00_AXIS_ARESETN(s_axis_aresetn),
  .M00_AXIS_ACLK(s_axis_aclk),
  .M00_AXIS_ARESETN(s_axis_aresetn),
  .M01_AXIS_ACLK(s_axis_aclk),
  .M01_AXIS_ARESETN(s_axis_aresetn),

  .S00_AXIS_TREADY(s_axis_tready),
  .S00_AXIS_TVALID(s_axis_tvalid),
  .S00_AXIS_TDATA (s_axis_tdata),
  .S00_AXIS_TKEEP (s_axis_tkeep),
  .S00_AXIS_TLAST (s_axis_tlast),
  .S00_AXIS_TDEST (s_axis_tdest),

  .M00_AXIS_TREADY(m0_axis_tready),
  .M00_AXIS_TVALID(m0_axis_tvalid),
  .M00_AXIS_TDATA (m0_axis_tdata),
  .M00_AXIS_TKEEP (m0_axis_tkeep),
  .M00_AXIS_TLAST (m0_axis_tlast),
  .M00_AXIS_TDEST (m0_axis_tdest),

  .M01_AXIS_TREADY(m1_axis_tready),
  .M01_AXIS_TVALID(m1_axis_tvalid),
  .M01_AXIS_TDATA (m1_axis_tdata),
  .M01_AXIS_TKEEP (m1_axis_tkeep),
  .M01_AXIS_TLAST (m1_axis_tlast),
  .M01_AXIS_TDEST (m1_axis_tdest),

  .M02_AXIS_TREADY(m2_axis_tready),
  .M02_AXIS_TVALID(m2_axis_tvalid),
  .M02_AXIS_TDATA (m2_axis_tdata),
  .M02_AXIS_TKEEP (m2_axis_tkeep),
  .M02_AXIS_TLAST (m2_axis_tlast),
  .M02_AXIS_TDEST (m2_axis_tdest),

  .S00_DECODE_ERR ()
);

endmodule
