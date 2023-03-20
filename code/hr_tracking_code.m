close all;
clear;
% Set parameters
fs = 50;
FILTER_DELAY = 20;
n_FFT = 2048;
CutoffFreqHzHP = 40/60; % 40 BPM;
CutoffFreqHzLP = 240/60; % 40 BPM;
full_freq_range = linspace(0, fs, n_FFT);
[extra, lowR] = (min(abs(full_freq_range - CutoffFreqHzHP)));
[extra, highR] = (min(abs(full_freq_range - CutoffFreqHzLP)));
HR_RANGE = highR - lowR + 1;
window = fs * 7;
freq_range = full_freq_range(lowR:highR);
hr_range = freq_range * 60;
% Read csv
golden_hr = csvread('./golden.csv');
golden_hr = golden_hr(:, 1);
table = csvread('./data.csv');
data.ppg_g = table(:, 1);
data.acc_x = table(:, 2);
data.acc_y = table(:, 3);
data.acc_z = table(:, 4);
% Signal processing
data.ppg_g_lpf = HRTRACKING.fir_lpf_4Hz_conv(data.ppg_g, fs);
data.acc_x_lpf = HRTRACKING.fir_lpf_4Hz_conv(data.acc_x, fs);
data.acc_y_lpf = HRTRACKING.fir_lpf_4Hz_conv(data.acc_y, fs);
data.acc_z_lpf = HRTRACKING.fir_lpf_4Hz_conv(data.acc_z, fs);
data.ppg_g_filter = HRTRACKING.fir_hpf_conv(data.ppg_g_lpf, fs);
data.acc_x_filter = HRTRACKING.fir_hpf_conv(data.acc_x_lpf, fs);
data.acc_y_filter = HRTRACKING.fir_hpf_conv(data.acc_y_lpf, fs);
data.acc_z_filter = HRTRACKING.fir_hpf_conv(data.acc_z_lpf, fs);
% Simulation
sim_sec = floor((length(data.ppg_g_filter))/ fs);
ppg_fft = zeros(sim_sec, HR_RANGE);
accx_fft = zeros(sim_sec, HR_RANGE);
accy_fft = zeros(sim_sec, HR_RANGE);
accz_fft = zeros(sim_sec, HR_RANGE);
acc_fft = zeros(sim_sec, HR_RANGE);
denoise_fft = zeros(sim_sec, HR_RANGE);
hr_track = zeros(sim_sec, 1);
sim_timer = 7;
for i =  window:fs:length(data.ppg_g_filter)
    ppg = data.ppg_g_filter(i - window + 1 : i);
    accx = data.acc_x_filter(i - window + 1 : i);
    accy = data.acc_y_filter(i - window + 1 : i);
    accz = data.acc_z_filter(i - window + 1 : i);
    % PPG signal converted to PPG FFT
    ppg_ffti = single(fft(ppg, n_FFT));
    ppg_ffti= abs(ppg_ffti(lowR:highR));
    ppg_fft(sim_timer, :) = ppg_ffti/max(ppg_ffti);
    % ACC signal converted to ACC FFT and merge
    accx_ffti = single(fft(accx, n_FFT));
    accx_ffti = abs(accx_ffti(lowR:highR));
    accx_fft(sim_timer, :) = accx_ffti/max(accx_ffti);
    accy_ffti = single(fft(accy, n_FFT));
    accy_ffti = abs(accy_ffti(lowR:highR));
    accy_fft(sim_timer, :) = accy_ffti/max(accy_ffti);
    accz_ffti = single(fft(accz, n_FFT));
    accz_ffti = abs(accz_ffti(lowR:highR));
    accz_fft(sim_timer, :) = accz_ffti/max(accz_ffti);
    acc_fft(sim_timer, :) = single((accx_fft(sim_timer, :) + accy_fft(sim_timer, :) + accz_fft(sim_timer, :))/3);
    %% STUDENT: Specturm Denoise
    denoise_fft(sim_timer, :) = 0;
    denoise_ffti = abs(ppg_ffti - (accx_ffti + accy_ffti + accz_ffti));
    denoise_fft(sim_timer, :) = denoise_ffti/max(denoise_ffti);
    %% STUDENT: HR Tracking
    hr_track(sim_timer) = 0;
    [val , idx] = max(denoise_fft(sim_timer, 20:90));
    hr_track(sim_timer) = idx;
    sim_timer = sim_timer + 1;    
end
hr_track = round(rescale(hr_track,65,170));
% Calculate AP5, AP10
[availability] = HRTRACKING.availability(hr_track(1:length(golden_hr)), golden_hr);
% Plot Figures
f9=figure(9); f9.Position = [100, 100, 1200, 800];
subplot(2, 2, 1);
imagesc(1:sim_sec, hr_range, ppg_fft'); set(gca,'YDir','normal');
xlabel('time(sec)');ylabel('HR(bpm)');title('PPG Spectrum');
subplot(2, 2, 2);
imagesc(1:sim_sec, hr_range, accz_fft'); set(gca,'YDir','normal');
xlabel('time(sec)');ylabel('HR(bpm)');title('ACC Spectrum');
subplot(2, 2, 3);
imagesc(1:sim_sec, hr_range, denoise_fft'); set(gca,'YDir','normal');
xlabel('time(sec)');ylabel('HR(bpm)');title('Denoise Spectrum');
subplot(2, 2, 4);
hold on;plot(hr_track);hold on; plot(golden_hr); 
xlabel('time(sec)');ylabel('HR(bpm)');
legend({'HR', 'Golden'}, 'Location', 'SouthEast');
title(['HR Tracking AP5: ' num2str(availability(2)) ' AP10: ' num2str(availability(3))]);



