function rgb = displayShowImage(thisD, displayFlag, varargin)
%Render an image of the display image data
%
% Synopsis
%   rgb = displayShowImage(thisD, [displayFlag], [varargin])
%
% Inputs
%
% Optional
%
% Outputs
%
%  
% Examples:
%   thisD   = displayCreate('LCD-Apple');
%   scene = sceneCreate; rgb = sceneGet(scene,'rgb');
%   thisD = displaySet(thisD,'rgb',rgb);
%
%   rgb = displayShowImage(thisD);
%   displayShowImage(thisD);
%   rgb = displayShowImage(thisD, 1, ha);
%
% (HJ) May, 2014

%% Get parameters

if isempty(thisD), cla; return;  end
if notDefined('displayFlag'), displayFlag = 1; end
if isempty(varargin), app = ieAppGet(thisD); end

%% Show the stored rgb image

% We convert the stored rgb image into a scene using the display
% characteristics.
rgb = displayGet(thisD,'rgb');
if ~isempty(rgb)
    scene = sceneFromFile(rgb, 'rgb', [], thisD);
    rgb   = sceneGet(scene, 'rgb');
    imshow(app.axisMain,rgb); axis image; axis off
end

end

