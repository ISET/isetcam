function rgb = sceneShowImage(scene,displayFlag,gam)
%Render an image of the scene data
%
%    rgb = sceneShowImage(scene,displayFlag,gam)
%
% Computes from scene spectral data to an sRGB rendering. Which type of
% rendering depends on the displayFlag.
%
% displayFlag:
%     absolute value of 0,1 compute RGB image 
%     absolute value of 2,  compute gray scale for IR
%     absolute value of 3,  HDR rendering method
%
%     If value is zero or negative, do not display, just render to rgb.
%
% gam:  The gamma value for the rendering
%
% Examples:
%   rgb = sceneShowImage(scene,-1);   % Compute, but don't show
%   sceneShowImage(scene,1);          % Show
%   sceneShowImage(scene)             % Same as above
%   im = sceneShowImage(scene,2);      % Same as above
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO:  Shouldn't we select the axes for rendering here?  There is only
% one axis in the scene and oi window. But if we ever go to more, this
% routine should  say which axis should be used for rendering.

if isempty(scene), cla; return;  end

if ieNotDefined('gam'),         gam = 1; end
if ieNotDefined('displayFlag'), displayFlag = 1; end

if checkfields(scene,'data','photons')
    % Don't duplicate the data.
    photons = scene.data.photons;
    wList   = sceneGet(scene,'wavelength');
    sz      = sceneGet(scene,'size');
else
    cla
    sprintf('ISET Warning:  Data are not available');
    return;
end
   
% This displays the image in the GUI.  The displayFlag flag determines how
% imageSPD converts the data into a displayed image.  It is set from the
% GUI in the function sceneShowImage.
rgb = imageSPD(photons,wList,gam,sz(1),sz(2),displayFlag);

return;

