% ieRodSpectralSensitivity.m
% 
% Estimated rod photopigment (rhodopsin) spectral sensitivity
%
% Here is a picture of the rod photopigment spectral sensitivity,
% normalized.
%
%   https://www.unm.edu/~toolson/human_cone_response.htm
%
% At 400nm is is down to around 0.3 of the peak.  You can see the same
% value in the original Wald and Brown paper, Human Rhodopsin,1958,
% figure 2 
%
% That is the same as we get with this calculation
%
% See also
%   macular.m

% Start with scotopic luminosity, and then remove the lens
wave = 400:700;
[scotopic,wave]  = ieReadSpectra('scotopicLuminosity.mat',wave);
ieNewGraphWin;plot(wave,scotopic);

% Human lens transmittance
lensT = oiGet(oi,'optics transmittance',wave);
plot(wave,lensT);

% Divide out the lens
rods  = ieScale(scotopic ./lensT,1);
ieNewGraphWin; plot(wave,rods)

% Set the peak based on Rodieck. Maybe this should be normalized?

rodPeakAbsorbtance = 0.66;             % from Rodieck
rods  = rods*rodPeakAbsorbtance;
ieNewGraphWin; plot(wave,rods)
fname = fullfile(isetRootPath,'data','human','rods.mat');
ieSaveSpectralFile(wave,rods,'Estimated rhodopsin dividing scotopic sensitivity by human lens',fname);

%% END