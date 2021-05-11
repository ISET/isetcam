function params = imageHparams
% Return default parameters for image harmonic
%
%      params = imageHparms
%
% We create harmonics for visual psychophysics testing.  This function
% returns the default parameter structured used in creating harmonics.
%
% More comments needed about length of freq, and so forth.
%
% Example:
%   params = imageHparms;
%
% See also:  sceneCreate('harmonic',imageHparams);
%
% Copyright ImagEval Consultants, LLC, 2009

params.freq = 2;
params.contrast = 1;
params.ang = 0;
params.ph = 1.5708;
params.row = 128;
params.col = 128;
params.GaborFlag = 0;

return;
