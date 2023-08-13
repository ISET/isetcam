%% s_opticsPSF2Zcoeffs.m
%
% PSF 2 Wernike Coefficients
%
% Search for the Wernike polynomial coefficients that produce a target PSF.
%
% Note this good Watson tutorial.  But it has no units, wavelength,
% and such.
%
%  http://jov.arvojournals.org/article.aspx?articleid=2213266
%
% BW, Vistasoft team, 2018

%% Create a wavefront object with some coefficients

% Create a wvf object
wave = 550;
wvf = wvfCreate('wave',wave);
wvf = wvfSet(wvf,'zcoeffs',.2,'defocus');
wvf = wvfSet(wvf,'zcoeffs',0,'vertical_astigmatism');

wvf = wvfCompute(wvf);

wvfPlot(wvf,'image psf','unit','um','plot range',15);

%% Get the parameters we need for the search

thisWaveUM  = wvfGet(wvf,'wave','um');
thisWaveNM  = wvfGet(wvf,'wave','nm');
pupilSizeMM = wvfGet(wvf,'pupil size','mm');
zpupilDiameterMM = wvfGet(wvf,'z pupil diameter');

pupilPlaneSizeMM = wvfGet(wvf,'pupil plane size','unit','mm',thisWaveNM);
nPixels   = wvfGet(wvf,'spatial samples');
wvf       = wvfCompute(wvf);
psfTarget = wvfGet(wvf,'psf');

f = @(x) psf2zcoeff(x,psfTarget,pupilSizeMM,zpupilDiameterMM,pupilPlaneSizeMM,thisWaveUM, nPixels);

% I should to figure out how to set the tolerances.  Default is 1e-4
zcoeffs = wvfGet(wvf,'zcoeffs');

% I am searching over the first 6 coefficients.  This includes defocus.
% Could do more, I suppose.  Also, the first coefficient ('piston') has no
% impact on the PSF.  So the search always forces that to 0.
nCoeffs = 6;
zcoeffs(1:nCoeffs)
x0 = zeros(size(zcoeffs(1:nCoeffs)));
options = optimset('PlotFcns',@optimplotfval);

x = fminsearch(f,x0,options);

% Piston comes back as an arbitrary value because the error function
% ignores it. We force it to zero here.
x(1) = 0;

%% Compare the values

fprintf('Estimated\n');
disp(x)

fprintf('True\n');
disp(zcoeffs(1:nCoeffs))

%% Show the pupil phase functions

vcNewGraphWin([],'tall');
subplot(2,1,1), wvfPlot(wvf,'image pupil phase','unit','mm','wave',wave,'window',false)

wvf2 = wvfSet(wvf,'zcoeffs',x);
wvf2     = wvfComputePSF(wvf2);
subplot(2,1,2), wvfPlot(wvf2,'image pupil phase','unit','mm','wave',wave,'window',false)

%%