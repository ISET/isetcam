% Read a scene with arbitrary spectral radiance functions, say from
% ISETAuto day
%
% Convert the spectra to Natural Spectra principal components, making
% sure that the new spectra impact a camera and the human cones the
% same way that the old spectra would.
%
% Alternatively, it should also be possible to replace with natural
% spectra in a way that preserves the response of a couple of cameras.
%
% Scratch for now.
%


%% Write a function to load up a bunch of reflectances

% What did Zheng implement here?  Can I use that?
% Probably I should load up a bunch of surfaces here, not the basis,
% and then a bunch of lights.  But I think this is probably formally
% equivalent if I multiply the basis functions by the lights and then
% take the top 6 or 8 principal components, matching the number of
% sensors we design.
wave = 400:10:700;
[rBasis,~,comment] = ieReadSpectra('reflectanceBasis',wave);

%% Multiply the reflectances through a number of different lights

% Write a function to load up a bunch of light spectra
% Combine the surfaces
%
d50 = ieReadSpectra('D50',wave);
d65 = ieReadSpectra('D65',wave);
d75 = ieReadSpectra('D75',wave);
LED1 = ieReadSpectra('LED_1839',wave);
LED2 = ieReadSpectra('LED_4613',wave);

ieNewGraphWin;
plotRadiance(wave,d75);

%% Load up a couple of sensor spectral files

% A camera we used in the simulation
rgb = ieReadSpectra('RGB',wave);
rgb = ieScale(rgb,0,1);

% The human visual system
cones = ieReadSpectra('Stockman',wave);
cones = ieScale(cones,0,1);
C = [rgb,cones];

% svd(C)

% Maybe we should choose n spectral bands to make the weight estimates
% unique.
cmy = ieReadSpectra('CMY',wave);
cmy = ieScale(cmy,0,1);

C = [rgb,cmy,cones];
% svd(C)

plotRadiance(wave,C);

%% We want to find weights, w, for a radiance such that
%
% C' * s = C'* rBasis * w
%
% Suppose C is 31 x 9, and rBasis is 31 x 8
% then 
%
% X = C' * rBasis 
% 
% is 9 x 8
%
% 
% (X' * X) is 8 x 8 and close to singular.  But probably usable.
%
X = C'*rBasis;
svd(X'*X)

%% We choose enough channels to find a unique set of weights for the natural spectra 
%
%  s is known, w are the weights
%
%  C'*s = C'*rBasis*w
%  X = C'*rBasis
%
%  C'*s = X * w
%  X'*C'*s = X'*X * w
%  inv(X'*X)*X'*s = w
%
% We need X'*X to be invertible, we should be OK.  We should use the
% divide (\) for estimating, rather than inv(), I believe.
%
% When w is estimated, the spectral radiance is rBasis*w.  By
% construction it is natural, and by construction it matches the
% responses in the different channels.
%
% We might consider matching channels in 8 spectral bands, by the way.


%% End
