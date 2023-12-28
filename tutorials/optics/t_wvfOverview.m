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

% We never change the f number.  We only adjust only the pupil or the focal
% length. To set the fnumber to 4, we have to decide what to change, the
% pupil or the focal length.
%
% To make the fNumber, say 4, we would do this:

fLength = wvfGet(wvf,'focal length','mm');
wvf = wvfSet(wvf,'calc pupil diameter',fLength/4,'mm');
wvfGet(wvf,'fnumber')

wvfGet(wvf,'focal length','mm')
wvfGet(wvf,'calc pupil diameter','mm')
wvfGet(wvf,'calc pupil diameter','m')

%% The default OI has an f number of 4 and focal length of 3.9 mm

[oi, wvf] = oiCreate('diffraction limited');

oiGet(oi,'optics fnumber')
oiGet(oi,'optics focal length','mm')

wvfGet(wvf,'fnumber')
wvfGet(wvf,'focal length','mm')

%% Test from DHB

pupilDiamMm = 3;
theOI = oiCreate('wvf human', pupilDiamMm);

assert(abs(pupilDiamMm - oiGet(theOI,'optics pupil diameter','mm')) < 1e-5)

% This is the distance we should set the focal length to be in perfect
% focus for the scene.  Not exactly the focal length.
% focalLength = oiGet(theOI, 'distance');

focalLength = oiGet(theOI,'optics focal length','mm');

desiredFNumber = focalLength / pupilDiamMm ;
assert(abs(desiredFNumber - oiGet(theOI,'optics fnumber')) < 1e-5)

% This set is the test.  Did we change things correctly?
theOI  = oiSet(theOI , 'optics fnumber', desiredFNumber);

focalLengthTest = oiGet(theOI,'optics focal length','mm');
pupilTest = oiGet(theOI,'optics pupil diameter','mm');

assert( abs(focalLengthTest - focalLength) < 1e-6);
assert( abs(pupilTest - pupilDiamMm) < 1e-6);

% Maybe we should try changing the focalLength, reset the fnumber, and then
% test again

theOI  = oiSet(theOI , 'optics focal length', 0.004);   % Meters
theOI  = oiSet(theOI , 'optics fnumber', desiredFNumber);
pupilTest = oiGet(theOI,'optics pupil diameter','mm');
focalLengthTest = oiGet(theOI,'optics focal length','mm');

assert(abs(focalLengthTest/pupilTest - desiredFNumber) < 1e-6);
assert(abs(focalLengthTest - 4) < 1e-6);


%%

pupilDiamMmCheck = 1000 * oiGet(theOI, 'optics aperture diameter');
if (max(abs(pupilDiamMmCheck - pupilDiamMm)) > 1e-8)
    error('Failed to set pupil diameter as expected');
end
