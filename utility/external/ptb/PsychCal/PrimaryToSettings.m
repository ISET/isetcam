function [settings, badIndex] = PrimaryToSettings(cal, primary)
% [settings, badIndex] = PrimaryToSettings(cal, primary)
%
% Convert from primary color space coordinates to device
% setting coordinates.
%
% This depends on the standard calibration globals.

% 9/26/93    dhb   Added calData argument, badIndex return.
% 4/5/02     dhb, ly  New calling interface.

[gamut, badIndex] = PrimaryToGamut(cal, primary);
settings = GamutToSettings(cal, gamut);
