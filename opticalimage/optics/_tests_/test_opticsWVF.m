function tests = test_opticsWVF()
    tests = functiontests(localfunctions);
end

function testMain(testCase)
%% Comparing oi methods and wvf methods numerically
%
% See also
%

%%
ieInit;

%% Compare wvf and standard OI versions of diffraction limited
%
% First, calculate using the wvf code base.
wvf = wvfCreate;
% wvfWave = wvfGet(wvf,'wave');

% Set aribtrarily
fLengthMM = 10; 
fNumber = 3;
pupilMM = fLengthMM/fNumber;
wvf = wvfSet(wvf,'focal length',fLengthMM);
wvf = wvfSet(wvf,'lcaMethod','none');
wvf  = wvfCompute(wvf);

pRange = 10;  % Microns
wvfPlot(wvf,'psf','unit','um','plot range',pRange,'airy disk',true);
title(sprintf('Calculated pupil diameter %.1f mm',pupilMM));

%% Compare wvf and oi methods directly

wvfData = wvfPlot(wvf,'psf xaxis','unit','um','plot range',10);

oi = wvf2oi(wvf);
uData = oiGet(oi,'optics psf xaxis');
hold on;
plot(uData.samp,uData.data,'gs');
legend({'wvf','Airy','oi'});

% Check the summation
assert(abs(sum(uData.data(:)) - 0.157166317909746) < 1e-3);

%% Get the otf data from the OI and WVF computed two ways
%
% Compare the two OTF data sets directly.
wvfOTF = wvfGet(wvf,'otf');
oiOTF  = oiGet(oi,'optics otf');
assert(max(abs(oiOTF(:))-abs(wvfOTF(:))) < 1e-6); 

% Checksum good to within 1 part in a thousand This changed slightly
% (1.0831 to 1.085) with the Merge of ISETCam/ISETBio. Keeping an eye
% on how this varies.
assert(abs(real(sum(oiOTF(:))) / 1.085e+03 - 1) < 1e-3)

%% Now, make a multispectral wvf and convert it to ISET OI format
wave = 400:50:700;
pupilMM = 3;   % Could be 6, 4.5, or 3
fLengthMM = 17;

% Create the multispectral wvf
wvf  = wvfCreate('wave',wave,'name',sprintf('%dmm-pupil',pupilMM));
wvf  = wvfSet(wvf,'calc pupil diameter',pupilMM);
wvf  = wvfSet(wvf,'focal length',fLengthMM);  % 17 mm focal length for deg per mm
wvfWave = wvfGet(wvf,'wave');

% Calculate without human LCA
wvf = wvfSet(wvf,'lcaMethod','none');
wvf  = wvfCompute(wvf);

% Convert wvf to OI format
oi = wvf2oi(wvf);

%%  Show that the diffraction limited OTFs differ by wavelength
ieNewGraphWin([],'wide');
otf = oiPlot(oi,'otf',[],wave(1),'mm','no window');
subplot(1,2,1); mesh(otf.fx,otf.fy,abs(otf.otf));
title(sprintf('Wave: %d',wave(1)));
otf = oiPlot(oi,'otf',[],wave(end),'mm','no window');
subplot(1,2,2); mesh(otf.fx,otf.fy,abs(otf.otf));
title(sprintf('Wave: %d',wave(end)));
drawnow;

%% Compute with the oi and the wvf
gridScene = sceneCreate('grid lines',384,128);
gridScene = sceneSet(gridScene,'wave',wvfWave);
gridScene = sceneSet(gridScene,'hfov',1);
% sceneWindow(gridScene);

% Create the oi
oi = oiCompute(oi,gridScene);
oi = oiSet(oi,'name',sprintf('oi f/# %.2f',oiGet(oi,'fnumber')));
oiWindow(oi);

%% This is the oi computed directly with the wvfP using wvfApply
oiWVF = oiCompute(wvf,gridScene);
oiWindow(oiWVF);

% Compare the photons
photons1 = oiGet(oi,'photons');
photons2 = oiGet(oiWVF,'photons');

assert(abs(mean(photons1,'all') - mean(photons2,'all')) < 1e-6);

%% Setting a defocus on the wvf structure
defocus = 1;  % Diopters
wvfD = wvfSet(wvf,'zcoeff',defocus,'defocus');
wvfD = wvfSet(wvfD,'lcaMethod','none');
wvfD = wvfCompute(wvfD);
pRange = 20;
plotWave = 700;
wvfPlot(wvfD,'psf','unit','um','wave',plotWave,'plot range',pRange);
title(sprintf('Defocus %.1f D',defocus));
psf500 = wvfGet(wvfD,'psf',500);
assert(abs(max(psf500(:)) - 0.0017609) < 1e-6);

%% Convert to an OI and render
oiD = oiCompute(wvfD,gridScene);
oiD = oiSet(oiD,'name',sprintf('oiCompute Defocus %.1f no LCA',defocus));
oiWindow(oiD);
photons550 = oiGet(oiD,'photons',550);

testValue = 1.3628e+19;  % Set on May 8, 2024.
assert(abs((sum(photons550(:))/testValue) - 1) < 1e-3);

%% Now recompute and include human longitudinal chromatic aberration
wvfDCA = wvfSet(wvfD,'lcaMethod','human');
wvfDCA = wvfCompute(wvfDCA);
oiDCA = oiCompute(wvfDCA,gridScene);
oiDCA = oiSet(oiDCA,'name','Defocus and LCA');
oiWindow(oiDCA);

%% Add some astigmatism, still include the human LCA
wvfVA = wvfSet(wvf,'zcoeff',0.5,'defocus');
wvfVA = wvfSet(wvfVA,'zcoeff',-0.5,'vertical_astigmatism');

% We need to re-compute.
wvfVA = wvfSet(wvfVA,'lcaMethod','human');
wvfVA  = wvfCompute(wvfVA);
oi = oiCompute(wvfVA,gridScene);
photons550 = oiGet(oi,'photons',550);
assert(abs((sum(photons550(:))/testValue) - 1) < 1e-3);

oi = oiSet(oi,'name','vertical astig');
oiWindow(oi);

testWave = [450,550];
for ii = 1:numel(testWave)
    uData = oiPlot(oi,'psf',[],testWave(ii));
    set(gca,'xlim',[-20 20],'ylim',[-20 20]);
end

% Check the 550 nm PSF max ...
assert(abs(max(uData.psf(:)) - 0.0145) < 1e-3)
assert(abs(max(uData.x(:)) - 188.1156) < 1e-3)

%% Make sure figures draw
drawnow;

%% END

end
