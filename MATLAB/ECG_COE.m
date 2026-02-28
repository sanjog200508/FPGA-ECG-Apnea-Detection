ecg = load('ecg_fixed.txt');  
fs = 100;
start_time = 60; 
duration   = 60;     
start_idx = start_time*fs + 1;
end_idx   = start_idx + duration*fs - 1;
ecg_use = ecg(start_idx:end_idx);
[pks, locs] = findpeaks(ecg_use, ...
    'MinPeakDistance', 60, ...
    'MinPeakHeight', 7300);
num_peaks = length(locs);
fprintf('Number of R-peaks: %d\n', num_peaks);
figure;
subplot(2,1,1)
plot(ecg_use(1:6000))
hold on
plot(locs(locs < 6000), pks(locs < 6000), 'r*')
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
fid = fopen('ecg_rom.coe', 'w');
fprintf(fid, 'memory_initialization_radix = 10;\n');
fprintf(fid, 'memory_initialization_vector =\n');
for i = 1:length(ecg_use)
    if i == length(ecg_use)
        fprintf(fid, '%d;\n', ecg_use(i));
    else
        fprintf(fid, '%d,\n', ecg_use(i));
    end
end
fclose(fid);
