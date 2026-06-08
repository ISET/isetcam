%% s_wvfPSFSpacing
%
% Illustrates how to control the PSF sample spacing
%
% This can be done by a wvfSet(wvf,'psf sample spacing',valMM)
% The calculation is shown here
%
% Also documented in t_wvfOverview.mlx

wvf = wvfCreate;

lambdaNM = 550;
fnumber = 4;
focallengthMM = 4;
nPixels = 1024;

wvf = wvfSet(wvf,'wave',lambdaNM);
wvf = wvfSet(wvf, 'focal length', focallengthMM, 'mm');
wvf = wvfSet(wvf, 'calc pupil diameter', focallengthMM/fnumber);
wvf = wvfSet(wvf, 'spatial samples', nPixels);

%% this is what we are trying to match

psf_spacingMM = 1e-3; 

lambdaMM = wvfGet(wvf,'wave','mm');
focalLengthMM = wvfGet(wvf,'focal length','mm');
nPixels = wvfGet(wvf,'npixels');

% compute the pupil sample spacing that matches this PSF sample
% spacing in the image plane.
pupil_spacingMM = lambdaMM * focallengthMM / (psf_spacingMM * nPixels);

% This implements the change in PSF dx
wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * nPixels);
wvfSummarize(wvf);

%% Now initialize another psf dx

psf_spacingMM = 2e-3; 

pupil_spacingMM = lambdaMM * focallengthMM / (psf_spacingMM * nPixels);
wvf = wvfSet(wvf,'field size mm', pupil_spacingMM * nPixels);

% The other optical parameters (e.g., f-number, focal length) are unchanged
wvfSummarize(wvf);

%% Now do this through a call to wvfSet()

% Sample spacing in millimeters (1 micron)
val = 1e-3;
wvf = wvfSet(wvf,'psf sample spacing',val) % or wvfSet(wvf, 'psf dx',val)
wvfSummarize(wvf)

%% TODO: add code to explain the angle version, here

% This is an angular measure
wvfGet(wvf,'ref psf sample interval')


%%