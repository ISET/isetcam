function [otf, achOTF] = humanCore(wave, sampleSF, p, D0)
%  Compute the human optical transfer function
%
% Syntax:
%   [otf, achOTF] = humanCore(wave, nWave, sampleSF, p, D0)
%
% Description:
%    Calculate the human OTF.
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanCore.m' into the Command Window.
%
% Inputs:
%    p        - Numeric. Pupil radius in meters. Computed from f/# and
%               focal length.
%    D0       - Numeric. The base dioptric power (accomodation), usually
%               around 60.
%    sampleSF - Vector. Spatial frequencies in cycles/deg
%    wave     - Vector. Wavelength in nanometers
%
% Outputs:
%    otf      -  Matrix. Optical transfer function (actually, this is the
%                MTF, just a set of scale factors. We assume there is no
%                frequency-dependent phase shift.
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * [Calculation is based on 
%    Marimont and Wandell 1994): Matching color images: the effects of 
%    axial chromatic aberration, JOSA,  Vol. 11, Issue 12, pp. 3113-3122]
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    06/14/18  jnm  Formatting

% Examples:
%{
    wave = 400:10:700;
    sampleSF = [0:1:30];
    p = 0.0015;
    D0 = 60;
    otf = humanCore(wave, sampleSF, p, D0);
    mesh(sampleSF, wave, otf)
%}

% Retrieve the defocus, in diopters, at each wavelength
D = humanWaveDefocus(wave);

% Converts the defocus in diopters to the Hopkins w20 parameter for a given
% pupil radius in meters, defocus (D, diopters), and dioptric power (D0).
% The explanation for this formula is in Marimont and Wandell.
w20 = p ^ 2 / 2 * (D0 .* D) ./ (D0 + D);

% plot(wave, w20);
% grid on;
% xlabel('Wavelength (nm)');
% ylabel('relative defocus (Hopkins w20)');

% We use this factor to convert from the input spatial frequency units
% (cycles/deg) to cycles/meter needed for the Hopkins eye
% c = 3434.07;  % degrees per meter for human eye
c = 1 / (tand(1) * (1 / D0));  % deg per meter for a human eye

% Compute the general OTF, independent of wavelength.
achOTF = humanAchromaticOTF(sampleSF);

s = zeros(length(wave), length(sampleSF));
alpha = zeros(size(s));
otf = zeros(size(s));
lambda = wave * 1e-9;

for ii = 1:length(wave)
    % Compute the reduced spatial frequency (0, 2)
    % s = m * (m/m) * cy/m -> Dimensionless in the end
    s(ii, :) = ( c * lambda(ii) / (D0 * p)) * sampleSF;
    % s(ii, :) = ( lambda(ii) /(D0*p)) * sampleSFm;

    % Related to the defocus specified by w20, which in turn depends on p,
    % D and D0.
    alpha(ii, :) = ((4 * pi) ./ (lambda(ii))) .* w20(ii) .* s(ii, :);

    % We put the vector of sample SF into this array.
    % Then we interpolate to the full 2D array outside of this loop.
    otf(ii, :) = opticsDefocusedMTF(s(ii, :), abs(alpha(ii, :)));

    % Combine the Williams human measurements. The otf() variable now
    % represents the Hopkins OTF combined with the further distortions
    % measured for a typical human eye by Williams. Each row is for a
    % different wavelength. In the next move, when we return to the calling
    % routine, humanOTF, we interpolate these values from sampleSF and wave
    % into the full OTF2D at the frequencySupport spacing.
    otf(ii, :) = otf(ii, :) .* achOTF;
end

end