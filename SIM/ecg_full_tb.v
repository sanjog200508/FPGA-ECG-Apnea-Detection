`timescale 1ns/1ps

module ecg_full_tb;

reg clk;
reg rst;
reg sample_enable;
reg signed [15:0] ecg_sample;

wire r_peak_out;
wire [15:0] rr_value_out;
wire apnea_flag_out;

ecg_top_sim DUT (
    .clk(clk),
    .rst(rst),
    .sample_enable(sample_enable),
    .ecg_sample(ecg_sample),
    .r_peak_out(r_peak_out),
    .rr_value_out(rr_value_out),
    .apnea_flag_out(apnea_flag_out)
);

always #5 clk = ~clk;
integer i;
reg signed [15:0] ecg_mem [0:5999];
reg r_peak_d;
integer peak_count = 0;

always @(posedge clk) begin
    r_peak_d <= r_peak_out;
    if (sample_enable && r_peak_out && !r_peak_d)
        peak_count = peak_count + 1;
end

initial begin
    clk = 0;
    rst = 1;
    sample_enable = 0;
    ecg_sample = 0;

    $readmemh("ecg_data_normal.mem", ecg_mem);

    #100;
    rst = 0;
    i = 0;

    while(i < 6000)
    begin
        ecg_sample = ecg_mem[i];
        repeat(99) begin
            @(posedge clk);
            sample_enable = 0;
        end
        @(posedge clk);
        sample_enable = 1;

        @(posedge clk);
        sample_enable = 0;

        i = i + 1;
    end
    $display("=================================");
    $display("Total R-Peaks Detected = %d", peak_count);
    $display("Apnea Flag Status     = %d", apnea_flag_out);
    $display("=================================");

    $finish;
end

endmodule
