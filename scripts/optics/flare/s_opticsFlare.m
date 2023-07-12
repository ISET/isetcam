%%  Experiments with flare
% 
% This is a longer version of v_opticsFlare, with more experiments and
% tests. 
%
% See also
%   v_opticsFlare, s_wvfOI, s_wvfChromatic, 

%%
ieInit;

%% Create some optics with a little defocus and astigmatism

wvf = wvfCreate;    % Default wavefront 5.67 fnumber
pupilMM = 3; flengthM = 7e-3;
wvf = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf = wvfSet(wvf,'focal length',flengthM);

% Now create some flare based on the aperture, dust and scratches.
% There are many parameters for this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
aperture = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);
% ieNewGraphWin; imagesc(aperture); axis image;

% This does not yet work.
wvf = wvfCompute(wvf,'aperture',aperture);

wvfPlot(wvf,'psf','um',550,20,'airy disk');

ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');

%% Illustrate with a point array

scenePoint = sceneCreate('point array',384,128);
scenePoint = sceneSet(scenePoint,'fov',1);

oi = oiCompute(wvf,scenePoint);

oi = oiSet(oi,'name',sprintf('wvf-%d',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi); 
oiSet(oi,'gamma',0.5); drawnow;

%% Show the oi PSF
oiPlot(oi,'psf550');
set(gca,'xlim',[-20 20],'ylim',[-20 20]);

%%  There is a lot of similarity in the PSF, but the spatial scale is not the same

%% HDR Test scene. Green repeating circles

sceneHDR = sceneCreate('hdr');
sceneHDR = sceneSet(sceneHDR,'fov',3);
% sceneWindow(sceneHDR);

[oiApply, pMask, psf] = piFlareApply(sceneHDR,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));

% piFlareApply psf
ieNewGraphWin; mesh(getMiddleMatrix(psf(:,:,15),[120,120]));
title('piFlareApply psf');

% And the effects are therefore quite different.
oiApply = oiSet(oiApply,'name','piFlare');
oiWindow(oiApply);
oiSet(oiApply,'gamma',0.5); drawnow;

%%

oi = oiCompute(wvf,sceneHDR);
oi = oiSet(oi,'name','wvf');
oiWindow(oi);
oiSet(oi,'render flag','hdr');
oiSet(oi,'gamma',1); drawnow;

%%
oi = oiCompute(oiApply,sceneHDR);
oi = oiCrop(oi,'border');
oi = oiSet(oi,'name','piFlare');

oiWindow(oi);
oiSet(oi,'render flag','hdr');
oiSet(oi,'gamma',1); drawnow;

%% Change the number of sides
scenePoint = sceneSet(scenePoint,'fov',1);

nsides = 5;
aperture = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);

% Pupil and PSF
wvf = wvfCompute(wvf,'aperture',aperture);
wvfPlot(wvf,'psf','um',550,20,'airy disk');


%%
oi = oiCompute(wvf,scenePoint);
oi = oiSet(oi,'name',sprintf('wvf-test %d-sides',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi); 
oiSet(oi,'render flag','hdr'); drawnow;

%% Now the HDR scene

oi = oiCompute(wvf,sceneHDR);
oi = oiCrop(oi,'border');
oi = oiSet(oi,'name',sprintf('wvf %d-sides',nsides));

oiWindow(oi); 
oiSet(oi,'render flag','hdr'); drawnow;

%% Add some blur

wvf = wvfSet(wvf,'zcoeffs',1,{'defocus'});

% Now create some flare based on the aperture, dust and scratches.
% There are many parameters for this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
[aperture, params] = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);

wvf = wvfPupilFunction(wvf,'aperture function',aperture);
wvf = wvfComputePSF(wvf,'compute pupil func',false);  % force as false is important
wvfPlot(wvf,'psf','um',550,20,'airy disk');

oi = oiCompute(wvf,sceneHDR);
oi = oiSet(oi,'name','wvf defocus');
oiWindow(oi);
oiSet(oi,'render flag','hdr');
oiSet(oi,'gamma',1); drawnow;

%% END