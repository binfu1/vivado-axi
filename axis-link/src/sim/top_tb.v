 `timescale 1 ns / 10 ps
 
module top_tb;
reg s_axis_aclk;
reg s_axis_aresetn;
  
wire      s_axis_tready;
reg       s_axis_tvalid;
reg [7:0] s_axis_tdata;
reg       s_axis_tkeep;
reg       s_axis_tlast;
reg [1:0] s_axis_tdest;

reg        m0_axis_tready;
wire       m0_axis_tvalid;
wire [7:0] m0_axis_tdata;
wire       m0_axis_tkeep;
wire       m0_axis_tlast;
wire [1:0] m0_axis_tdest;

reg        m1_axis_tready;
wire       m1_axis_tvalid;
wire [7:0] m1_axis_tdata;
wire       m1_axis_tkeep;
wire       m1_axis_tlast;
wire [1:0] m1_axis_tdest;

reg        m2_axis_tready;
wire       m2_axis_tvalid;
wire [7:0] m2_axis_tdata;
wire       m2_axis_tkeep;
wire       m2_axis_tlast;
wire [1:0] m2_axis_tdest;

initial begin
fork
  #0 begin 
    s_axis_aclk = 1'b1;
    s_axis_aresetn = 1'b0;
    m0_axis_tready = 1'b1;
    m1_axis_tready = 1'b1;
    m2_axis_tready = 1'b1;
  end
  #10 begin
    s_axis_aresetn = 1'b1;
  end
join
end
 
always #5 s_axis_aclk = !s_axis_aclk;

reg [1:0] flag;
always @(posedge s_axis_aclk or s_axis_aresetn) begin
  if (!s_axis_aresetn) flag <= 2'd1;
  else if (flag == 2'd2) flag <= 2'd0;
  else flag <= flag + 2'd1;
end

always @(posedge s_axis_aclk or s_axis_aresetn) begin
  if (!s_axis_aresetn) begin
    s_axis_tvalid <= 1'b0;
    s_axis_tdata <= 8'd0;
    s_axis_tkeep <= 1'b0;
    s_axis_tlast <= 1'b0;
    s_axis_tdest <= 1'b0;
  end
  else if (s_axis_tready) begin
    s_axis_tvalid <= 1'b1;
    s_axis_tdata <= s_axis_tdata + 8'd1;
    s_axis_tkeep <= 1'b1;
    s_axis_tlast <= 1'b1;
    if (flag == 2'b0) s_axis_tdest <= 2'd0;
    else if (flag == 2'b1) s_axis_tdest <= 2'd1;
    else s_axis_tdest <= 2'd2;
  end
end

top top_i(
  .s_axis_aclk(s_axis_aclk),
  .s_axis_aresetn(s_axis_aresetn),

  .s_axis_tready(s_axis_tready),
  .s_axis_tvalid(s_axis_tvalid),
  .s_axis_tdata(s_axis_tdata),
  .s_axis_tkeep(s_axis_tkeep),
  .s_axis_tlast(s_axis_tlast),
  .s_axis_tdest(s_axis_tdest),

  .m0_axis_tready(m0_axis_tready),
  .m0_axis_tvalid(m0_axis_tvalid),
  .m0_axis_tdata (m0_axis_tdata),
  .m0_axis_tkeep (m0_axis_tkeep),
  .m0_axis_tlast (m0_axis_tlast),
  .m0_axis_tdest (m0_axis_tdest),

  .m1_axis_tready(m1_axis_tready),
  .m1_axis_tvalid(m1_axis_tvalid),
  .m1_axis_tdata (m1_axis_tdata),
  .m1_axis_tkeep (m1_axis_tkeep),
  .m1_axis_tlast (m1_axis_tlast),
  .m1_axis_tdest (m1_axis_tdest),

  .m2_axis_tready(m2_axis_tready),
  .m2_axis_tvalid(m2_axis_tvalid),
  .m2_axis_tdata (m2_axis_tdata),
  .m2_axis_tkeep (m2_axis_tkeep),
  .m2_axis_tlast (m2_axis_tlast),
  .m2_axis_tdest (m2_axis_tdest)
);

endmodule
