function fft_out = COLORE_FREQ(sigin, fs, fmin, fmax, mode)
% COLORE_FREQ Filters the FFT of the input signal within specified frequency bands.
%
% This function applies a frequency band filter to the FFT of the input signal.
% The mode parameter determines whether the frequencies within the band or outside the band are retained.
%
% Usage:
%   fft_out = COLORE_FREQ(sigin, fs, fmin, fmax, mode)
%
% Inputs:
%   sigin - Input signal
%   fs    - Sampling frequency (Hz)
%   fmin  - Lower frequency bound (Hz)
%   fmax  - Upper frequency bound (Hz)
%   mode  - Filtering mode (1: retain frequencies within the band, 0: discard frequencies within the band)
%
% Outputs:
%   fft_out - Filtered FFT of the input signal
%
% Example:
%   sigin = randn(32768, 1); % Create a random signal
%   fs = 48000; % Sampling frequency
%   fmin = 300; % Lower frequency bound
%   fmax = 3000; % Upper frequency bound
%   mode = 1; % Retain frequencies within the band
%   fft_out = COLORE_FREQ(sigin, fs, fmin, fmax, mode);
%
% Patrick Marmaroli

% Compute the FFT of the input signal
siginfft = fft(sigin);
nfft = length(siginfft);

% Create positive and negative frequency vectors
vfc_pos = linspace(0, fs/2, nfft/2 + 1);
vfc_neg = -fliplr(vfc_pos(2:end-1));
vfc = [vfc_pos, vfc_neg];

% Determine frequency indices within and outside the specified band
indFreqInBand = vfc >= fmin & vfc <= fmax | vfc <= -fmin & vfc >= -fmax;
indFreqOutBand = vfc < fmin & vfc > -fmin | vfc < -fmax | vfc > fmax;

% Compute the magnitude of the FFT
absS = abs(siginfft);

% Apply the frequency band filter based on the mode
switch mode
    case 1
        absS(indFreqOutBand, :) = 0; % Retain frequencies within the band
    case 0
        absS(indFreqInBand, :) = 0; % Discard frequencies within the band
end

% Reconstruct the filtered FFT
fft_out = absS .* exp(1i * angle(siginfft));
end
