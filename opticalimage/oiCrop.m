function [oi, rect] = oiCrop(oi, rect)
%Crop the data in an optical image
%
% Synopsis
%  [oi,rect] = oiCrop(oi,[rect])
%
% Description
%   The image axis is (1,1) in the upper left.  Increasing y-values run
%   down the image.  Increasing x-values run to the right.
%   The rect parameters are (x,y,width,height).
%   (x,y) is the upper left corner of the rectangular region
%
% Inputs
%    oi:  An optical image structure
%  rect:  Typically a vector (rect) of [row col height width]
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
%  This routine also updates the field of view parameter.s
%
%  A common case is to remove the black border from the oi window.  That is
%  managed by setting rect = 'border';
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
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
    [roiLocs, rect] = ieROISelect(oi);
elseif isequal(rect, 'border')
    sz = oiGet(oi, 'size');
    % Rects are x,y, not row col.  Not sure why I had to screw
    % around like this with the 1 pixel offsets.  Something about
    % calculating from 1:N instead of 0:N-1
    rect = ceil([sz(2) * 0.1 + 1, sz(1) * 0.1 + 1, sz(2) * 0.8 - 1, sz(1) * 0.8 - 1]);
    roiLocs = ieRect2Locs(rect);
elseif isvector(rect)
    roiLocs = ieRect2Locs(rect);
end

%% Preserve the original sample space
sampleSpace = oiGet(oi, 'distance per sample');

%% Adjust the irradiance data

% The number of selected columns and rows
c = rect(3) + 1;
r = rect(4) + 1;

% These are in XW format.
photons = vcGetROIData(oi, roiLocs, 'photons');
photons = XW2RGBFormat(photons, r, c);

% oi    = oiClearData(oi);
oi = oiSet(oi, 'photons', photons);
newSz = oiGet(oi, 'size');

oi = oiSet(oi, 'illuminance', oiCalculateIlluminance(oi));

%% Update the horizontal field of view

% Also, the sample spacing will not be preserved when the FOV changes and
% becomes large. We might consider to do an integration to calculate
% accurate width/height of the new frame.


focalLength = oiGet(oi, 'optics focal length');
%{
% ZLY: I think we can calculate the wAngular in this way.
wAngular = oiGet(oi,'wangular');
sz = oiGet(oi,'size');
wAngularNew = atand(newSz(2) * sampleSpace/2/focalLength) /...
atand(sz(2) * sampleSpace/2/focalLength) * wAngular;
%}
wAngularNew = atand(newSz(2)*sampleSpace(2)/2/focalLength) * 2;


oi = oiSet(oi, 'wangular', wAngularNew);


end
