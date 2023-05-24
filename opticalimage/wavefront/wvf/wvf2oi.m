function oi = wvf2oi(wvf)
% Convert wavefront data to ISETBIO optical image with optics
%
% Syntax:
%   oi = wvf2oi(wvf)
%
% Description:
%    Use Zernicke polynomial data in the wvfP structure and create an
%    ISETBIO optical image whose optics match the wavefront data structure.
%
%    Before calling this function, compute the PSF of the wvf structure.
%
%    Non-optics aspects of the oi structure take on default values.
%
% Inputs:
%    wvf - A wavefront parameters structure (with a computed PSF)
%
% Outputs:
%    oi  - ISETBIO optical image
%
% Optional key/value pairs:
%    None.
%
% Notes:
%  * [NOTE: DHB - There is an interpolation in the loop that computes the
%     otf wavelength by wavelength.  This appears to be there to handle the
%     possibility that the frequency support in the wvf structure could be
%     different for different wavelengths. Does that ever happen?  If we
%     check and it doesn't, I think we could save a little time by getting
%     rid of the interpolation.]
%  * [NOTE: DHB - NCP and I spent a lot of time last summer suffering
%     through the psf <-> otf calculations as part of the IBIOColorDetect
%     project, and the fftshift conventions.]
%  * [NOTE: DHB - There is a note that PSF might start real but that the
%     PSF implied by the OTF computed here might not be.  We should check
%     into that.  We don't want imaginary PSFs showing up in calculations.
%     Perhaps this is handled by the oi methods, in that perhaps they
%     enforce that the psf obtained from the otf is in fact real.]
%  * [NOTE: DHB - It might be worth checking that it is OK just to set the
%     wavelength on the OTF, even if the oi itself has different wavelength
%     sampling.]
%
% See Also:
%    oiCreate, oiPlot
%

% History:
%	 xx/xx/12       Copyright Wavefront Toolbox Team 2012
%    11/13/17  jnm  Comments & formatting
%    01/01/18  dhb  Set name and oi wavelength from wvf.
%              dhb  Check for need to interpolate, skip if not.
%    01/11/18  jnm  Formatting update to match Wiki
%    04/14/21  dhb  Set fNumber to correspond to wvf calc pupil size.
%                   Previously this was the oi default of 3 mm pupil.

% Examples:
%{
    wvf = wvfCreate;
    wvf = wvfComputePSF(wvf);
    oi = wvf2oi(wvf);
    oiPlot(oi, 'psf550');
%}
%{
    wvf = wvfCreate('wave', [400 550 700]');
    wvf = wvfSet(wvf, 'zcoeff', 1, 'defocus');
	wvf = wvfComputePSF(wvf);
    oi = wvf2oi(wvf);
    oiPlot(oi, 'psf550');
%}

%% Set up parameters
if notDefined('wvf'), error('Wavefront structure required.'); end
wave = wvfGet(wvf, 'calc wave');

%% First we figure out the frequency support.
fMax = 0;
for ww = 1:length(wave)
    f = wvfGet(wvf, 'otf support', 'mm', wave(ww));
    if max(f(:)) > fMax
       fMax = max(f(:));
       maxWave = wave(ww);
    end
end

% Make the frequency support in ISET as the same number of samples with the
% wavelength with the highest frequency support from WVF.
%
% This support is set up with sf 0 at the center of the returned vector,
% which matches how the wvf object returns the otf.
%
% This section is here in case the frequency support for the wvf otf varies
% with wavelength.  Not sure that it ever does. There is a conditional that
% skips the inerpolation if the frequency support at a wavelength matches
% that with the maximum, so this doesn't cost us much time.
fx = wvfGet(wvf, 'otf support', 'mm', maxWave);
fy = fx;
[X, Y] = meshgrid(fx, fy);
c0 = find(X(1, :) == 0);
tmpN = length(fx);
if (floor(tmpN / 2) + 1 ~= c0)
    error('We do not understand where sf 0 should be in the sf array');
end

%% Set up the OTF variable for use in the ISETBIO representation
nWave = length(wave);
nSamps = length(fx);
otf = zeros(nSamps, nSamps, nWave);

%% Interpolate the WVF OTF data into the ISET OTF data for each wavelength.
%
% The interpolation seems to be here in case there is different frequency
% support in the wvf structure at different wavelengths.
for ww=1:length(wave)
    f = wvfGet(wvf, 'otf support', 'mm', wave(ww));
    if (f(floor(length(f) / 2) + 1) ~= 0)
        error(['wvf otf support does not have 0 sf in the '
            'expected location']);
    end
    
    % Apply fftshift to convert otf to DC in center, so that interp will
    % work right.
    thisOTF = fftshift(wvfGet(wvf, 'otf', wave(ww)));
    if (all(f == fx))
        est = thisOTF;
    else
        est = interp2(f, f', thisOTF, X, Y, 'cubic', 0);
    end
    
    % Isetbio wants the otf with (0, 0) sf at the upper left.  We
    % accomplish this by applying ifftshift to the wvf centered format.
    otf(:, :, ww) = ifftshift(est);
end

%% Place the frequency support and OTF data into an ISET structure.
%
% Build template with standard defaults
oi = oiCreate;
oi = oiSet(oi, 'name', wvfGet(wvf, 'name'));

% Copy the OTF parameters.
oi = oiSet(oi, 'optics OTF fx', fx);
oi = oiSet(oi, 'optics OTF fy', fy);
oi = oiSet(oi, 'optics otfdata', otf);
oi = oiSet(oi, 'optics OTF wave', wave);
oi = oiSet(oi, 'wave', wave);

% Set the pupil size
% Set the fNumber to correspond to the pupil size
focalLengthMM = oiGet(oi,'focal length')*1000;
oi = oiSet(oi, 'optics fnumber', focalLengthMM/wvfGet(wvf,'calc pupil size'));

end
