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
%     If value is zero or negative, do not display, just render the values
%     into the rgb variable that is returned.
%
% gam:  The gamma value for the rendering
%
% Copyright ImagEval Consultants, LLC, 2003.

% Examples:
%{
   scene = sceneCreate; sceneWindow(scene);
   rgb = sceneShowImage(scene,-1);    % Compute, but don't show
   pause(1);
   sceneShowImage(scene,1);           % Show
   pause(1);
   im = sceneShowImage(scene,2);      % Show gray scale version.
%}

%%  Input parameters
if isempty(scene), cla; return;  end

if ieNotDefined('gam'),         gam = 1; end
if ieNotDefined('displayFlag'), displayFlag = 1; end

try
    % If this is to a sceneWindow, get the axis.
    sceneAxis = ieSessionGet('scene axis');
catch
    % If there is no sceneWindow, set this to empty
    sceneAxis = [];
end

%%  Get the data
if checkfields(scene,'data','photons')
    % Don't duplicate the data.
    photons = scene.data.photons;
    wList   = sceneGet(scene,'wavelength');
    sz      = sceneGet(scene,'size');
else
    cla(sceneAxis);
    sprintf('ISET Warning:  Data are not available');
    return;
end
   
%% Display the image in the GUI, or just compute the values

% The absolute value of the displayFlag flag determines how imageSPD
% converts the data into a displayed image.  It is determined from the GUI.

% Clearing the axis eliminates any ROI overlays
cla(sceneAxis);
rgb = imageSPD(photons,wList,gam,sz(1),sz(2),displayFlag);

%% We could add back ROIs/overlays here, if desired.

end
