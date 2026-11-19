%% Retinal exposure limits for an isolated LED flash
%
% Run this script with ISETCam on the MATLAB path. Edit the input section
% for a different measured spectrum and pulse duration, or call
% humanFlashSafety(spectralRadiance,wave,flashDuration,sourceAngle) directly.
%
% Figure and example spectrum provenance
%   Farrell, Mou and Wandell, "Modeling spectroradiometric measurements of
%   oral mucosal tissue autofluorescence," Biomed. Opt. Express,
%   DOI 10.1364/BOE.575722, Figure 1B (dashed 415 nm trace). 
% 
%   The plot has alogarithmic ordinate. The example uses the
%   underlying linear radiance data from the paper's repository. The
%   Figure 1 script, figures/oeFigure1_LightCalibration.mlx, selects
%   the verification measurements for the nominal 415 nm LED driven at
%   920 mA. The source file used here is
%   data/ExcitationLights/spd-2024-03-07-verif-415nm450SPF-920mA.mat
%   in https://github.com/ISET/ISETOralMucosa at commit
%   4d68d67e2390dbc6e1fa56ba26b865883d7d2528. Source file SHA-256:
%   c9d2cff63d95fcd548f7f3e44834a7ec8f9b1afe0b69f6ae2ae9336134ccf783
%
%   The measurement was made under steady LED illumination through a
%   450 nm short-pass filter, as in the OralEye.
% 
%   The spectroradiometer viewed a diffuse white target at the
%   experimental working distance from the illuminator. The saved
%   example represents the radiance of that reflecting surface. To
%   reproduce the file from the original MAT file, load its wavelength
%   and data arrays. The native samples cover 380:2:780 nm, and linear
%   interpolation between 414 and 416 nm gives 18.345 W/(m^2 sr nm) at
%   415 nm. Linearly interpolate onto the column vector (380:780)' and
%   multiply all values by 10/18.345, using 10 W/(m^2 sr nm) as the
%   estimated 415 nm level for this example. The resulting peak is at
%   416 nm. Save the wavelength vector and the scaled radiance with
%   ieSaveSpectralFile. The 8 ms duration is the specified OralEye
%   flash duration. This example assumes the scaled spectrum
%   represents the average radiance during that pulse.
%
% Exposure calculation
%   IEC 62471:2006 is included in docs/EN62471.pdf. Clause 6.2 specifies the
%   1.7 mrad radiance field of view for pulsed lamps. Clause 4.3.3 (Eq. 4.5a)
%   limits the 300-700 nm B(lambda)-weighted radiance dose to 1e6 J/(m^2 sr).
%   Clause 4.3.5 (Eq. 4.9) limits the 380-1400 nm R(lambda)-weighted radiance
%   to 50000/(sourceAngle * flashDuration^0.25) W/(m^2 sr). To put the
%   thermal limit in the same units as the calculated dose, multiply by the
%   flash duration. The apparent source angle used in that limit is distinct
%   from the angular averaging field of view of the measurement. This
%   example uses 0.1 rad, the largest value in clause 4.2.2 and the value
%   that yields the lowest thermal limit for the supplied radiance.
%
%   B(lambda) and R(lambda) are loaded from the ISETCam spectral tables
%   blueLightHazard.mat and burnHazard.mat. Integrate each weighted spectrum
%   by the trapezoidal rule on the union of measured wavelengths, integer-nm
%   wavelengths and the endpoints of the measured overlap with the hazard
%   band. Interpolate linearly before multiplying spectral radiance by the
%   weights. Multiply the result by 0.008 s for the single-pulse dose.
%   The margin factor is the dose limit divided by the calculated dose.
%   Expected example results are approximately 1.127 J/(m^2 sr) and
%   8.87e5 for blue light, and 11.28 J/(m^2 sr) and 1.19e3 for thermal.
%
% Related estimates and scope
%   For a Lambertian target, incident spectral irradiance at that target is
%   pi * spectralRadiance ./ reflectance. Assuming unit reflectance, the
%   measured-band radiant exposure is pi * 0.008 * trapz(wave,spectralRadiance),
%   or about 5.18 J/m^2. Restricting this integration to 380-400 nm gives
%   about 0.140 J/m^2 of measured near-UV exposure. The 8 ms small-area skin
%   thermal benchmark from Eq. 4.12 is 20000 * 0.008^0.25, about 5981 J/m^2.
%   This benchmark describes skin exposure. With one flash every
%   5 or 10 s, the time-averaged reflected, blue-light-weighted radiance is
%   the single-pulse blue-light dose divided by the spacing in seconds
%   (about 0.225 or 0.113 W/(m^2 sr), respectively). Each 0.25 s window
%   contains at most one flash at those spacings. Clause 6.2 calls for a
%   continuous-wave risk assessment using time-averaged emission for a
%   repetitively pulsed lamp.
%
%   The values reported below apply to the supplied viewing condition and
%   the two retinal hazards for one pulse. To assess direct viewing, use
%   radiance of the assembled LED and optics as seen from the eye position.
%   Preserve the raw spectrum, calibration, optical geometry, pulse
%   waveform and measurement uncertainty when recording a device test.
%   The example spectrum covers 380-780 nm. Include any material emission
%   outside that band for a different source, and assess UV exposure with
%   the appropriate irradiance limits if applicable.

%% Inputs
spectrumFile = fullfile(fileparts(mfilename('fullpath')),'oralEye415Reference.mat');
[spectralRadiance,wave] = ieReadSpectra(spectrumFile);
flashDuration = 0.008; % seconds
sourceAngle = 0.1; % radians

%% Calculate and report the retinal margins
results = humanFlashSafety(spectralRadiance,wave,flashDuration,sourceAngle);
fprintf('IEC 62471:2006 retinal exposure for one %g ms flash\n',1000 * results.duration);
fprintf('Thermal source angle: %g rad\n',results.sourceAngle);
fprintf('Weighted dose and limit in J/(m^2 sr)\n');
fprintf('Blue light: %.3g / %.3g, %.3g%% of limit, margin factor %.3g\n', ...
    results.blueLight.dose,results.blueLight.limit, ...
    100 * results.blueLight.fractionOfLimit,results.blueLight.marginFactor);
fprintf('Retinal thermal: %.3g / %.3g, %.3g%% of limit, margin factor %.3g\n', ...
    results.retinalThermal.dose,results.retinalThermal.limit, ...
    100 * results.retinalThermal.fractionOfLimit,results.retinalThermal.marginFactor);
