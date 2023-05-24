function outPSF = psfCircularlyAverage(inPSF)
% Circularly average the provided PSF
%
% Syntax:
%   outPSF = psfCircularlyAverage(inPSF)
%
% Description:
%    As the name suggests. The PSF output volume is scaled to match the PSF
%    input volume.
% 
% Inputs:
%    inPSF  - Point-Spread Function
%
% Outputs:
%    outPSF - Circularly-averaged Point-Spread Function
%
% Optional key/value pairs:
%    None.
%

% History:
%    07/19/07  dhb  Wrote it.
%    12/22/09  dhb  Fix bug in how peakRow and peakCol are computed.
%    12/22/09  dhb  Make computation a little more fine grained.
%    07/23/12  dhb  Match out volume to in volume.
%    11/13/17  jnm  Comments & Formatting
%    01/01/18  dhb  Simplified example
%    01/11/18  jnm  Formatting update to match Wiki

% Examples:
%{
    wvf0 = wvfCreate;
    oblique_astig = 0.75;
    wvf0 = wvfSet(wvf0, 'zcoeffs', oblique_astig, {'oblique_astigmatism'});
    wvf0 = wvfComputePSF(wvf0);
    psf0 = wvfGet(wvf0, 'psf');
    psfC = psfCircularlyAverage(psf0);
    figure;
    clf;

    subplot(1, 2, 1);
    mesh(psf0);
    title('Astigmatic PSF');
    view(0, 90);
    axis('equal');
    axis([50 150 50 150]);

    subplot(1, 2, 2);
    mesh(psfC);
    title('Circularly Averaged PSF');
    view(0, 90);
    axis('equal');
    axis([50 150 50 150]);
%}

% Define quantization. Four was used in early code, but 1 makes more sense.
quantizationFactor = 1;

% Make a circularly symmetric version of average optics.
[m, n] = size(inPSF);
if (n ~= m), error('Input must be a square matrix'); end
nLinearPixels = m;

[peakRow, peakCol] = psfFindPeak(inPSF);
radiusMat = MakeRadiusMat(nLinearPixels, nLinearPixels, peakCol, peakRow);
outPSF = zeros(nLinearPixels, nLinearPixels);
nBands = round(nLinearPixels / quantizationFactor);
radii = linspace(0, 0.75 * nLinearPixels, nBands);
for q = 1:length(radii) - 1
    index = find(radiusMat >= radii(q) & radiusMat < radii(q + 1));
    if (~isempty(index)), outPSF(index) = mean(inPSF(index)); end
end
outPSF = sum(inPSF(:)) * outPSF / sum(outPSF(:));
