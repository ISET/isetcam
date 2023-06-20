%% Validate calculations with the wavefront toolbox
% 
%  Use the wavefront toolbox for calculations with shift-invariant
%  optics and flare.
%
% 
%% Diffraction limited case

wvf = wvfCreate;

% This increases the spatial resolution.
fieldsize = wvfGet(wvf,'fieldsizemm');
wvf = wvfSet(wvf,'fieldsizemm',2*fieldsize);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20,'airydisk');

%{
ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');
%}

%%  Now with a little defocus
wvf = wvfSet(wvf,'zcoeffs',0.5,{'defocus'});
fieldsize = wvfGet(wvf,'fieldsizemm');
wvf = wvfSet(wvf,'fieldsizemm',2*fieldsize);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20);

%{
ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');
%}

%% Compute with a point array scene

scene = sceneCreate('point array',512,128,'d65');
scene = sceneSet(scene,'fov',0.5);

% Make the points very bright.  It would be better to make them a
% little bigger, though.
mn = sceneGet(scene,'mean luminance');
scene = sceneSet(scene,'mean luminance',mn*1e8);

% sceneWindow(scene);

%% Experiment with different wavefronts

% We can start with any Zernike coefficients
wvf = wvfCreate;
fieldsize = wvfGet(wvf,'fieldsizemm');
wvf = wvfSet(wvf,'fieldsizemm',2*fieldsize);
wvf = wvfSet(wvf,'calc pupil diameter',3);
wvf = wvfSet(wvf,'wave',550);
wvf = wvfSet(wvf,'focal length',0.017);

% wvf = wvfSet(wvf,'zcoeffs',0.5,{'defocus'});
% wvf = wvfSet(wvf,'zcoeffs',-2,{'vertical_astigmatism'});

% There are many parameters on this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
[pupilAmp, params] = wvfPupilAmplitude(wvf,'nsides',3,...
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
oi = oiSet(oi,'name','wvf');

% Show the PSF
oiPlot(oi,'psf550');
set(gca,'xlim',[-10 10],'ylim',[-10 10]);

oi = oiCrop(oi,'border');
oiWindow(oi);

%% The same scene through piFlareApply

% wvfGet(wvf,'calc pupil diameter','mm')
oi = piFlareApply(scene,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));
oi = oiSet(oi,'name','flare');
oiWindow(oi);


% piFlareApply does not put the proper OTF information in the optical
% image. Therefore, this plot is not correct.  The photons, though,
% are approximately correct.
%{
 oiPlot(oi,'psf550');
 set(gca,'xlim',[-10 10],'ylim',[-10 10]);
%}

%%