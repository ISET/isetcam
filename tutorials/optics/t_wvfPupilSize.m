%% The effect of human pupil size on defocus
%
% Thibos and colleagues in Indiana collected wavefront aberration
% data for the human eye using
% <https://en.wikipedia.org/wiki/Shack%E2%80%93Hartmann_wavefront_sensor
% Shack-Hartman wavefront sensors>.  These data were collected at
% a large pupil diameter.
%
% Here, we set these data into the Zernike coefficients, and
% then we explore the effects of changing the pupil size. We
% evaluate the effect by computing the expected pointspread
% function.
%
% See also: wvfLoadThibsVirtualEyes, wvfCreate, wvfPlot
%
% (BW) (c) Wavefront Toolbox Team, 2014

%% Initialize
ieInit;

%% Load the Thibos data for one of the pupil diameter sizes

pupilMM = 7.5;        % Could be set to 6, 4.5, or 3 ...
zCoefs = wvfLoadThibosVirtualEyes(pupilMM);

% Create the wvf parameter structure with the appropriate values
wave = 520';
wvfP = wvfCreate('wave',wave,'zcoeffs',zCoefs,'name',sprintf('%d-pupil',pupilMM));
wvfP = wvfSet(wvfP,'pupil diameter',pupilMM);

%% Calculate the effect of varying the pupil diameter

cPupil = [2,4,7];
for ii=1:sum(cPupil<=pupilMM)
    wvfP = wvfSet(wvfP,'pupil diameter',cPupil(ii));
    wvfP = wvfComputePSF(wvfP);
    wvfPlot(wvfP,'2d psf space','um',wave,20);
    title(sprintf('pupil diameter %.1f mm',cPupil(ii)));
end

%%