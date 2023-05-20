 `timescale 1 ns / 10 ps
 
module top_tb;
reg init_clk;
reg s_axis_aresetn;
reg start_write;
reg start_read;

initial begin
fork
  #0 begin 
    init_clk = 1'b1;
    s_axis_aresetn = 1'b0;
    start_write =1'b0;
    start_read = 1'b0;
  end
  #10 begin
    s_axis_aresetn = 1'b1;
    start_write =1'b1;
  end
  #150 begin
    start_write =1'b0;
    start_read = 1'b1;
  end
  #200 begin
    start_read = 1'b0;
  end
join
end

always #5 init_clk = !init_clk;

top top_i(
  .s_axis_aresetn(s_axis_aresetn),
  .start_write(start_write),
  .start_read(start_read),
  .init_clk(init_clk)
);

endmodule
