function wvf = wvfComputePSF(wvf)
% Compute the psf for the wvf object.
%
%   wvf = wvfComputePSF(wvf)
%
% The point spread function is computed for each wavelength in the input
% wvf structure. The PSF computation is based on the Zernike coefficients
% specified to the OSA standard.
%
% The computation is simply the amplitude of the fft of the pupil function
% at each wavelength.  The psf is normalized for unit area under the curve
% (i.e., no loss of light).
%
% The real work for calculating the psf is done in the
% wvfComputePupilFunction routine.
% 
% See also: wvfGet, wvfCreate, wvfSet, wvfComputePupilFunction
%
% Copyright Wavefront Toolbox Team 2012
% Heavily edited for ISET, 2015

%% Programming
% We need to get the spatial sampling right.  At present, we aren't
% sure about the proper relationship between the size of the pupil
% function and the spatial frequency on the sensor surface.  I think
% DHB has been looking at this in ISETBIO land.

%% Initialize parameters.  These are calc wave.
if ieNotDefined('wvf'), error('wvf parameters required'); end

showBar = ieSessionGet('wait bar');

wList = wvfGet(wvf,'wave');
nWave = wvfGet(wvf,'nwave');
pupilfunc = cell(nWave,1);

%% Compute the pupil functions for each wavelength
wvf = wvfComputePupilFunction(wvf, showBar);

%% Compute the psfs 
psf = cell(nWave,1);
for wl = 1:nWave
    % Converting the pupil function to the PSF requires only an fft2 and
    % magnitude calculation 
    pupilfunc{wl} = wvfGet(wvf,'pupil function',wList(wl));
    amp = fft2(pupilfunc{wl});
    inten = (amp .* conj(amp));   %intensity
    psf{wl} = real(fftshift(inten));
    
    % Scale for unit area
    psf{wl} = psf{wl}/sum(sum(psf{wl}));
end

% The spatial support for each psf differs when computed in the pupil
% plane, as we do here.  So to plot these requires specifying the
% wavelength and getting the wavelength-dependent spatial support.  See
% wvfPlot().
wvf.psf = psf;


end


