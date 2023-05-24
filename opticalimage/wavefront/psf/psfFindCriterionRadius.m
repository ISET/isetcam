function radius = psfFindCriterionRadius(inPSF, criterion)
% Find the radius around the peak of the passed PSF
%
% Syntax:
%   radius = psfFindCriterionRadius(thePSF, criterion)
%
% Description:
%    Find the radius around the peak of the passed circularly symmetric
%    PSF that includes criterion fraction [0-1] of the mass.
%
%    Doesn't handle cases where PSF is super small or bigger than
%    underlying grid.
%
%    The passed PSF does not need to be centered or circularly averaged.
%
%    The answer comes back in pixels, so you need to convert to more
%    interesting units in the code that calls this utility function.
%
% Inputs:
%    inPSF     - Circularly symmetric PSF
%    criterion - Criterion fraction of the mass
%
% Outputs:
%    radius    - The radius around the PSF's peak
%
% Optional key/value pairs:
%    None.
%
% Notes:
%    * [Note: JNM - Possibly add error checking for if inPSF or criterion
%      are not supplied?]
%

% History:
%    09/16/07  dhb  Wrote it.
%    09/18/07  dhb  Eliminate integer constraint by linear interpolation.
%    12/22/09  dhb  Fix bug in how peakRow and peakCol are computed.
%    12/22/09  dhb  Normalize here so it is more flexible.
%    08/29/11  dhb  Center here so that it need not be done on call.
%    11/13/17  jnm  Comments & formatting
%    01/11/18  jnm  Formatting update to match Wiki

% Examples:
%{
    wvfP = wvfCreate;
    wvfP = wvfComputePSF(wvfP);
    myPSF = wvfGet(wvfP, 'psf');
    rad = psfFindCriterionRadius(myPSF, 0.5)
%}

% Normalize so it sums to one
inPSF = inPSF / sum(inPSF(:));
inPSF = psfCenter(inPSF);

% Make the radius matrix
[n, m] = size(inPSF);
if (n ~= m), error('Input must be a square matrix'); end
nLinearPixels = n;
[peakRow, peakCol] = psfFindPeak(inPSF);
radiusMat = MakeRadiusMat(nLinearPixels, nLinearPixels, peakCol, peakRow);

% Find the criterion radius
maxRadius = max(radiusMat(:));
radius = maxRadius;
mass = zeros(floor(maxRadius));
for ii = 1:floor(maxRadius)
    index = radiusMat <= ii;
    mass(ii) = sum(inPSF(index));
    if (mass(ii) > criterion)
        lambda = (criterion - mass(ii - 1)) / (mass(ii) - mass(ii - 1));
        radius = (1 - lambda) * (ii - 1) + lambda * ii;
        break;
    end
end