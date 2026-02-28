ecg = load('normalecg1.txt');
ecg0 = ecg - mean(ecg);
fs=100;
ecg_s = movmean(ecg0, 5);
threshold = mean(ecg_s) + 1.2*std(ecg_s);
[peaks, locs] = findpeaks(ecg_s, ...
    'MinPeakHeight', threshold, ...
    'MinPeakDistance', round(0.6*fs));
figure;
subplot(2,1,1)
plot(ecg_s(1:6000))
hold on
plot(locs(locs < 6000), peaks(locs < 6000), 'r*')
xlabel('Samples')
ylabel('Amplitude')
title('R-Peak Detection')
RR = diff(locs) / fs;
subplot(2,1,2)
histogram(RR,30)
xlabel('RR interval (s)')
ylabel('Count')
title('Distribution of RR intervals')
grid on
RR_mean = mean(RR);
RR_std  = std(RR);
RR_max  = max(RR);
long_gap_count = sum(RR > RR_mean + 0.25);
sudden_change_count = sum(abs(diff(RR)) > 0.25);
score = 0;
if RR_std > 0.12
    score = score + 1;
end

if long_gap_count > 5
    score = score + 1;
end

if sudden_change_count > 5
    score = score + 1;
end

if score >= 2
    disp('Sleep Apnea Detected');
else
    disp('Normal');
end

