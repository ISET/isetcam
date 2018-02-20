function outPSF = psfCircularlyAverage(inPSF)
% outPSF = psfCircularlyAverage(inPSF)
%
% As the name suggests.  The output volume is
% scaled to match the input volume.
%
% 7/19/07   dhb  Wrote it.
% 12/22/09  dhb  Fix bug in how peakRow and peakCol are computed.
% 12/22/09  dhb  Make computation a little more fine grained.
% 7/23/12   dhb  Match out volume to in volume.

% Define quantization.  Four was used in early code, but 1 makes more sense.
quantizationFactor = 1;

% Make a circularly symmetric version of average optics.
[m,n] = size(inPSF);
if (n ~= m)
    error('Input must be a square matrix');
end
nLinearPixels = m;

[peakRow,peakCol] = psfFindPeak(inPSF);
radiusMat = MakeRadiusMat(nLinearPixels,nLinearPixels,peakCol,peakRow);
outPSF = zeros(nLinearPixels,nLinearPixels);
nBands = round(nLinearPixels/quantizationFactor);
radii = linspace(0,0.75*nLinearPixels,nBands);
for q = 1:length(radii)-1;
    index = find(radiusMat >= radii(q) & radiusMat < radii(q+1));
    if (~isempty(index))
        outPSF(index) = mean(inPSF(index));
    end
end
outPSF = sum(inPSF(:))*outPSF/sum(outPSF(:));