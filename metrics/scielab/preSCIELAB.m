function [refImage,resampledcmpImage] = preSCIELAB(refImage,cmpImage)
%
%  [refImage,resampledcmpImage] = preSCIELAB(refImage,cmpImage)
%
% Author: ImagEval
% Purpose: pre-process images before performing S-CIELAB evaluation,
%          including : resize images to have the same size of images
%                      AND
%                      rescale images to make them within the same range
%          also need to reshape images to be compliant with the
%          scielab routine
% INPUT  : refImage -- reference image used in S-CIELAB evaluation
%          cmpImage -- image to be evaluated in S-CIELAB
% OUTPUT : refImage & cmpImage after being pre-processed for S-CIELAB
%           evaluation
%

warning('preSCIELAB Probably should be obsolete or at least handled by a different functionality.')

% Resize first
[mRows,mCols,mColors] = size(refImage);
[nRows,nCols,nColors] = size(cmpImage);

vectory = linspace(1,mRows,nRows);
vectorx = linspace(1,mCols,nCols);

[x,y] = meshgrid(vectorx,vectory);
[xi,yi] = meshgrid(1:mCols,1:mRows);

if nColors == 1,
    resampledcmpImage = interp2(x,y,cmpImage,xi,yi);
else
    resampledcmpImage(:,:,1) = interp2(x,y,cmpImage(:,:,1),xi,yi);
    resampledcmpImage(:,:,2) = interp2(x,y,cmpImage(:,:,2),xi,yi);
    resampledcmpImage(:,:,3) = interp2(x,y,cmpImage(:,:,3),xi,yi);
end

% Rescale : set range to [0 1]
refImage = refImage/max(refImage(:));
resampledcmpImage = resampledcmpImage/max(resampledcmpImage(:));

% Put output in a form that can be called by spatialCIELAB.m
if nColors == 1,
    refImage = [refImage refImage refImage];
    resampledcmpImage = [resampledcmpImage resampledcmpImage resampledcmpImage];
else
    refImage = [refImage(:,:,1) refImage(:,:,2) refImage(:,:,3)];
    resampledcmpImage = ...
        [resampledcmpImage(:,:,1) resampledcmpImage(:,:,2) resampledcmpImage(:,:,3)];
end

return;
