% Read a scene with arbitrary spectral radiance functions, say from
% ISETAuto day
%
% Convert the spectra to Natural Spectra principal components, but
% making sure that the new spectra impact a camera the same way that
% the old spectra would.
%
% Or maybe preserve a couple of cameras?
%
% Scratch for now.
%


%% Write a function to load up a bunch of reflectances

% What did Zheng contribute here?  Can I use that?
wave = 400:10:700;
rBasis = ieReadSpectra('reflectanceBasis',wave);

%% Multiply the reflectances through a number of different lights

% Write a function to load up a bunch of light spectra
%
d50 = ieReadSpectra('D50',wave);
d65 = ieReadSpectra('D65',wave);
d75 = ieReadSpectra('D75',wave);
LED1 = ieReadSpectra('LED_1839',wave);
LED2 = ieReadSpectra('LED_4613',wave);

ieNewGraphWin;
plotRadiance(wave,d75);

%% Load up a couple of sensor spectral files
rgbw = ieReadSpectra('RGBW',wave);
rgbw = ieScale(rgbw,0,1);

cmyg = ieReadSpectra('CMYG',wave);
cmyg = ieScale(cmyg,0,1);

foveon = ieReadSpectra('Foveon',wave);
foveon = ieScale(foveon,0,1);
C = [rgbw,cmyg,foveon];

plotRadiance(wave,C);

%% We want to find weights, w, for a radiance such that
%
% rgbw' * s = rgbw'* rBasis * w
%
% Suppose rgbw is 31 x 4, and rBasis is 31 x 8
% then X = rgbw' * rBasis is 4 x 8
%
% (X' * X) is 8 x 8, but it is probably singular
X = C'*rBasis;
svd(X'*X)

%% So now, we have enough sensor constraints to find a unique w in the natural spectral regime
%
%  s is known
%
%  C'*s = C'*rBasis*w
%  C'*s = X * w
%  X'*C'*s = X'*X * w
%  inv(X'*X)*X'*s = w
%
% As long as X'*X is invertible, we should be OK
%
% The new spectral radiance is rBasis*w.  By construction it is
% natural, and by construction it matches the responses in those
% different camera sensors
%
% 


%% End
