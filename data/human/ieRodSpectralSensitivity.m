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
thisLens = Lens('wave',wave);
lensT = thisLens.transmittance;
plot(wave,lensT);

% Divide out the lens
rods  = ieScale(scotopic ./lensT,1);
ieNewGraphWin; plot(wave,rods)

% We do not divide out the macular pigment because the rods are mainly
% outside of the macula.  But we could.
% macP = macular(wave);
% rods = ieScale(rods ./ macP.transmittance,1);

% Set the peak based on Rodieck. Maybe this should be normalized?

rodPeakAbsorbtance = 0.66;             % from Rodieck
rods  = rods*rodPeakAbsorbtance;
ieNewGraphWin; plot(wave,rods); grid on;

%%  Save
fname = fullfile(isetRootPath,'data','human','rods.mat');
ieSaveSpectralFile(wave,rods,'Estimated rhodopsin dividing scotopic sensitivity by human lens',fname);

%% END