%% Comparing oi methods and wvf methods numerically
%
% Historically, ISET mainly used diffraction limited calculations
% directly as a special case.  
%
% About 15 years ago, we added the ability to build general shift invariant
% representations based on wavefront aberrations specified by Zernike
% polynomials. These shift invariant representations can be diffraction
% limited (no aberrations) or with various simple aberrations (astigmatism,
% coma, defocus).
%
% The code in ISETBio was firmly based on the human data, including the
% human longitudinal chromatic aberration and the Stiles-Crawford effect.
% These were always set as the default wavefront creation.
%
% With the merge of ISETBio wavefront into ISETCam, we no longer
% impose the specific human features, such as longitudinal chromatic
% aberration, on the wavefront.  These are now optional.
%
% This validation script test the general wavefront calculations and the
% original ISETCam diffraction limited calculation (dlMTF).  The dlMTF code
% has been tested, and we show that the wavefront version matches the
% results.
%
% At the end of this script, we adjust the Zernike polynomial coefficients
% to produce different defocus and other wavefront aberrations.
%
% See also
%   

%%
ieInit;

%% Compare wvf and standard OI versions of diffraction limited

% First, calculate using the wvf code base.

wvfP = wvfCreate;    % Default wavefront 5.67 fnumber

% Adjust for testing general case.  At the moment, it only works well with
% the human parameters.
fLengthMM = 17; fLengthM = fLengthMM*1e-3;
fNumber = 5.6; thisWave = 550;
pupilMM = fLengthMM/fNumber;
wvfP = wvfSet(wvfP,'calc pupil diameter',pupilMM);
wvfP = wvfSet(wvfP,'focal length',fLengthM);
wvfP  = wvfComputePSF(wvfP,'lca', false);

pRange = 10;  % Microns
wvfData = wvfPlot(wvfP,'2d psf space','um',thisWave,pRange,'airy disk',true);
title(sprintf('Calculated pupil diameter %.1f mm',pupilMM));

%% Now, create the same model using the diffraction limited ISET code

% Compare wvf and oi methods directly
wvfData = wvfPlot(wvfP,'psf xaxis','um',thisWave,10);
hold on;

% Convert to OI and plot the same slice.  With the dx/2 shift, they agree
% except for a small scale factor.  Which I don't understand
oi = wvf2oi(wvfP);
uData = oiGet(oi,'optics psf xaxis');
plot(uData.samp,uData.data,'go');
legend({'wvf','oi'});

%% Get the otf data from the OI and WVF computed two ways

% Compare the two OTF data sets directly.
oi = wvf2oi(wvfP);
oiData = oiPlot(oi,'otf',[],thisWave);
wvData = wvfPlot(wvfP,'otf','mm',thisWave);

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
grid on; xlabel('Frequency'); ylabel('Amplitude');

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

%% Now add some astigmatism, leave the LCA on

wvfVA = wvfSet(wvfP,'zcoeff',0.3,'defocus');
wvfVA = wvfSet(wvfVA,'zcoeff',-1,'vertical_astigmatism');

% We need to compute.
wvfVA  = wvfComputePSF(wvfVA,'lca', true);

oi = wvf2oi(wvfVA,'model','human mw');  % This works
oi = wvf2oi(wvfVA,'model','wvf human');  % This works

% oi = wvf2oi(wvfVA,'model','diffraction limited');  % This does not work

oi = oiCompute(oi,radialScene);
oiWindow(oi);

[~, fig] = oiPlot(oi,'psf',thisWave);
psfPlotrange(fig,oi);

%% END
