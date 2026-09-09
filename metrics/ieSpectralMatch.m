function S_m = ieSpectralMatch(wave,A,B)
% Calculate the spectral match between two SPDs sampled over the same
% wavelength
%
% Calculate the numerator and denominator using trapezoidal integration
num   = trapz(wave, A .* B);
den_1 = trapz(wave, A.^2);
den_2 = trapz(wave, B.^2);

% Compute S_m
S_m = num / sqrt(den_1 * den_2);

end

