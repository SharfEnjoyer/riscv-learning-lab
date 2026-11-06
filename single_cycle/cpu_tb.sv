module cpu_tb;

logic clk;
logic rst;

datapath uut_datapath (
    .clk(clk),
    .rst(rst)
);

always #50 clk = ~clk;


initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, cpu_tb);
end


initial begin

    clk = 0;
    rst = 0;
    repeat(1) @(posedge clk);
    rst = 1;
    repeat(1) @(posedge clk);
    rst = 0;

    repeat(30) @(posedge clk);

    $display("Simulation Complete");
    $finish;
end

endmodule