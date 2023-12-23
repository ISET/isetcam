%% t_wvfOverview
%
% We describe the parameters and logic of the wavefront structure.
%
% Topics covered:
%   zcoeffs
%   umPerDegree
%   calc and meas parameters
%   refSizeOfFieldMM
%   sceParams
%   wavefrontaberrations
%   pupilfunc
%   psf
%   customLCA
%   PUPILFUNCTION_STALE
%   PSF_STALE
%
% Relationship between OI fnumber, focal length, sample spacing in the psf
% plane and these parameters
%
% See also
%   wvfCompute, wvfGet, wvfSet, wvf2oi, wvf2optics, wvfPlot
%

%% Test focal length and fnumber wvfSets/Gets

% Default
wvf = wvfCreate;
wvfGet(wvf,'focal length')
wvfGet(wvf,'focal length','m')
wvfGet(wvf,'focal length','mm')
wvfGet(wvf,'focal length','um')

% um per degree changes with focal length
wvfGet(wvf,'um per degree')
wvf = wvfSet(wvf,'focal length',3.9,'mm');
wvfGet(wvf,'um per degree')

% Print the focal length with different units
wvfGet(wvf,'focal length','mm')
wvfGet(wvf,'focal length','m')
wvfGet(wvf,'focal length','mm')

%% Now f-number

% Current f number
a = wvfGet(wvf,'fnumber')

% Matches pupil diameter and focal length
b = wvfGet(wvf,'focal length','mm')/wvfGet(wvf,'calc pupil diameter','mm');
assert( abs(a/b - 1) < 1e-9);

% Changing the f number adjusts only the pupil, not the focal length.  Our
% decision.
wvf = wvfSet(wvf,'fnumber',4);
assert(abs( 4/wvfGet(wvf,'f number') - 1) < 1e-9);

wvfGet(wvf,'focal length','mm')
wvfGet(wvf,'calc pupil diameter','mm')
wvfGet(wvf,'calc pupil diameter','m')

%% The default OI has an f number of 4 and focal length of 3.9 mm

[oi, wvf] = oiCreate('diffraction limited');

oiGet(oi,'optics fnumber')
oiGet(oi,'optics focal length','mm')

wvfGet(wvf,'fnumber')
wvfGet(wvf,'focal length','mm')
