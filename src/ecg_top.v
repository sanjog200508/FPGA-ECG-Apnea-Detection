module ecg_top(
    input clk,
    input rst,
    input mode,              // Switch: 0 = Normal, 1 = Apnea
    output [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an
);

// Mode Change Detection + Internal Reset

reg mode_d;

always @(posedge clk)
    mode_d <= mode;

wire mode_changed;
assign mode_changed = mode ^ mode_d;

wire system_reset;
assign system_reset = rst | mode_changed;

// 100 Hz sampling (from 100 MHz clock)

reg [12:0] addr = 0;
reg [19:0] slow = 0;

wire sample_enable;
assign sample_enable = (slow == 20'd999999);

always @(posedge clk or posedge system_reset)
begin
    if(system_reset)
    begin
        addr <= 0;
        slow <= 0;
    end
    else
    begin
        if(slow == 20'd999999)
            slow <= 0;
        else
            slow <= slow + 1;

        if(sample_enable)
        begin
            if(addr == 13'd5999)
                addr <= 0;
            else
                addr <= addr + 1;
        end
    end
end

// ECG ROMs (Normal + Apnea)

wire signed [15:0] normal_ecg;
wire signed [15:0] apnea_ecg;
wire signed [15:0] ecg_sample;

ecg_rom normal_inst (
    .clk(clk),
    .addr(addr),
    .ecg_out(normal_ecg)
);

apnea_ecg_rom apnea_inst (
    .clk(clk),
    .addr(addr),
    .ecg_out(apnea_ecg)
);

// MUX selection
assign ecg_sample = (mode == 0) ? normal_ecg : apnea_ecg;

// R-Peak Detector
wire r_peak;

r_peak_detector peak_inst (
    .clk(clk),
    .rst(system_reset),
    .sample_en(sample_enable),
    .ecg_in(ecg_sample),
    .r_peak(r_peak)
);

// RR Interval

wire [15:0] rr_value;

RR_interval RR_inst (
    .clk(clk),
    .rst(system_reset),
    .sample_en(sample_enable),
    .r_peak(r_peak),
    .rr_value(rr_value)
);
// Apnea Detection

wire apnea_flag;

apnea_detection apnea_inst1(
    .clk(clk),
    .rst(system_reset),
    .sample_en(sample_enable),
    .r_peak(r_peak),
    .rr_value(rr_value),
    .apnea_flag(apnea_flag)
);

// 6000-Sample Peak Counting (BPM)

reg [12:0] sample_count = 0;
reg [7:0]  peak_count   = 0;
reg [7:0]  final_count  = 0;

always @(posedge clk or posedge system_reset)
begin
    if(system_reset)
    begin
        sample_count <= 0;
        peak_count   <= 0;
        final_count  <= 0;
    end
    else if(sample_enable)
    begin
        if(sample_count == 13'd5999)
        begin
            final_count <= peak_count;
            sample_count <= 0;
            peak_count <= 0;
        end
        else
        begin
            sample_count <= sample_count + 1;

            if(r_peak)
                peak_count <= peak_count + 1;
        end
    end
end

// Live R-Peak Blink

reg [24:0] blink_counter = 0;
reg blink_led = 0;

always @(posedge clk or posedge system_reset)
begin
    if(system_reset)
    begin
        blink_counter <= 0;
        blink_led <= 0;
    end
    else
    begin
        if(r_peak)
        begin
            blink_led <= 1;
            blink_counter <= 25'd20_000_000;
        end
        else if(blink_counter > 0)
            blink_counter <= blink_counter - 1;
        else
            blink_led <= 0;
    end
end

// BCD Conversion for 7-Segment

reg [3:0] hundreds;
reg [3:0] tens;
reg [3:0] ones;

always @(*) begin
    hundreds = final_count / 100;
    tens     = (final_count % 100) / 10;
    ones     = final_count % 10;
end

// 7-Segment Multiplexing (Basys 3)

reg [19:0] refresh_counter = 0;
reg [1:0] digit_select = 0;
reg [3:0] current_digit;

always @(posedge clk)
    refresh_counter <= refresh_counter + 1;

always @(posedge clk)
    digit_select <= refresh_counter[19:18];

always @(*) begin
    case(digit_select)
        2'b00: begin
            an = 4'b1110;
            current_digit = ones;
        end
        2'b01: begin
            an = 4'b1101;
            current_digit = tens;
        end
        2'b10: begin
            an = 4'b1011;
            current_digit = hundreds;
        end
        default: begin
            an = 4'b0111;
            current_digit = 4'd0;
        end
    endcase
end

// 7-Segment Decoder (Active LOW)

always @(*) begin
    case(current_digit)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
end

// LED Mapping

assign led[0]      = blink_led;
assign led[15]     = apnea_flag;
assign led[14:1]   = 14'b0;

endmodule
