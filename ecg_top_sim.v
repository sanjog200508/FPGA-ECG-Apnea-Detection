module ecg_top_sim(
    input clk,
    input rst,
    input sample_enable,
    input signed [15:0] ecg_sample,
    output r_peak_out,
    output [15:0] rr_value_out,
    output apnea_flag_out
);

wire r_peak;
wire [15:0] rr_value;
wire apnea_flag;

// R-Peak Detector
r_peak_detector peak_inst (
    .clk(clk),
    .rst(rst),
    .sample_en(sample_enable),
    .ecg_in(ecg_sample),
    .r_peak(r_peak)
);

// RR Interval
RR_interval RR_inst (
    .clk(clk),
    .rst(rst),
    .sample_en(sample_enable),
    .r_peak(r_peak),
    .rr_value(rr_value)
);

// Apnea Detection
apnea_detection apnea_inst(
    .clk(clk),
    .rst(rst),
    .sample_en(sample_enable),
    .r_peak(r_peak),
    .rr_value(rr_value),
    .apnea_flag(apnea_flag)
);

assign r_peak_out      = r_peak;
assign rr_value_out    = rr_value;
assign apnea_flag_out  = apnea_flag;

endmodule
