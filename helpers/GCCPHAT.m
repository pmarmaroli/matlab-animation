function [G, axe_ms, axe_spl] = GCCPHAT(rec, ref, fs, norm, f1, f2)
% GCCPHAT Computes the Generalized Cross-Correlation with Phase Transform (GCC-PHAT)
%
% This function calculates the cross-correlation between two signals, with
% an optional PHAT weighting for more robust time delay estimation.
%
% Usage:
%   [G, axe_ms, axe_spl] = GCCPHAT(rec, ref, fs)
%   [G, axe_ms, axe_spl] = GCCPHAT(rec, ref, fs, norm)
%   [G, axe_ms, axe_spl] = GCCPHAT(rec, ref, fs, norm, f1, f2)
%
% Inputs:
%   rec  - Received signal
%   ref  - Reference signal
%   fs   - Sampling frequency (Hz)
%   norm - (Optional) Normalization flag (default = 1)
%   f1   - (Optional) Lower frequency bound for filtering (Hz)
%   f2   - (Optional) Upper frequency bound for filtering (Hz)
%
% Outputs:
%   G       - Cross-correlation result
%   axe_ms  - Time vector in milliseconds
%   axe_spl - Time vector in samples
%
% Example:
%   ref = randn(32768, 1); % Create a reference signal
%   sig = [zeros(5, 1); ref(1:end-5)]; % Add a delay
%   fs = 48000;
%   [G_classic, axe_ms, axe_spl] = GCCPHAT(sig, ref, fs);
%   [G_phat, axe_ms, axe_spl] = GCCPHAT(sig, ref, fs, 1, 0, fs/2);
%
%   figure;
%   plot(axe_spl, G_classic, 'k');
%   hold on;
%   plot(axe_spl, G_phat, 'r--');
%
% Patrick Marmaroli

% Ensure the signals are of the same length
maxLength = max(length(rec), length(ref));
nfft = 2^nextpow2(maxLength);

if nfft ~= maxLength
    rec = [rec; zeros(nfft - length(rec), 1)];
    ref = [ref; zeros(nfft - length(ref), 1)];
end

% Set default normalization flag
if nargin < 4
    norm = 1;
end

% Compute the FFTs, with optional frequency band filtering
if nargin > 4
    fft1 = COLORE_FREQ(rec, fs, f1, f2, 1);
    fft2 = COLORE_FREQ(ref, fs, f1, f2, 1);
else
    fft1 = fft(rec, nfft);
    fft2 = fft(ref, nfft);
end

% Compute power spectral density
Pxy = fft1 .* conj(fft2);

% Apply PHAT weighting if frequency bounds are specified
if nargin > 4
    Denom = abs(Pxy);
    Denom(Denom <= 1e-6) = 1e-6; % Prevent division by zero
else
    Denom = 1;
end

% Compute the cross-correlation
G = fftshift(real(ifft(Pxy ./ Denom)));

% Normalize the cross-correlation result
if norm == 1
    G = G ./ max(abs(G));
end

% Generate time vectors
if nargout > 1
    axe_spl = (1:length(G)) - nfft / 2 - 1;
    axe_ms = axe_spl ./ fs * 1000;
end
end
