clear all; close all; clc;

% Add paths for helper functions and audio files
addpath("helpers\");
addpath("assets\audio\");

% Load sample speech signal
[s1, fs] = audioread('speech_mono.wav'); % Load the speech signal

% Select a segment of the speech signal for processing
s1 = s1(45600:52800); 
s2 = s1; % Duplicate the signal for cross-correlation

% Parameters
max_delay = 500; % Maximum delay in samples

% Ground truth delay profile (in samples)
gt_delay = [floor(linspace(0, max_delay, 40))'; ...
            floor(linspace(max_delay, -max_delay, 40))'; ...
            floor(linspace(-max_delay, 0, 40))'];

% Ground truth SNR profile (in dB)
gt_snr = [linspace(20, -5, 40)'; ...
          linspace(-5, 20, 40)'; ...
          linspace(20, -5, 40)'];

numSteps = length(gt_delay); % Number of animation steps

% Create time vector in milliseconds
vt = (0:1/fs:length(s1)/fs - 1/fs)';
vt_ms = vt * 1000;

% Create figure for visualization
figure;
subplot(2,2,[1,2]);
h1 = plot(vt_ms, s1 + 0.5, 'r', 'LineWidth', 2); % Plot signal 1
hold on;
h2 = plot(vt_ms, s2 - 0.5, 'b', 'LineWidth', 2); % Plot signal 2
ylim([-1 1] * 1.1);
legend('Mic 1', 'Mic 2');
tt = title(sprintf('Time delay: %3.2f ms - SNR: %3.2f dB', 0, 40));
xlabel('Time (ms)');
grid on;

subplot(2,2,3);
h3 = plot(0, 0, 'k', 'LineWidth', 2);
title('Classic Cross-Correlation');
xlabel('Lag (ms)');
xlim([-1 1] * max_delay * 1.05 / fs * 1000);
ylim([-1.1 1.1]);
ylabel('Correlation');
grid on;

subplot(2,2,4);
h4 = plot(0, 0, 'k', 'LineWidth', 2);
title('GCC-PHAT Cross-Correlation');
xlabel('Lag (ms)');
xlim([-1 1] * max_delay * 1.05 / fs * 1000);
ylim([-1.1 1.1]);
ylabel('Correlation');
grid on;

% Set font properties for all axes and text in the figure
tta = findall(gca, 'type', 'axes');
set(tta, 'fontname', 'Segoe UI', 'fontsize', 14);
ttf = findall(gcf, 'type', 'text');
set(ttf, 'fontsize', 14);
set(ttf, 'fontname', 'Segoe UI');
set(gcf, 'color', 'w', 'units', 'normalized');
box on;
set(gcf, 'position', [0.1567 0.0977 0.7416 0.6081]);

% Function to add noise to achieve a specified SNR
add_noise = @(signal, SNR) signal + sqrt(var(signal) / (10^(SNR / 10))) * randn(size(signal));

pause

% Initialize GIF filename
gif_filename = 'gccphat_animation.gif';

% Animation loop
for k = 1:numSteps
    SNR = gt_snr(k); % Get current SNR value
    
    % Calculate current delay
    delay = gt_delay(k);
    
    % Apply delay to signals
    if (delay >= 0)
        delayed_s1 = [zeros(delay, 1); s1(1:end-delay)];
        delayed_s2 = s2;
    else
        delayed_s1 = s1;
        delayed_s2 = [zeros(-delay, 1); s2(1:end+delay)];
    end
    
    % Add noise to delayed signals
    delayed_s1 = add_noise(delayed_s1, SNR);
    delayed_s2 = add_noise(delayed_s2, SNR);
    
    % Compute classic cross-correlation
    [xcorr_vals, lags] = xcorr(delayed_s1, delayed_s2);
    xcorr_vals = xcorr_vals ./ max(abs(xcorr_vals)); % Normalize cross-correlation
    lags_ms = lags / fs * 1000; % Convert lags to milliseconds
    
    % Compute GCC-PHAT cross-correlation (assumes GCCPHAT function is available)
    [G, axe_ms, ~] = GCCPHAT(delayed_s1, delayed_s2, fs, 1, 100, 8000);
    
    % Update signal plots
    set(h1, 'YData', delayed_s1 + 0.5);
    set(h2, 'YData', delayed_s2 - 0.5);
    
    % Update cross-correlation plots
    set(h3, 'XData', lags_ms);
    set(h3, 'YData', xcorr_vals);
    set(h4, 'XData', axe_ms);
    set(h4, 'YData', G);
    
    % Update title with current delay and SNR
    set(tt, 'String', sprintf('Time delay: %3.2f ms - SNR: %3.2f dB', delay / fs * 1000, SNR));
    
    % Capture the plot as an image 
    frame = getframe(gcf); 
    img = frame2im(frame); 
    [imind, cm] = rgb2ind(img, 256); 
    
    % Write to the GIF File 
    if k == 1 
        imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1); 
    else 
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1); 
    end
    
    % Pause to create animation effect
    pause(0.1);
end
