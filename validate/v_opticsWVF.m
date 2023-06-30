%% Comparing oi methods and wvf methods numerically
%
% Historically, ISET mainly used diffraction limited calculations
% directly as a special case.  
%
% About 10 years ago, we added the ability to build shift invariant
% representations based on wavefront aberrations specified by Zernike
% polynomials. This allows us to create shift invariant
% representations that are diffraction limited (no aberrations) or
% with various simple aberrations (astigmatism, coma, defocus).
%
% The code in ISETBIO was pretty firmly based on the human data,
% including the human longitudinal chromatic aberration and the
% Stiles-Crawford effect. These were always set as the default
% wavefront creation.
%
% With the merge of ISETBio wavefront into ISETCam, we no longer
% impose the specific human features, such as longitudinal chromatic
% aberration, on the wavefront.
%
% This validation script test the agreement between the general
% wavefront calculations and the original ISET diffraction limited
% calculation.  The dlMTF code has been tested, and we show that the
% wavefront version matches the results.
%
% At the end, we show how to adjust the Zernike polynomial
% coefficients to produce different defocus and other wavefront
% aberrations.
%

%%
ieInit;

%% Compare wvf and standard OI versions of diffraction limited

% First, calculate using the wvf code base.

% Create the wvf parameter structure 
thisWave = 550;
pupilMM = 3;   % Could be 6, 4.5, or 3
fLengthM = 17e-3;

wvfP  = wvfCreate('wave',thisWave,'name',sprintf('%d-pupil',pupilMM));
wvfP  = wvfSet(wvfP,'calc pupil diameter',pupilMM);
wvfP  = wvfSet(wvfP,'focal length',fLengthM);  % 17 mm focal length for deg per mm

wvfP  = wvfComputePSF(wvfP,'lca', false);

pRange = 10;  % Microns
wvfData = wvfPlot(wvfP,'2d psf space','um',thisWave,pRange,'airy disk',true);
title(sprintf('Calculated pupil diameter %.1f mm',pupilMM));

%% Now, create the same model using the diffraction limited ISET code

oi = oiCreate('diffraction limited');
oi = oiSet(oi,'optics focal length',fLengthM);
oi = oiSet(oi,'optics fnumber', fLengthM*1e+3/pupilMM);

% Check values
% oiGet(oi,'optics focal length','mm')
% oiGet(oi,'optics aperture diameter','mm')
uData = oiPlot(oi,'psf',[],thisWave);

%% Compare wvf and oi methods directly
%
% The spatial sampling of the two methods is NOT matched.  But they
% both have spatial sampling with real spatial units.  So we can
% interpolate OI data to match the wvf data.  
%
% They are both created to sum to one over their respectively sampling
% grids.   Thus a constant function on that sampling grid will be
% unchanged.
%
% But the two sampling grids are different!  So to compare we need to
% put them on the same sampling grid.  We interpolate to the sampling
% grid of from the higher resolution to lower, and then normalize to
% sum to 1 on that sampling grid.

[X,Y] = meshgrid(wvfData.x,wvfData.y);
% ieNewGraphWin; mesh(X,Y,wvfData.z);
% ieNewGraphWin; mesh(uData.x,uData.y,uData.psf);

% Interpolate from higher resolution (PSF) to lower (WVF)
estPSF = interp2(uData.x,uData.y,uData.psf,X,Y,'linear',0);
estPSF = estPSF/sum(estPSF(:));

ieNewGraphWin([],'wide');
subplot(1,3,1)
mesh(X,Y,wvfData.z); hold on;
plot3(X,Y,estPSF,'k.'); grid on;

subplot(1,3,2)
plot(estPSF(:),wvfData.z(:),'o');
identityLine; xlabel('wvf interp'); ylabel('oi data'); grid on;

subplot(1,3,3)
histogram((estPSF(:) - wvfData.z(:)),20);

%% Get the otf data from the OI and WVF computed two ways

% Compare the two OTF data sets directly.
oiData = oiPlot(oi,'otf',[],thisWave);
maxF = 2000;
wvData = wvfPlot(wvfP,'otf','mm',thisWave,maxF);

% Remember that the DC position must account for whether the
% length of fx is even or odd
ieNewGraphWin;
if isodd(length(wvData.fx)), wvMid = floor(length(wvData.fx)/2) + 1;
else,                 wvMid = length(wvData.fx)/2 + 1;
end
plot(wvData.fx, wvData.otf(:,wvMid),'r-'); hold on;

if isodd(length(oiData.fx)), oiMid = floor(length(oiData.fx)/2) + 1;
else,          oiMid = length(oiData.fx)/2 + 1;
end
plot(oiData.fx, oiData.otf(:,oiMid),'bo')
legend({'wvf','oi'})
grid on
xlabel('Frequency'); ylabel('Amplitude');

%% Now, make a multispectral wvf (wvfP) and convert it to ISET OI format

% Create the wvf parameter structure with the appropriate values
wave = (400:50:700);
pupilMM = 3;   % Could be 6, 4.5, or 3
fLengthM = 17e-3;

wvfP  = wvfCreate('wave',wave,'name',sprintf('%dmm-pupil',pupilMM));
wvfP  = wvfSet(wvfP,'calc pupil diameter',pupilMM);
wvfP  = wvfSet(wvfP,'focal length',fLengthM);  % 17 mm focal length for deg per mm

wvfP  = wvfComputePSF(wvfP,'lca',false);

% Convert it to OI format
oi = wvf2oi(wvfP);

%% Compare the OTFs
thisWave = 550;
oiData = oiPlot(oi,'otf',[],thisWave);
wvData = wvfPlot(wvfP,'2D otf','mm',thisWave);

ieNewGraphWin;
if isodd(length(wvData.fx)), wvMid = floor(length(wvData.fx)/2) + 1;
else,                 wvMid = length(wvData.fx)/2 + 1;
end
plot(wvData.fx, wvData.otf(:,wvMid),'r-'); hold on;

if isodd(length(oiData.fx)), oiMid = floor(length(oiData.fx)/2) + 1;
else,          oiMid = length(oiData.fx)/2 + 1;
end
plot(oiData.fx, oiData.otf(:,oiMid),'bo')
legend({'wvf','oi'})

%% If the OTF data are basically matched

% We should be able to take the wvf otf data and interpolate them onto
% the oi otf frequency values.

% There are very small differences (~0.005) at a few interpolated values
est = interp2(wvData.fx,wvData.fy,wvData.otf,oiData.fx,oiData.fy,'cubic',0);

ieNewGraphWin([],'wide');
subplot(1,2,1)
plot(est(:),oiData.otf(:),'rx')
axis equal; xlabel('Estimated from wvf'); ylabel('Original OI')
identityLine

% Some issue because of complex numbers.
% Nearly perfect.  Even though the PSFs are not perfect.  Should try
% to understand why.
%
subplot(1,2,2)
histogram(abs(est(:)) - abs(oiData.otf(:)),100)

%% Compute with the oi and a scene, and then try wvfApply

radialScene = sceneCreate('radial lines');
radialScene = sceneSet(radialScene,'hfov',2);
% sceneWindow(radialScene);

% Create the oi
oi = wvf2oi(wvfP);
oi = oiCompute(oi,radialScene);
oi = oiSet(oi,'name',sprintf('oi f/# %.2f',oiGet(oi,'fnumber')));
oiWindow(oi);

% This is the oi computed directly with the wvfP using wvfApply
oiWVF = wvfApply(radialScene,wvfP,'lca',false);
oiWindow(oiWVF);

% Compare the photons
photons1 = oiGet(oi,'photons');
photons2 = oiGet(oiWVF,'photons');

ieNewGraphWin;
plot(photons1(:),photons2(:),'.');
identityLine; grid on; xlabel('oiCompute'); ylabel('wvfApply');

%% Finally, show off with setting a defocus on the wvf structure

defocus = 1;  % Diopters
wvfD = wvfSet(wvfP,'zcoeff',defocus,'defocus');

wvfD = wvfComputePSF(wvfD,'lca',false);
pRange = 20;
wvfPlot(wvfD,'2d psf space','um',thisWave,pRange);
title(sprintf('Defocus %.1f D',defocus));

%% Convert to an OI and render

oiD = wvf2oi(wvfD);
oiD = oiCompute(oiD,radialScene);
oiD = oiSet(oiD,'name',sprintf('oiCompute Defocus %.1f no LCA',defocus));
oiWindow(oiD);

%% Compare with wvfApply

oiWVFD = wvfApply(radialScene,wvfD);
oiWVFD = oiSet(oiWVFD,'name',sprintf('wvfApply Defocus %.1f no LCA',defocus));

oiWindow(oiWVFD);

%% Now include human longitudinal chromatic aberration

wvfDCA = wvfComputePSF(wvfD,'lca',true,'force',true);
oiDCA = oiCompute(wvf2oi(wvfDCA),radialScene);
oiDCA = oiSet(oiDCA,'name','Defocus and LCA');
oiWindow(oiDCA);

%% END
