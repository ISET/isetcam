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

%%
wvf = wvfCreate;
wvf = wvfCompute(wvf);

otfSupport = wvfGet(wvf,'otf support');
min(otfSupport), max(otfSupport)

psfSupport = wvfGet(wvf,'psf support','um');
min(psfSupport), max(psfSupport)

wvfSummarize(wvf);

%% Change number of pixels

% Changes the PSF support but not the PSF spacing
% Changes the OTF spacing, but not the OTF support
wvf = wvfCreate;

wvf = wvfSet(wvf,'npixels',101);
wvfSummarize(wvf);

wvf = wvfSet(wvf,'npixels',801);
wvfSummarize(wvf);

%% Focal length - changes all the spatial params (psf and otf)

% Notice the change in um per degree and f number as well.
wvf = wvfCreate;

wvf = wvfSet(wvf,'focal length',4,'mm');
wvfSummarize(wvf);

wvf = wvfSet(wvf,'focal length',40,'mm');
wvfSummarize(wvf);

%% Calc pupil diameter

% No change to the PSF and OTF parameters
wvf = wvfCreate;

% Notice the change in f number as well.

wvf = wvfSet(wvf,'calc pupil diameter',1,'mm');
wvfSummarize(wvf);

wvf = wvfCreate;

wvf = wvfSet(wvf,'calc pupil diameter',6,'mm');
wvfSummarize(wvf);

%% Change the measured pupil specification

wvf = wvfCreate;

wvf = wvfSet(wvf,'measured pupil diameter',3,'mm');
wvfSummarize(wvf);

wvf = wvfSet(wvf,'measured pupil diameter',6,'mm');
wvfSummarize(wvf);

%% Match a target OI sample spacing

lambdaMM = 550e-6;
fnumber = 4;
focallengthMM = 4;
nPixels = 1024;

wvf = wvfSet(wvf, 'focal length', focallengthMM, 'mm');

wvf = wvfSet(wvf, 'calc pupil diameter', focallengthMM/fnumber);

wvf = wvfSet(wvf, 'spatial samples', nPixels);

psf_spacingMM = 1e-3; % this is what we are trying to match
% compute the pupil sample spacing
pupil_spacingMM = lambdaMM * focallengthMM / (psf_spacingMM * nPixels);

wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * nPixels);

wvfSummarize(wvf);

% Notice that pupil plane is smaller than pupil diameter in this case.
psf_spacingMM = 3e-3; % this is what we are trying to match
% compute the pupil sample spacing
pupil_spacingMM = lambdaMM * focallengthMM / (psf_spacingMM * nPixels);

wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * nPixels);

wvfSummarize(wvf);


%% END
