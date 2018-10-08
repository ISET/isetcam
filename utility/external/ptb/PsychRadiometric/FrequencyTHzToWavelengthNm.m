function [wavelengthNm] = FrequencyTHzToWavelengthNm(frequencyTHz)
% [wavelengthNm] = FrequencyTHzToWavelengthNm(frequencyTHz)
%
% Convert the frequency of light, expressed in THz, to 
% the wavelength of light expressed in Nm.
%
% How to do this conversion is available in many places, but I
% got it from Rodieck, First Steps in Seeing, p. 517.  There
% you can read that 500 nm <-> 600 THz.
% 
% 5/23/14  dhb  Wrote it.

NmPerTHz = 300000;

wavelengthNm = NmPerTHz/frequencyTHz;