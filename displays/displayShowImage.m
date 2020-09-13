function rgb = displayShowImage(d, displayFlag, varargin)
%Render an image of the display image data
%
%    rgb = displayShowImage(d, [displayFlag], [varargin])
%
% Examples:
%   d   = displayCreate('LCD-Apple');
%   scene = sceneCreate; rgb = sceneGet(scene,'rgb');
%   d = displaySet(d,'rgb',rgb);
%
%   rgb = displayShowImage(d);
%   displayShowImage(d);
%   rgb = displayShowImage(d, 1, ha);
%
% (HJ) May, 2014

if isempty(d), cla; return;  end
if notDefined('displayFlag'), displayFlag = 1; end
if ~isempty(varargin), thisAxis = varargin{1}; end

% Get parameters
wave = displayGet(d, 'wave');
%{
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
%}

% Compute photon image
rgb = displayGet(d,'rgb');
if ~isempty(rgb)
    scene = sceneFromFile(rgb, 'rgb', [], d);
    img   = sceneGet(scene, 'photons');
    
    % This displays the image in the main axis panels of the display
    % window.  The displayFlag flag determines how imageSPD converts the
    % data into a displayed image.
    axes(thisAxis);
    gam = 1;
    rgb = imageSPD(img,wave,gam, [], [], displayFlag);
    axis image; axis off
end

end

