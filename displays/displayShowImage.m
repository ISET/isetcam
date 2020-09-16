function rgb = displayShowImage(thisD, varargin)
% Render an image of the display image data
%
% Synopsis
%   rgb = displayShowImage(thisD, [varargin])
%
% Inputs
%
% Optional
%   app:   Display window, either displayWindow_App or a matlab.ui.figure.
%
% Outputs
%   rgb:   The images
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
if isempty(varargin), app = ieAppGet(thisD);
else, app = varargin{1};
end

%% Show the stored rgb image

% We convert the stored rgb image into a scene using the display
% characteristics.
rgb = displayGet(thisD,'rgb');
if ~isempty(rgb)
    scene = sceneFromFile(rgb, 'rgb', [], thisD);
    rgb   = sceneGet(scene, 'rgb');
else
    scene = sceneCreate;
    rgb = sceneGet(scene,'rgb');
    thisD = displaySet(thisD,'rgb',rgb);
    ieReplaceObject(thisD);
end

switch class(app)
    case 'displayWindow_App'
        axis(app.displayImage);
        imshow(rgb); axis image; axis off
    case 'matlab.ui.figure'
        imshow(app,rgb); axis image; axis off
    otherwise
        error('Unknown type of display window %s\n',class(app));
end


end

