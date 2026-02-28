module apnea_detection (
    input clk,
    input rst,
    input sample_en,        // 100 Hz enable
    input r_peak,           // 1-cycle pulse
    input [15:0] rr_value,  // RR interval in samples
    output reg apnea_flag
);

// ================= PARAMETERS =================
parameter GAP_THRESHOLD   = 16'd25;    // 0.25 sec
parameter VAR_THRESHOLD   = 32'd144;   // (12 samples)^2
parameter WINDOW_SAMPLES  = 13'd5999;  // 60 sec window @100Hz

reg [12:0] sample_counter = 0;

reg [31:0] sum_rr = 0;
reg [47:0] sum_rr_sq = 0;
reg [7:0]  beat_count = 0;

reg [7:0] long_gap_count = 0;
reg [7:0] sudden_change_count = 0;

reg [15:0] prev_rr = 0;

reg [31:0] mean;
reg [31:0] variance;
reg [2:0]  score;

wire [15:0] rr_diff;
assign rr_diff = (rr_value > prev_rr) ?
                 (rr_value - prev_rr) :
                 (prev_rr - rr_value);
always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        sample_counter <= 0;
        sum_rr <= 0;
        sum_rr_sq <= 0;
        beat_count <= 0;
        long_gap_count <= 0;
        sudden_change_count <= 0;
        apnea_flag <= 0;
        prev_rr <= 0;
        mean <= 0;
        variance <= 0;
        score <= 0;
    end

    else if (sample_en)
    begin
        if (sample_counter == WINDOW_SAMPLES)
        begin
            sample_counter <= 0;

            if (beat_count > 1)
            begin
                // Compute mean
                mean <= sum_rr / beat_count;

                // Compute variance (no sqrt needed)
                variance = (sum_rr_sq / beat_count) - (mean * mean);

                score = 0;

                if (variance > VAR_THRESHOLD)
                    score = score + 1;

                if (long_gap_count > 5)
                    score = score + 1;

                if (sudden_change_count > 5)
                    score = score + 1;

                if (score >= 2)
                    apnea_flag <= 1;
                else
                    apnea_flag <= 0;
            end
            else
                apnea_flag <= 0;

            // Reset window statistics
            sum_rr <= 0;
            sum_rr_sq <= 0;
            beat_count <= 0;
            long_gap_count <= 0;
            sudden_change_count <= 0;
        end
        else
        begin
            sample_counter <= sample_counter + 1;

            if (r_peak)
            begin
                sum_rr <= sum_rr + rr_value;
                sum_rr_sq <= sum_rr_sq + (rr_value * rr_value);
                beat_count <= beat_count + 1;

                // Sudden RR change
                if (rr_diff > GAP_THRESHOLD)
                    sudden_change_count <= sudden_change_count + 1;

                // Long gap detection
                if (rr_diff > (GAP_THRESHOLD << 1))   
                    long_gap_count <= long_gap_count + 1;

                prev_rr <= rr_value;
            end
        end
    end
end

endmodule
