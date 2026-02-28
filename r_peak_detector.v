module r_peak_detector(
    input clk,
    input rst,
    input sample_en,
    input signed [15:0] ecg_in,
    output reg r_peak
);

parameter MIN_DIST  = 60;
parameter THRESHOLD = 16'sd7300;  

reg signed [15:0] prev = 0;
reg signed [15:0] curr = 0;
reg signed [15:0] next = 0;

reg [15:0] distance = MIN_DIST;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        prev <= 0;
        curr <= 0;
        next <= 0;
        distance <= MIN_DIST;
        r_peak <= 0;
    end
    else if(sample_en)
    begin
        // Shift samples
        prev <= curr;
        curr <= next;
        next <= ecg_in;

        // Increase refractory counter
        distance <= distance + 1;

        // Peak detection: rising -> falling transition
        if( (curr > prev) &&          // rising
            (curr >= next) &&         // flat or falling
            (curr > THRESHOLD) &&
            (distance >= MIN_DIST) )
        begin
            r_peak <= 1;
            distance <= 0;
        end
        else
        begin
            r_peak <= 0;
        end
    end
end

endmodule
