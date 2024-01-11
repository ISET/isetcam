% t_wvfPupilSize
%
% Explore the effect of changing the pupil size in the calculation.
%
% Description:
%    We load the Thibos wavefront data for various pupil diamters and
%    caclulate and plot psfs for various other pupil diameters.
%
%    We then set the calculated pupil size and compute the expected
%    pointspread function. That function changes as the pupil diameter gets
%    smaller, and also varies a little with the measured size for a fixed
%    calculation size.
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/14  BW   (c) Wavefront Toolbox Team, 2014
%    12/20/17  dhb  Add exploration of different measurement sizes.
%    09/25/18  jnm  Formatting

%% Initialize
ieInit;

%% Load the Thibos data for one of the measured pupil diameter sizes
% Measured pupil size can be 7.5 6, 4.5, or 3 mm. Here we load the largest
% available size, so that we can vary the size of the calcualated pupil and
% see its effect. See below to examine the effect of measured pupil size.
measPupilMM = 7.5;
zCoefs = wvfLoadThibosVirtualEyes(measPupilMM);

% Create the wvf parameter structure with the appropriate values
wave = 520';
wvfP = wvfCreate('wave',wave,'zcoeffs',zCoefs,'name',sprintf('%d-pupil',measPupilMM));
wvfP = wvfCompute(wvfP,'human lca',true);
wvfP = wvfSet(wvfP,'measured pupil diameter',measPupilMM);

%% Calculate the effect of varying the pupil diameter
cPupil = [2,4,7];
for ii=1:sum(cPupil<=measPupilMM)
    wvfP = wvfSet(wvfP,'calc pupil diameter',cPupil(ii));
    wvfP = wvfCompute(wvfP,'human lca',true);
    wvfPlot(wvfP,'psf','unit','um','wave',wave,'plot range',20);
    title(sprintf('pupil diameter %.1f mm',cPupil(ii)));
end

%%
% Create the wvf parameter structure with the appropriate values Be sure to
% set both measured pupil size and the pupil size for calculation. It's
% true that we'll vary it below, but initializing both explicitly is a good
% habit to get into.
%
% The calculated pupil size must be equal to or smaller than the measured
% pupil size.
wave = (400:10:700)';
index550 = find(wave == 550);
wvfP = wvfCreate('calc wavelengths', wave, 'zcoeffs', zCoefs, ...
    'measured pupil size', measPupilMM, 'calc pupil size', measPupilMM, ...
    'name', sprintf('%d-pupil', measPupilMM));

%% Explore the effect of varying the pupil diameter used in the calculation

% This is done with the measured pupil size fixed.
measPupilMM = 7.5;
calcPupilMM = [2, 3, 4, 5, 6, 7];
for ii = 1:sum(calcPupilMM <= measPupilMM)
    wvfP = wvfSet(wvfP, 'calc pupil size', calcPupilMM(ii));
    wvfP = wvfCompute(wvfP,'human lca',true);
    wvfPlot(wvfP, 'psf', 'unit','um', 'wave', 550, 'plot range', 20);
    title(sprintf(strcat("Measured pupil diameter %0.1f mm, ", ...
        "calculated pupil diameter %.1f mm"), measPupilMM, ...
        calcPupilMM(ii)));
end

%% Now fix the calcuated pupil size at 3 mm and vary the measured size.

% We are not sure whether the Thibos data contains measurements made of
% real eyes for different pupil sizes, or whether the measurements were
% made for the largest pupil size and then the Zernike coefficients
% computed from the measured pupil function over various diameters.
%
% In either case, in an idealized world, we think that the central (e.g.) 3
% mm of the pupil function would be the same no matter how large a pupil
% the measurements were made for. Measurement or calculation error could
% cause deviations from this prediction, however. We do find differences in
% the psfs computed for 3 mm from various measured pupil sizes, but they
% are not large.
%
% Here, each time through the loop, we load new zcoeffs according to the
% specified measurement pupil size.
clear psf
measPupilMM = [7.5 6 4.5 3];
calcPupilMM = 3;
for ii = 1:sum(measPupilMM >= calcPupilMM)
    zCoefs = wvfLoadThibosVirtualEyes(measPupilMM(ii));

    % Uncomment the next line if you want to try this with diffraction
    % limited rather than Thibos optics. This shows that we get the same
    % psf no matter what pupil size we say was measured, as expected.
    % zCoefs = zeros(size(zCoefs));

    wvfP = wvfCreate('calc wavelengths', wave, 'zcoeffs', zCoefs, ...
        'measured pupil size', measPupilMM(ii), ...
        'calc pupil size', calcPupilMM, ...
        'name', sprintf('%d-pupil', measPupilMM(ii)));
    wvfP = wvfCompute(wvfP,'human lca',true);
    psf{ii} = wvfGet(wvfP, 'psf');
    if (ii > 1)
        maxAbsDiff = max(abs(psf{1}{index550}(:) - psf{ii}{index550}(:)));
        if (maxAbsDiff > 1e-7)
            fprintf(strcat("Psf calculated at 550 nm for %d mm ", ...
                "differs for measured pupil %g mm and %g mm\n"), ...
                calcPupilMM, measPupilMM(1), measPupilMM(ii));
            fprintf(strcat("\tMax abs difference is %0.2g, max of psf", ...
                " 1 is %0.2g\n"), maxAbsDiff, max(psf{ii}{index550}(:)));
        else
            fprintf(strcat("Psf calculated at 550 nm for %d mm ", ...
                "matches for measured pupil %g mm and %g mm\n"), ...
                calcPupilMM, measPupilMM(1), measPupilMM(ii));
        end
    end
    wvfPlot(wvfP, 'psf', 'unit','um', 'wave',550, 'plot range', 20);    
    title(sprintf(strcat("Measured pupil diameter %0.1f mm, ", ...
        "calculated pupil diameter %.1f mm"), measPupilMM(ii), ...
        calcPupilMM));
end
