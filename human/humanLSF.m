function [lineSpread, xDim, wave] = ...
    humanLSF(pupilRadius, dioptricPower, unit, wave)
% Calculate the human linespread function at a range of wavelengths
%
% Syntax:
%   [lsf, xDim, wave] = humanLSF([pupilRadius], [dioptricPower], ...
%       [unit], [wave]);
%
% Description:
%    The pupil radius is typically 0.5-3mm and specified in meters
%    The dioptric power is around 1/0.017mm
%    The returned units are either degrees (default), 'um' or 'mm'
%    wave samples are typically 400:700 nm
%
%    The human line spread function includes the optical defocus and the
%    chromatic aberration. The spatial extent (and spatial frequency) range
%    are determined by the spatial extent and sampling density of the
%    original scene.
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanLSF.m' into the Command Window.
%
% Inputs:
%    pupilRadius   - (Optional) Numeric. The pupil radius, specified in
%                    meters. Default is 0.0015 m.
%    dioptricPower - (Optional) Numeric. The dioptric power. Default is
%                    59.9404 mm.
%    unit          - (Optional) String. The return units. Options include
%                    'default', 'um, and 'mm'. Default is 'mm'.
%    wave          - (Optional) Vector. Vector containing wavelengths in
%                    nm. Default is 400:700 nm.
%
% Outputs:
%    lineSpread    - Matrix. Matrix containing the line spread.
%    xDim          - Vector. The vector containing the x-dimension
%    wave          - Vector. The vector containing the wavelengths
%
% Optional key/value pairs:
%    None.
%
% Notes:
%
% References:
%    Marimont & Wandell (1994 --  J. Opt. Soc. Amer. A, v. 11,
%    p. 3113-3122 -- see also Foundations of Vision by Wandell, 1995.
%
% See Also:
%    humanOTF and discussion therein.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    06/20/18  jnm  Formatting. Fix examples. Split examples. Added
%                   'default' to unit options (same case as 'mm'.

% Examples:
%{
    [lsf, xDim, wave] = humanLSF;
    colormap(jet);
    mesh(xDim, wave, lsf);
    xlabel('wave');
    ylabel('mm')
%}
%{
    [lsf, xDim, wave] = humanLSF([], [], 'mm');
    colormap(jet);
    mesh(xDim, wave, lsf)
%}
%{
    radius = 0.003/2;    % In meters
    dioptricPower = 60;  % In diopters (1/m)
    unit = 'mm';
    [lsf, xDim, wave] = humanLSF(radius, dioptricPower, 'mm');
    colormap(jet);
    mesh(xDim, wave, lsf)
%}

% Default pupil radius is 3mm
if notDefined('pupilRadius'), p = 0.0015; else, p = pupilRadius; end
% dioptric power of unaccomodated eye
if notDefined('dioptricPower'), D0 = 59.9404; else, D0 = dioptricPower; end
if notDefined('unit'), unit = 'mm'; end
if notDefined('wave'), wave = 400:700; end  % Default wavelength sampes

% [Note: BW - I may change the humanOTF return format to include the
% fftshift ... be aware that may break this code. And I may forget to come
% back and clean this  -- BW, 12.06.2006]
% The pupil size is used here ('p')
[combinedOTF, sampleSf, wave] = humanOTF(p, D0, [], wave);
% mesh(sampleSf(:, :, 1), sampleSf(:, :, 2), combinedOTF(:, :, 15))

nWave = length(wave);
% Compute the linespread functions, under the assumption of symmetry. We
% compute the line spread in the row direction.
nSamples = size(combinedOTF, 1);
lineSpread = zeros(nWave, nSamples);

for ii = 1:nWave
    tmp = squeeze(combinedOTF(:, :, ii));
    OTFcenterLine = tmp(:, 1);                     % plot(OTFcenterLine)
    thisLSF = fftshift(abs(ifft(OTFcenterLine)));  % plot(thisLSF)
    lineSpread(ii, :) = thisLSF;
    % I don't understand why this doesn't add up
    % sum(thisLSF), max(OTFcenterLine)
end

% The max is the Nyquist frequency (deg/samp)
% There are two samples at the Nyquist frequency
deltaSpace = 1 / (2 * max(sampleSf(:)));
spatialExtentDeg = deltaSpace * size(lineSpread, 2);
fList = unitFrequencyList(nSamples);
xDim = fList * spatialExtentDeg;

% 330 microns/deg
mmPerDeg = 0.330;
switch lower(unit)
    case {'mm', 'default'}
        xDim = xDim * mmPerDeg;
    case 'um'
        xDim = xDim * mmPerDeg * 10 ^ 3;
    otherwise
        error('Unknown unit %s', unit);
end

end