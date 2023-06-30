%% Flare simulation using the wvf method
% 
% The flare simulation operates by creating pupil amplitude functions that
% have non-circular shapes (polygons) and contain scratches and dust in the
% aperture itself.
%
% See also 
%   v_opticsVWF

%%
ieInit;

%% A simple test scene
scene = sceneCreate('point array',128,32);
scene = sceneSet(scene,'fov',1);
% sceneWindow(scene);

%% Experiment with different wavefronts

% We can start with any Zernike coefficients
wvf = wvfCreate;
wvf = wvfSet(wvf,'calc pupil diameter',3);
wvf = wvfSet(wvf,'wave',550);
wvf = wvfSet(wvf,'focal length',0.017);

% fieldsize = wvfGet(wvf,'fieldsizemm');
% wvf = wvfSet(wvf,'fieldsizemm',2*fieldsize);

% There are many parameters for this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
[pupilAmp, params] = wvfPupilAmplitude(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);
% ieNewGraphWin; imagesc(pupilAmp); colormap(gray); axis image

% At this point the pupil function is good, which I check by plotting
% the images below in the block comment.  
wvf = wvfPupilFunction(wvf,'amplitude',pupilAmp);

% We do not want the wvfComputePSF to recompute the pupil function.  So it
% is crucial to set 'force' to false.  That way we keep the pupil
% function and just compute the PSF.
wvf = wvfComputePSF(wvf,'lca',false,'force',false);

wvfPlot(wvf,'psf','um',550,10,'airy disk');

%{
ieNewGraphWin([], 'wide');
subplot(1,2,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,2,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
%}

%{
% Even if I change the defocus, the amp and phase are OK.
wvf = wvfSet(wvf,'zcoeff',1,{'defocus'});
wvf = wvfPupilFunction(wvf,'amplitude',pupilAmp);
%}

%% Convert to an OI

oiHuman = wvf2oi(wvf);
[uData, fig] = oiPlot(oiHuman,'psf 550');
psfPlotrange(fig,uData);

title(sprintf("fNumber %.2f Wave %.0f Airy Diam %.2f",oiGet(oi,'optics fnumber'),thisWave,AD));

oiDL = wvf2oi(wvf,'model','diffraction limited');
oiPlot(oiDL,'psf 550');

%% Calculate the oi from the scene, but using the wvf

%{
% Also works
 oi = wvfApply(scene,wvf,'lca',false,'force',false);
 oi = oiCompute(oi,scene);
%}
oi = oiCompute(wvf,scene);

% Show the oi PSF
oiPlot(oi,'psf550');
set(gca,'xlim',[-10 10],'ylim',[-10 10]);

oi = oiSet(oi,'name',sprintf('wvf-%d',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi);
oiSet(oi,'gamma',0.5); drawnow;

%% HDR Test scene

scene = sceneCreate('hdr');
scene = sceneSet(scene,'fov',1);

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','wvf');
oiWindow(oi);
oiSet(oi,'gamma',0.5);

%% The same scene through piFlareApply

% wvfGet(wvf,'calc pupil diameter','mm')
[oiApply, pMask, psf] = piFlareApply(scene,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));
oiApply = oiSet(oiApply,'name','flare');
oiWindow(oiApply);
oiSet(oiApply,'gamma',0.5);

%%
