function [illScale, meanSPD] = hcIlluminantScale(hcIlluminant)
% Estimate the relative illuminant intensity across space
%
%   [illScale, meanSPD] = hcIlluminant(hcIlluminant)
%
% Inputs:
%  hcIlluminant:  Hypercube illuminant data
%
% Returns:
%   illScale: Relative intensity of the illuminant across the image
%   meanSPD:  Illuminant SPD (mean)
%
% The img is a relative weighting so it does not matter if we find this in
% energy units or photon units ... the scalar will be the same
%
% Example:
%
%
% See also:  s_hcHyspexToISET
%
% Copyright Imageval, LLC , 2013

if ieNotDefined('hcIlluminant'), error('hypercube illuminant required');end

[hcIlluminant,r,c] = RGB2XWFormat(hcIlluminant);
meanSPD = mean(hcIlluminant,1);
% vcNewGraphWin; plot(meanSPD)

% In XW format, each column is a SPD at a pixel.  We want to describe all
% of the pixels by a scale factor with respect to the meanIllSPDEnergy
%
%   energyXW = weightPerPixel*meanIllSPDEnergy
%      e = w*m
%      w = e*m'*(m*m')^-1
%   or
%      w = e*pinv(m)
%
illScale = double(hcIlluminant)*pinv(meanSPD(:)');
illScale = reshape(illScale,r,c);

% Normalize so that the weights are between 0 and 1, and correct the ill
% spd so that everything is reasonable.
mx       = max(illScale(:));
illScale = illScale/mx;
meanSPD  = mx*meanSPD;

% vcNewGraphWin; imagesc(illScale); colormap(gray(64))

end
