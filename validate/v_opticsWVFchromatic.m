%% v_opticsWVFchromatic
%
% Check the wavelength dependency of the wavefront calculation.
%
% Seems perfect to me.
%
% Imageval Consulting, LLC 2015

ieInit

%% I compared this with the ISETBIO verion of wvfP
% they are identical at 550, when there is no charomatic abberation

% Create the wvf parameter structure with the appropriate values
for thisWave = [400, 500, 600, 700]
    pupilMM = 3; % Could be 6, 4.5, or 3
    fLengthM = 17e-3;

    wvfP = wvfCreate('wave', thisWave, 'name', sprintf('%d-pupil', pupilMM));
    wvfP = wvfSet(wvfP, 'pupil diameter', pupilMM);
    wvfP = wvfComputePSF(wvfP);
    wvfP = wvfSet(wvfP, 'focal length', fLengthM); % 17 mm focal length for deg per mm

    pRange = 9; % Microns
    wvfPlot(wvfP, '2d psf space', 'um', thisWave, pRange);
    title(sprintf('Calculated pupil diameter %.1f mm', pupilMM));

    % This is the radius of the Airy disk for this fnumber
    fNumber = wvfGet(wvfP, 'focal length', 'mm') / pupilMM;
    radius = (2.44 * fNumber * thisWave * 10^-9) / 2 * ieUnitScaleFactor('um');
    nSamp = 200;
    [adX, adY, adZ] = ieShape('circle', nSamp, radius);
    adZ = adZ + max(wvfP.psf{1}(:)) * 5e-3;
    hold on;
    p = plot3(adX, adY, adZ, 'k-');
    set(p, 'linewidth', 3);
    hold off;
    title(sprintf('WVF psf at %d (fnumber %.1f)', thisWave, fNumber))

end
