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

%% Experiment with different wavefronts

thisWave = 550;

% We can start with any Zernike coefficients
wvf = wvfCreate;
wvf = wvfSet(wvf,'calc pupil diameter',3);
wvf = wvfSet(wvf,'wave',thisWave);
wvf = wvfSet(wvf,'focal length',0.017);

% There are many parameters for this function, including dot mean, line
% mean, dot sd, line sd, line opacity.  They are returned in params
nsides = 3;
[apertureFunction, params] = wvfAperture(wvf,'nsides',nsides,...
    'dot mean',20, 'dot sd',3, 'dot opacity',0.5, ...
    'line mean',20, 'line sd', 2, 'line opacity',0.5);
% ieNewGraphWin; imagesc(pupilAmp); colormap(gray); axis image

% The pupil function is updated.
wvf = wvfPupilFunction(wvf,'amplitude',apertureFunction);

% We do not want the wvfComputePSF to recompute the pupil function.
% So it is crucial to set 'force' to false, which is interpreted as
% 'do not recompute the pupil function.'  The default pupil function
% is false, but I include this here to explain why.
%
% I think the code should be refactored and 'force' should be renamed.
% 
wvf = wvfComputePSF(wvf,'lca',false,'force',false);
wvfPlot(wvf,'psf','um',550,10,'airy disk');

ieNewGraphWin([], 'wide');
subplot(1,2,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,2,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');

%% Convert to an OI

oiHuman = wvf2oi(wvf);
[uData, fig] = oiPlot(oiHuman,'psf 550');

psfPlotrange(fig,oiHuman);
AD = airyDisk(thisWave,wvfGet(wvf,'fnumber'),'diameter',true);
title(sprintf("fNumber %.2f Wave %.0f Airy Diam %.2f",oiGet(oi,'optics fnumber'),thisWave,AD));

%% More conversion tests

% If you use 'diffraction limited' model, we force it to 'shift
% invariant'

% These are all OK.
oiDL = wvf2oi(wvf,'model','shift invariant');
oiPlot(oiDL,'psf 550');

oiDL = wvf2oi(wvf,'model','wvf human');
oiPlot(oiDL,'psf 550');

oiDL = wvf2oi(wvf,'model','human mw');
oiPlot(oiDL,'psf 550');

%% oiCompute using the wvf

oi = oiCompute(wvf,scene);

% Show the oi PSF
oiPlot(oi,'psf550');
set(gca,'xlim',[-10 10],'ylim',[-10 10]);

oi = oiSet(oi,'name',sprintf('wvf-%d',nsides));
oi = oiCrop(oi,'border');
oiWindow(oi);
oiSet(oi,'gamma',0.5); drawnow;

%% HDR test scene

scene = sceneCreate('hdr');
scene = sceneSet(scene,'fov',1);

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','wvf');
oiWindow(oi);
oiSet(oi,'gamma',0.5); drawnow;

%% The same scene through Zhenyi's piFlareApply

% Not yet a perfect match.  But getting there.
[oiApply, pMask, psf] = piFlareApply(scene,'num sides aperture',nsides, ...
    'focal length',wvfGet(wvf,'focal length','m'), ...
    'fnumber',wvfGet(wvf,'fnumber'));

oiApply = oiSet(oiApply,'name','piFlare');
oiWindow(oiApply);
oiSet(oiApply,'gamma',0.5);

%%
