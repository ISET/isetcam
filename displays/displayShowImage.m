function rgb = displayShowImage(d, displayFlag, varargin)
%Render an image of the display image data
%
%    rgb = displayShowImage(d, [displayFlag], [varargin])
%
% Examples:
%   d   = displayCreate('LCD-Apple');
%   rgb = displayShowImage(d);
%   displayShowImage(d);
%   rgb = displayShowImage(d, 1, ha);
%
% (HJ) May, 2014

if isempty(d), cla; return;  end
if notDefined('displayFlag'), displayFlag = 1; end
if ~isempty(varargin), ha = varargin{1}; end

% Get parameters
wave = displayGet(d, 'wave');
global vcSESSION;

% Not sure why display image is attached here, rather than to display.  Ask
% HJ.
if isfield(vcSESSION, 'imgData')
    rgb = vcSESSION.imgData;
else
    cla;
    warning('No image data found');
    return;
end

% Compute photon image
scene = sceneFromFile(rgb, 'rgb', [], d);
img   = sceneGet(scene, 'photons');
    
% This displays the image in the GUI.  The displayFlag flag determines how
% imageSPD converts the data into a displayed image.  It is set from the
% GUI in the function displayShowImage.
axes(ha);
gam = 1;
rgb = imageSPD(img,wave,gam, [], [], displayFlag);
axis image; axis off

return;

