ecg = load('ecg_data.txt');   
max_val = max(abs(ecg));
scale = 0.8 * 32767 / max_val;
ecg_fixed = round(ecg * scale);
dlmwrite('ecg_fixed.txt', ecg_fixed, 'delimiter', '\n');
