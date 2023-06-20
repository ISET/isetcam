%% Validate calculations with the wavefront toolbox
% 

wvf = wvfCreate;
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20);

ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');

%%
wvf = wvfSet(wvf,'zcoeffs',2,{'defocus'});
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20);

ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');

%% Make a point array scene
scene = sceneCreate('point array',512,128);
% scene = sceneCreate('grid lines',512,128);

scene = sceneSet(scene,'fov',0.5);
mn = sceneGet(scene,'mean luminance');
scene = sceneSet(scene,'mean luminance',mn*1e5);

sceneWindow(scene);

%% Experiment with different wavefronts

% We can start with any Zernike coefficients
wvf = wvfCreate;    
wvf = wvfSet(wvf,'calc pupil diameter',8);
% wvf = wvfSet(wvf,'zcoeffs',0.5,{'defocus'});
% wvf = wvfSet(wvf,'zcoeffs',-2,{'vertical_astigmatism'});

% There are many parameters on this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
[pupilAmp, params] = wvfPupilAmplitude(wvf,'nsides',3,...
    'dot mean',0, 'dot sd',0, 'dot opacity',0.1, ...
    'line mean',0, 'line sd', 0, 'line opacity',0.1);

% ieNewGraphWin; imagesc(pupilAmp); colormap(gray); axis image

wvf = wvfPupilFunction(wvf,'amplitude',pupilAmp);

% The amplitude of the pupil function is not scaled correctly for
% size.
%{
ieNewGraphWin([], 'wide');
subplot(1,2,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,2,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
%}

%% Show the PSF
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,10);
oi = wvf2oi(wvf);

oi = oiCompute(oi,scene);
oiWindow(oi);
% oiPlot(oi,'psf',550);

%%