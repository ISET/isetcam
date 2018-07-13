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

%% Not sure which of these we will need

waveIdx = 1;
maxMM = 2;
maxUM = 20;      
pupilfuncrangeMM = 5;

%% Use Zernike polynomials to specify a diffraction limited PSF.

% This is the diffraction limited case with all the polynomials
% coefficients set to 0.
wvf0 = wvfCreate;
wvf0 = wvfSet(wvf0,'wave',550);
z = wvfGet(wvf0,'zcoeffs');

% This is how we compute the PSF from those zcoeffs
wvf0 = wvfComputePSF(wvf0);
ab = wvfGet(wvf0','wavefront aberrations');
vcNewGraphWin;
imagesc(ab);

% Also called the pupil aperture
pf = wvfGet(wvf0','pupil function');
vcNewGraphWin;
imagesc(pf);

%% I think we are just looping over the zcoeffs

% The fminsearch error function will do this

wvf = wvfComputePSF(wvf);
% Relies mainly on this
% wvf = wvfComputePupilFunction(wvf, showBar);

thisPSF = wvfGet(wvf0,'psf');

% Compute and return the error
% desiredPSF vs. thisPSF

% the wvfComputePSF requires the pupil function.
% From this:  wvfComputePupilFunction
%{
% That is needed only once, not in the loop In fact, we don't really
% need it for this case because the apodization (A) is always 1.
A = ones(nPixel,nPixel);   
%}

% Once we have the pupilfunc at the wavelength, we only need to do
% this
%{
amp = fft2(pupilfunc{wl});
inten = (amp .* conj(amp));   %intensity
psf{wl} = real(fftshift(inten));
    
% Scale for unit area
psf{wl} = psf{wl}/sum(sum(psf{wl}));
%}

%%




% wList = wvfGet(wvf0,'wave');
wList = 550;
wvfPlot(wvf0,'2dpsf space normalized','um',wList,maxUM);
