%% Testing wvf optical image methods numerically
%
% Historically, ISET used diffraction limited calculations directly as a
% special case.
%
% About 2020 years ago, we added the ability to build general shift
% invariant representations based on wavefront aberrations specified by
% Zernike polynomials. These shift invariant representations can be
% diffraction limited (no aberrations) or with various simple aberrations
% (astigmatism, coma, defocus).
%
% The code in ISETBio was firmly based on human data, including the human
% longitudinal chromatic aberration and the Stiles-Crawford effect. These
% were also designed to use wavefront calculations from adaptive optics,
% with a first draft provided by Heidi Hofer.
%
% With the merge of ISETBio wavefront into ISETCam, we are doing wavefront
% calculations without requiring the specific human features, such as human
% longitudinal chromatic aberration or Stiles Crawford, on the wavefront.
% These are now optional.
%
% This script tests the basic wavefront calculations including the
% diffraction limited calculation for a perfect wavefront, and calculations
% with some defocus and human lca.
%
% Other scripts, particularly related to flare, test the ability to
% generate aperture functions.
%
% See also
%   wvfCompute, wvfComputePupilFunction, wvfCreate, wvf2oi

%%
ieInit;

%% Compare wvf and standard OI versions of diffraction limited

% First, calculate using the wvf code base.
wvf = wvfCreate;    % Default wavefront 5.67 fnumber

fLengthMM = 17; fLengthM = fLengthMM*1e-3;
fNumber = 5.67; thisWave = 550;
pupilMM = fLengthMM/fNumber;

wvf = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf = wvfSet(wvf,'measured pupil diameter',10);
wvf = wvfSet(wvf,'focal length',fLengthM);

% No human lca or sce.  Constant aperture function.
wvf = wvfCompute(wvf);

%{
wvf = wvfComputePupilFunction(wvf);
wvf = wvfComputePSF(wvf);
%}

pRange = 10;  % Microns
wvfPlot(wvf,'psf','um',thisWave,pRange,'airy disk',true);
title(sprintf('Calculated pupil diameter %.1f mm',pupilMM));

%% Now, create the same model using the diffraction limited ISET code

% Compare wvf and oi methods directly
wvfData = wvfPlot(wvf,'psf xaxis','um',thisWave,10);
hold on;

% Convert to OI and plot the same slice.  With the dx/2 shift, they agree
% except for a small scale factor.  Which I don't understand
oi = wvf2oi(wvf);
uData = oiGet(oi,'optics psf xaxis');
plot(uData.samp,uData.data,'go');
legend({'wvf','oi'});
xlabel('Pos (um)'); ylabel('Amp (a.u.)')

%% Get the otf data from the OI and WVF computed two ways

% Compare the two OTF data sets directly.
oiData = oiPlot(oi,'otf',[],thisWave);
wvData = wvfPlot(wvf,'otf','mm',thisWave);

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
plot(oiData.fx, abs(oiData.otf(:,oiMid)),'bo')
legend({'wvf','oi'})
grid on; xlabel('Frequency'); ylabel('Amplitude');

%% Now, make a multispectral wvf (wvfP) and convert it to ISET OI format

wave = (400:10:700);
pupilMM = 3;   % Could be 6, 4.5, or 3
fLengthM = 17e-3;

wvf  = wvfCreate('wave',wave,'name',sprintf('%dmm-pupil',pupilMM));
wvf  = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf  = wvfSet(wvf,'focal length',fLengthM);  % 17 mm focal length for deg per mm

wvf = wvfCompute(wvf);

%{
wvf = wvfComputePupilFunction(wvf);
wvf = wvfComputePSF(wvf,'lca', false);
%}

% Convert it to OI format
oi = wvf2oi(wvf);

thisWave = 550;
oiData = oiPlot(oi,'otf',[],thisWave);
wvData = wvfPlot(wvf,'2D otf','mm',thisWave);

ieNewGraphWin;
if isodd(length(wvData.fx)), wvMid = floor(length(wvData.fx)/2) + 1;
else,                 wvMid = length(wvData.fx)/2 + 1;
end
plot(wvData.fx, wvData.otf(:,wvMid),'r-'); hold on;

if isodd(length(oiData.fx)), oiMid = floor(length(oiData.fx)/2) + 1;
else,          oiMid = length(oiData.fx)/2 + 1;
end
plot(oiData.fx, abs(oiData.otf(:,oiMid)),'bo');
legend({'wvf','oi'})

%% If the OTF data are basically matched

% We should be able to take the wvf otf data and interpolate them onto
% the oi otf frequency values.

% There are very small differences (~0.005) at a few interpolated values
est = interp2(wvData.fx,wvData.fy,wvData.otf,oiData.fx,oiData.fy,'cubic',0);

ieNewGraphWin;
tiledlayout(1,2);
nexttile
plot(abs(est(:)),abs(oiData.otf(:)),'rx')
axis equal; xlabel('Estimated from wvf'); ylabel('Original OI')
identityLine;

nexttile;
histogram(abs(est(:)) - abs(oiData.otf(:)),100)

%% Compute with the oi and a scene, and then try wvfApply

radialScene = sceneCreate('radial lines');
radialScene = sceneSet(radialScene,'hfov',2);
% sceneWindow(radialScene);

% Create the oi 
oi    = oiCompute(oi, radialScene);
oiWVF = oiCompute(wvf,radialScene);
oiWVF = oiSet(oiWVF,'name',sprintf('oi f/# %.2f',oiGet(oi,'fnumber')));
oiWindow(oiWVF);

%{
% This is the oi computed directly using wvfApply. 
% I plan to deprecate.
oiWVF = wvfApply(radialScene,wvf,'lca',false);
oiWindow(oiWVF);
%}

%% Compare the photons
photons1 = oiGet(oi,'photons');
photons2 = oiGet(oiWVF,'photons');

ieNewGraphWin;
plot(photons1(:),photons2(:),'.');
identityLine; grid on; xlabel('oiCompute'); ylabel('wvfApply');

%% Set a defocus on the wvf structure

defocus = 1;  % Diopters
wvfD = wvfSet(wvf,'zcoeff',defocus,'defocus');

% Try to make this work
%
wvfD = wvfCompute(wvfD);
%{
wvfD = wvfComputePupilFunction(wvfD);
wvfD = wvfComputePSF(wvfD,'lca',false);
%}
pRange = 20;
wvfPlot(wvfD,'psf mesh','um',thisWave,pRange);
title(sprintf('Defocus %.1f D',defocus));

%% Convert to an OI and render

oiD = oiCompute(wvfD,radialScene);
oiD = oiSet(oiD,'name',sprintf('oiCompute Defocus %.1f no LCA',defocus));
oiWindow(oiD);

%% Compare with wvfApply
%{
% Worked fine last BW checked.
oiWVFD = wvfApply(radialScene,wvfD);
oiWVFD = oiSet(oiWVFD,'name',sprintf('wvfApply Defocus %.1f no LCA',defocus));
oiWindow(oiWVFD);
%}

%% Include human longitudinal chromatic aberration

wvfDCA = wvfCompute(wvfD,'human lca',true);
pRange = 50;
wvfPlot(wvfDCA,'psf mesh','um',450,pRange);
title('Wave 450');
pRange = 50;
wvfPlot(wvfDCA,'psf mesh','um',550,pRange);
title('Wave 550');

%{
wvfDCA = wvfComputePupilFunction(wvfD,'human lca',true);
wvfDCA = wvfComputePSF(wvfDCA);
%}

%{
wvfDCA = wvfComputePSF(wvfD,'lca',true,'compute pupil func',true);
%}

oiDCA = oiCompute(wvfDCA,radialScene);
oiDCA = oiSet(oiDCA,'name','Defocus and LCA');
oiWindow(oiDCA);

%% Add some astigmatism, leave the LCA on

wvfVA = wvfSet(wvf,'zcoeff',0.3,'defocus');
wvfVA = wvfSet(wvfVA,'zcoeff',-0.5,'vertical_astigmatism');

wvfVA = wvfCompute(wvfVA,'human lca',true);
oi = oiCompute(wvfVA,radialScene);
oiWindow(oi);

thisWave = 450;
[~, fig] = oiPlot(oi,'psf',[],thisWave); psfPlotrange(fig,oi,thisWave);

thisWave = 550;
[~, fig] = oiPlot(oi,'psf',[],thisWave); psfPlotrange(fig,oi,thisWave);


%% END
