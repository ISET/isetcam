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

wvf = wvfCreate;
thisWave = wvfGet(wvf,'wave');

% Set aribtrarily
fLengthMM = 10; fLengthM = fLengthMM*1e-3; fNumber = 3;
pupilMM = fLengthMM/fNumber;
wvf = wvfSet(wvf,'focal length',fLengthM);
wvf  = wvfComputePSF(wvf,'lca', false);

pRange = 10;  % Microns
wvfPlot(wvf,'2d psf space','um',thisWave,pRange,'airy disk',true);
title(sprintf('Calculated pupil diameter %.1f mm',pupilMM));

%% Compare wvf and oi methods directly

wvfData = wvfPlot(wvf,'psf xaxis','um',thisWave,10);

% Convert to OI and plot the same slice.
% except for a small scale factor.  Which I don't understand
oi = wvf2oi(wvf);
uData = oiGet(oi,'optics psf xaxis');
hold on;
plot(uData.samp,uData.data,'gs');
legend({'wvf','Airy','oi'});

%% Get the otf data from the OI and WVF computed two ways

% Compare the two OTF data sets directly.
wvfOTF = wvfGet(wvf,'otf');
oiOTF  = oiGet(oi,'optics otf');

% You must use fftshift, not ifftshift, to convert OI OTF data to
% match the WVF data.
ieNewGraphWin;
oiOTFS = fftshift(oiOTF);
plot(abs(oiOTFS(:)),abs(wvfOTF(:)),'.');
identityLine;
title('OTF: oi converted to wvf')

%% Now, make a multispectral wvf and convert it to ISET OI format

wave = linspace(400,700,4);
pupilMM = 3;   % Could be 6, 4.5, or 3
fLengthM = 17e-3;

% Create the multispectral wvf
wvf  = wvfCreate('wave',wave,'name',sprintf('%dmm-pupil',pupilMM));
wvf  = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf  = wvfSet(wvf,'focal length',fLengthM);  % 17 mm focal length for deg per mm

% Calculate without human LCA
wvf  = wvfComputePSF(wvf,'lca',false,'force',true);

% Convert wvf to OI format
oi = wvf2oi(wvf);

%% Plot the wavelength dependent OTFs

ieNewGraphWin;
tiledlayout(2,2);
for ii=1:numel(wave)
    thisWave = wave(ii);

    oiOTF = oiGet(oi,'optics otf and support',thisWave);
    wvOTF = wvfGet(wvf,'otf and support','mm',thisWave);
    nexttile;
    plot(abs(oiOTF.otf(:)),abs(wvOTF.data(:)),'.');
    title(sprintf('Wave: %d',wave(ii)));
    identityLine; grid on;
end

%%  Show that the diffraction limited OTFs differ by wavelength

ieNewGraphWin([],'wide');
otf = oiPlot(oi,'otf',[],wave(1),'mm','no window');
subplot(1,2,1); mesh(otf.fx,otf.fy,abs(otf.otf));
title(sprintf('Wave: %d',wave(1)));
otf = oiPlot(oi,'otf',[],wave(end),'mm','no window');
subplot(1,2,2); mesh(otf.fx,otf.fy,abs(otf.otf));
title(sprintf('Wave: %d',wave(end)));

%% Compute with the oi and the wvf

% I used this for a while, too.  It was fine.
% radialScene = sceneCreate('radial lines');
% radialScene = sceneSet(radialScene,'hfov',2);

gridScene = sceneCreate('grid lines',384,128);
gridScene = sceneSet(gridScene,'hfov',1);
% sceneWindow(gridScene);

% Create the oi
oi = wvf2oi(wvf);
oi = oiCompute(oi,gridScene);
oi = oiSet(oi,'name',sprintf('oi f/# %.2f',oiGet(oi,'fnumber')));
oiWindow(oi);

% This is the oi computed directly with the wvfP using wvfApply
oiWVF = wvfApply(gridScene,wvf,'lca',false);
oiWindow(oiWVF);

% Compare the photons
photons1 = oiGet(oi,'photons');
photons2 = oiGet(oiWVF,'photons');

ieNewGraphWin;
plot(photons1(:),photons2(:),'.');
identityLine; grid on; xlabel('oiCompute'); ylabel('wvfApply');

%% Setting a defocus on the wvf structure

defocus = 1;  % Diopters
wvfD = wvfSet(wvf,'zcoeff',defocus,'defocus');

wvfD = wvfComputePSF(wvfD,'lca',false);
pRange = 20;
wvfPlot(wvfD,'2d psf space','um',thisWave,pRange);
title(sprintf('Defocus %.1f D',defocus));

%% Convert to an OI and render

oiD = oiCompute(wvfD,gridScene);
oiD = oiSet(oiD,'name',sprintf('oiCompute Defocus %.1f no LCA',defocus));
oiWindow(oiD);

%% Compare with wvfApply
%{
oiWVFD = wvfApply(radialScene,wvfD);
oiWVFD = oiSet(oiWVFD,'name',sprintf('wvfApply Defocus %.1f no LCA',defocus));

oiWindow(oiWVFD);
%}

%% Now recompute and include human longitudinal chromatic aberration

wvfDCA = wvfComputePSF(wvfD,'lca',true,'force',true);
oiDCA = oiCompute(wvfDCA,gridScene);
oiDCA = oiSet(oiDCA,'name','Defocus and LCA');
oiWindow(oiDCA);

%% Add some astigmatism, still include the human LCA

wvfVA = wvfSet(wvf,'zcoeff',0.5,'defocus');
wvfVA = wvfSet(wvfVA,'zcoeff',-0.5,'vertical_astigmatism');

% We need to re-compute.
wvfVA  = wvfComputePSF(wvfVA,'lca', true);

oi = oiCompute(wvfVA,gridScene);
oi = oiSet(oi,'name','vertical astig');
oiWindow(oi);

testWave = [450,550];
for ii = 1:numel(testWave)
    [~, fig] = oiPlot(oi,'psf',[],testWave(ii)); 
end


%% END
