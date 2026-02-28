module RR_interval (
    input clk,
    input rst,
    input sample_en,     // 100 Hz enable
    input r_peak,
    output reg [15:0] rr_value
);

reg [15:0] counter = 0;

always @(posedge clk or posedge rst)
begin
    if (rst) begin
        counter <= 0;
        rr_value <= 0;
    end
    else if (sample_en) begin
        counter <= counter + 1;

        if (r_peak) begin
            rr_value <= counter;  // store RR
            counter <= 0;         // reset for next interval
        end
    end
end

endmodule
