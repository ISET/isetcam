%% PSF 2 Wernike Coefficients
%
% Given a PSF, we search for the Wernike polynomial coefficients that
% produce the PSF.  We are exploring different search methods.  And we
% are going to see if we can't find an analytical solution.
%
%
% Note this good Watson tutorial.  But it has no units, wavelength,
% and such.
%
%  http://jov.arvojournals.org/article.aspx?articleid=2213266
%
%

%% Use Zernike polynomials to specify a diffraction limited PSF.

% This is the diffraction limited case with all the polynomials
% coefficients set to 0.
wvf0 = wvfCreate('wave',550);

% This is how we compute the PSF from those zcoeffs
wvf0 = wvfComputePSF(wvf0);
wvfPlot(wvf0,'image psf space','um')

% Also called the pupil aperture
pf = wvfGet(wvf0,'pupil function');
wvfPlot(wvf0,'2d pupil phase space','mm')

%%  Testing the search

% Create a wvf object
wvf = wvfCreate('wave',500);
wvf = wvfSet(wvf,'zcoeffs',0.93,'defocus');
wvf = wvfSet(wvf,'zcoeffs',0.4,'vertical_astigmatism');

wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'image pupil phase','mm')
% wvfPlot(wvf,'image pupil amp','mm')

%% Pull out the parameters we need for the search
thisWaveUM  = wvfGet(wvf,'wave','um');
thisWaveNM  = wvfGet(wvf,'wave','nm');
pupilSizeMM = wvfGet(wvf,'pupil size','mm');
pupilPlaneSizeMM = wvfGet(wvf,'pupil plane size','mm',thisWaveNM);
nPixels = wvfGet(wvf,'spatial samples');
wvf     = wvfComputePSF(wvf);
psfTarget = wvfGet(wvf,'psf');
% wvfPlot(wvf,'image psf space','um')

f = @(x) psf2zcoeff(x,psfTarget,pupilSizeMM,pupilPlaneSizeMM,thisWaveUM, nPixels);

% This is the right answer.
% We initialize just away from the right answer/
% We need to figure out how to set the tolerances
zcoeffs = wvfGet(wvf,'zcoeffs');
nCoeffs = 6;
zcoeffs(1:nCoeffs)
x0 = zeros(size(zcoeffs(1:nCoeffs)));
options = optimset('PlotFcns',@optimplotfval);

x = fminsearch(f,x0,options);
% Piston is always set to 0 in the search. It comes back arbitrary.
% We force it to zero here.
x(1) = 0;  

%%
disp(x)
disp(zcoeffs(1:nCoeffs))
%% Show that the pupil phase functions match

wvfPlot(wvf,'image pupil phase','mm')

wvf2 = wvfSet(wvf,'zcoeffs',x);
wvf2     = wvfComputePSF(wvf2);
wvfPlot(wvf2,'image pupil phase','mm')

%%