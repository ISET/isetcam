%%  Flare simulations using wvf methods
% 
%
% See also 
%   v_opticsVWF, piFlareApply
%


%%
ieInit;

%%
scene = sceneCreate('point array',128,32);
scene = sceneSet(scene,'fov',1);
sceneWindow(scene);

%% Experiment with different wavefronts

% We can start with any Zernike coefficients
wvf = wvfCreate;
% fieldsize = wvfGet(wvf,'fieldsizemm');
% wvf = wvfSet(wvf,'fieldsizemm',2*fieldsize);
wvf = wvfSet(wvf,'calc pupil diameter',3);
wvf = wvfSet(wvf,'wave',550);
wvf = wvfSet(wvf,'focal length',0.017);

% wvf = wvfSet(wvf,'zcoeffs',0.5,{'defocus'});
% wvf = wvfSet(wvf,'zcoeffs',-2,{'vertical_astigmatism'});

% There are many parameters on this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
[pupilAmp, params] = wvfPupilAmplitude(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);
% ieNewGraphWin; imagesc(pupilAmp); colormap(gray); axis image

wvf = wvfPupilFunction(wvf,'amplitude',pupilAmp);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,10,'airy disk');

%{
ieNewGraphWin([], 'wide');
subplot(1,2,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,2,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
%}

%% Calculate the oi from the scene, but using the wvf
oi = wvfApply(scene,wvf);

% Show the oi PSF
oiPlot(oi,'psf550');
set(gca,'xlim',[-10 10],'ylim',[-10 10]);

oi = oiSet(oi,'name',sprintf('wvf-%d',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi);
oiSet(oi,'gamma',0.5);

%% The same scene through piFlareApply

% Seem more blurry, but it should match, no?

[oi, pMask, psf] = piFlareApply(scene,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));
oi = oiSet(oi,'name',sprintf('flare-%d',nsides));
oiWindow(oi);

% piFlareApply does not put the proper OTF information in the optical
% image. Therefore, the oiPlot is not correct.  The photons, though,
% are approximately correct.
ieNewGraphWin; 
mesh(getMiddleMatrix(psf(:,:,15),20));
grid on;
%{
oiPlot(oi,'psf550');
set(gca,'xlim',[-10 10],'ylim',[-10 10]);
%}

%% HDR Test scene
% Uses sceneHDRLights
% {
scene = sceneCreate('hdr');
scene = sceneSet(scene,'fov',1);
% sceneWindow(scene);
%}

oi = wvfApply(scene,wvf);
oi = oiSet(oi,'name','wvf');

oiWindow(oi);
oiSet(oi,'gamma',0.5);

%% The same scene through piFlareApply

% wvfGet(wvf,'calc pupil diameter','mm')
[oi, pMask, psf] = piFlareApply(scene,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));
oi = oiSet(oi,'name','flare');
oiWindow(oi);
oiSet(oi,'gamma',0.5);

%%
