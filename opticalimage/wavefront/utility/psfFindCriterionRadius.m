function radius = psfFindCriterionRadius(inPSF,criterion)
% radius = psfFindCriterionRadius(psf,criterion)
%
% Find the radius around the peak of the passed circularly symmetric
% PSF that includes criterion fraction [0-1] of the mass.
%
% Doesn't handle cases where PSF is super small or bigger than underlying
% grid.
%
% The passed PSF does not need to be centered or circularly averaged.
%
% 9/16/07  dhb  Wrote it.
% 9/18/07  dhb  Eliminate integer constraint by linear interpolation.
% 12/22/09 dhb  Fix bug in how peakRow and peakCol are computed.
% 12/22/09 dhb  Normalize here so it is more flexible.
% 08/29/11 dhb  Center here so that it need not be done on call.

% Normalize so it sums to one
inPSF = inPSF/sum(inPSF(:));
inPSF = psfCenter(inPSF);

% Make the radius matrix
[n,m] = size(inPSF);
if (n ~= m) 
    error('Input must be a square matrix');
end
nLinearPixels = n;
[peakRow,peakCol] = psfFindPeak(inPSF);
radiusMat = MakeRadiusMat(nLinearPixels,nLinearPixels,peakCol,peakRow);

% Find the criterion radius
maxRadius = max(radiusMat(:));
radius = maxRadius;
for i = 1:floor(maxRadius)
    index = find(radiusMat <= i);
    mass(i) = sum(inPSF(index));
    if (mass(i) > criterion)
        lambda = (criterion-mass(i-1))/(mass(i)-mass(i-1));
        radius = (1-lambda)*(i-1) + lambda*i;
        break;
    end
end