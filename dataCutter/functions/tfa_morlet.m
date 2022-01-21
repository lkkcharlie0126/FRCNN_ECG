function TFmap = tfa_morlet(td, fs, fmin, fmax, fstep)
%tfa_morlet: time frequency analysis using Morlet Wavelet.
%   [TF] = tfa_morlet(td, fs, fmin, fmax, fstep) returns the time-frequency table
%   calculated by using the Morlet Wavelet, where 
%     td is the input temporal data,
%     fs is the sampling rate, 
%     [fmin:fstep:fmax] constitute the resulted frequency resolution.
%
%   Yong-Sheng Chen
%   modified by Chia-Feng Lu 2013.11.08

TFmap = [];
for fc=fmin:fstep:fmax
    MW = MorletWavelet(fc/fs);  % calculate the Morlet Wavelet by giving the central freqency
    cr = conv(td, MW, 'same');
    
    TFmap = [TFmap; abs(cr)];
end

function MW = MorletWavelet(fc)
%MorletWavelet: Morlet wavelet.
%   [MW] = MorletWavelet(fc) returns coefficients of 
%   the Morlet wavelet, where fc is the central frequency.
%   
%   MW(fc,t) = A * exp(-t^2/(2*sigma_t^2)) * exp(2i*PI*fc*t)
%            = A * exp(t*(t/(-2*sigma_t^2)+2i*PI*fc))
%   A = 1/(sigma_t*PI^0.5)^0.5,
%   sigma_t = 1/(2*PI*sigma_f)
%   sigma_f = fc/F_RATIO
%
%   The effective support of this wavelet is determined by fc and two constants,
%   fc/sigma_f and Z_alpha/2.
%
%   Yong-Sheng Chen


% Compute values of the Morlet wavelet.

F_RATIO = 7;    % frequency ratio (number of cycles): fc/sigma_f, should be greater than 5
Zalpha2 = 3.3;  % value of Z_alpha/2, when alpha=0.001

sigma_f = fc/F_RATIO;
sigma_t = 1/(2*pi*sigma_f);
A = 1/sqrt(sigma_t*sqrt(pi));
max_t = ceil(Zalpha2 * sigma_t);

t = -max_t:max_t;

%MW = A * exp((-t.^2)/(2*sigma_t^2)) .* exp(2i*pi*fc*t);
v1 = 1/(-2*sigma_t^2);
v2 = 2i*pi*fc;
MW = A * exp(t.*(t.*v1+v2));