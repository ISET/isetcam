%% PSF 2 Wernike Coefficients
%
% Search for the Wernike polynomial coefficients that produce a target PSF.
% 
% It is possible there is an analytical solution to this.  I was too lazy
% to figure that out.  I will check with someone over coffee.
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

wvf = wvfComputePSF(wvf);
% wvfPlot(wvf,'image pupil phase','mm')
wvfPlot(wvf,'image psf space','um')
% wvfPlot(wvf,'image pupil amp','mm')

%% Get the parameters we need for the search

thisWaveUM  = wvfGet(wvf,'wave','um');
thisWaveNM  = wvfGet(wvf,'wave','nm');
pupilSizeMM = wvfGet(wvf,'pupil size','mm');
zpupilDiameterMM = wvfGet(wvf,'z pupil diameter');

pupilPlaneSizeMM = wvfGet(wvf,'pupil plane size','mm',thisWaveNM);
nPixels   = wvfGet(wvf,'spatial samples');
wvf       = wvfComputePSF(wvf);
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
subplot(2,1,1), wvfPlot(wvf,'image pupil phase','mm',wave,'no window')

wvf2 = wvfSet(wvf,'zcoeffs',x);
wvf2     = wvfComputePSF(wvf2);
subplot(2,1,2), wvfPlot(wvf2,'image pupil phase','mm',wave,'no window')

%%