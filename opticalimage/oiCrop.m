function [oi,rect] = oiCrop(oi,rect)
%Crop the data in an optical image
%
% Synopsis
%  [oi,rect] = oiCrop(oi,[rect])
%
% Description
%   The image axis is (1,1) in the upper left.  Increasing y-values run
%   down the image.  Increasing x-values run to the right.
%   The rect parameters are [x y width-1 height-1].
%   (x,y) is the upper left corner of the rectangular region
%
% Inputs
%    oi:  An optical image structure
%  rect:  A vector [x y width-1 height-1].
%         It can also be the string 'border' in which case the black border
%         is removed
%
% Optional key/value pairs:
%  N/A
%
% Outputs:
%   oi:   The modified optical image structure
%  rect:  The rect used to crop the original
%
% Description:
%  Crop the data (photons) in the scene or optical image to within the
%  rectangle, rect. If rect is not defined a graphical routine is initiated
%  for selecting the rectangle.
%
%  Because these are multispectral data, we can't use the usual imcrop.
%
%  Crop the depth map along with the photons when their sizes match.
%  Update the field of view to preserve the image-plane sample spacing.
%
%  A common case is to remove the black border from the oi window.  That is
%  managed by setting rect = 'border';
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   oiCompute, oiPadValue
%

% Examples:
%{
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
sz = oiGet(oi,'size');
rect = ceil([sz(2)*0.1 + 1, sz(1)*0.1 + 1, sz(2)* 0.8 - 1, sz(1)*0.8 - 1]);
oi = oiCrop(oi,rect);
oiWindow(oi);
%}

%%
if ieNotDefined('oi'), error('You must define an optical image.'); end

if ieNotDefined('rect')
    [roiLocs,rect] = ieROISelect(oi);
elseif isequal(rect, 'roundeven')
    % Sometimes you may want the oi size to be even, use this then.
    sz = oiGet(oi, 'size');
    rect = [1, 1, sz(2) - 1, sz(1) - 1];
    if isodd(rect(3) - rect(1)),  rect(3) = rect(3) - 1; end
    if isodd(rect(4) - rect(2)), rect(4) = rect(4) - 1; end
    roiLocs = ieRect2Locs(rect);
elseif isequal(rect,'border')
    sz = oiGet(oi,'size');
    % Rects are x,y, not row col.  Not sure why I had to screw
    % around like this with the 1 pixel offsets.  Something about
    % calculating from 1:N instead of 0:N-1
    rect = ceil([sz(2)*0.1 + 1, sz(1)*0.1 + 1, sz(2)* 0.8 - 1, sz(1)*0.8 - 1]);
    if isodd(rect(3) - rect(1)), rect(3) = rect(3) - 1; end
    if isodd(rect(4) - rect(2)), rect(4) = rect(4) - 1; end
    roiLocs = ieRect2Locs(rect);
elseif isvector(rect)
    roiLocs = ieRect2Locs(rect);
end

%% Preserve the original sample spacing
samplePitch = oiGet(oi,'sample size');
sourceSize = oiGet(oi,'size');
%% Adjust the irradiance data

% The number of selected columns and rows
c = rect(3)+1; r = rect(4)+1;

% These are in XW format.
photons = vcGetROIData(oi,roiLocs,'photons');
photons = XW2RGBFormat(photons,r,c);

oi = oiSet(oi,'photons',photons);
depthMap = oiGet(oi,'depth map');
if isequal(size(depthMap),sourceSize)
    rows = ieClip(roiLocs(:,1),1,sourceSize(1));
    cols = ieClip(roiLocs(:,2),1,sourceSize(2));
    depthMap = reshape(depthMap(sub2ind(sourceSize,rows,cols)),r,c);
    oi = oiSet(oi,'depth map',depthMap);
end

oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));

%% Update the horizontal field of view

imageDistance = oiGet(oi,'focal plane distance');
oi = oiSet(oi,'wangular',2 * atand(c * samplePitch / (2*imageDistance)));

end





