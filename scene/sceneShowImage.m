function rgb = sceneShowImage(scene,renderFlag,gam,app)
% Render an image of the scene data from its SPD values
%
% Synopsis
%    rgb = sceneShowImage(scene,renderFlag,gam,app)
%
% Brief description
%  Computes from scene spectral data to an sRGB rendering. Which type of
%  rendering depends on the displayFlag.
%
% Inputs
%  scene:
%  renderFlag:
%     absolute value of 0,1 compute RGB image
%     absolute value of 2,  compute gray scale for IR
%     absolute value of 3,  HDR rendering method
%
%     If value is negative, do not display, just render the values
%     into the rgb variable that is returned.
%
%  gam:    The gamma value for the rendering
%  app:    sceneWindow_App class object, or a fig, or 0 (equiv to
%          renderFlag <= 0)
%
% Outputs
%   rgb:   Image for display
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   imageSPD, oiShowImage, imageShowImage

% Examples:
%{
   scene = sceneCreate; sceneWindow(scene);
   rgb = sceneShowImage(scene,-1);    % Compute, but don't show
   ieNewGraphWin; imagescRGB(rgb);    % Now show
%}
%{
   thisW = sceneWindow;
   sceneShowImage(scene,1,1,thisW);      % Show
%}
%{
   thisW = sceneWindow;
   im = sceneShowImage(scene,2,1,thisW); % Show gray scale version.
%}
%{
   im = sceneShowImage(scene,2,1);       % Create gray scale version.
%}

%%  Input parameters
if isempty(scene), cla; return;  end

if ~exist('gam','var') || isempty(gam),         gam = 1;         end
if ~exist('renderFlag','var') || isempty(renderFlag), renderFlag = 1; end
if ~exist('app','var') || isempty(app),      app = [];     end

if renderFlag > 0
    if isempty(app) || isa(app,'sceneWindow_App')
        % User told us nothing. We think the user wants it in the IP window
        [app,appAxis] = ieAppGet('scene');
    elseif isa(app,'matlab.ui.Figure')
        % Not sure why we are ever here.  Maybe the user had a pre-defined
        % window?
        appAxis = [];
    elseif isequal(app,0)
        % User sent in a 0. Just return the values and do not display.
        % Equivalent to displayFlag = false;
        appAxis = [];
    end
end

%%  Get the data
if checkfields(scene,'data','photons')
    % Don't duplicate the data.
    photons = sceneGet(scene,'photons');
    wList   = sceneGet(scene,'wavelength');
    sz      = sceneGet(scene,'size');
else
    cla(sceneAxis);
    warning('Data are not available');
    return;
end

%% Display the image in the GUI, or just compute the values

% The absolute value of the displayFlag flag determines how imageSPD
% converts the data into a displayed image.  It is determined from the GUI
% from the app.

% The displayFlag is always set to negative.  So imageSPD does not show the
% image.  Rather, we show it upon return here.
rgb = imageSPD(photons,wList,gam,sz(1),sz(2),-1*abs(renderFlag),[],[],app);

%% We could add back ROIs/overlays here, if desired.

if renderFlag > 0
    % Either show it in the app window or in a graph window
    if isa(appAxis,'matlab.ui.control.UIAxes')
        % This is the axis in the window
        image(appAxis,rgb); axis image; axis off;
        
    elseif isa(app,'matlab.ui.Figure')
        % This is a Matlab figure
        figure(app);
        if ~exist('xcoords', 'var') || ~exist('ycoords', 'var') || isempty(xcoords) || isempty(ycoords)
            imagescRGB(rgb); axis image; axis off
        else
            % User specified a grid overlay
            rgb = rgb/max(rgb(:));
            rgb = ieClip(rgb,0,[]);
            imagesc(xcoords,ycoords,rgb);
            axis image;   grid on;
            set(gca,'xcolor',[.5 .5 .5]);
            set(gca,'ycolor',[.5 .5 .5]);
        end
        
    elseif isequal(app,0)
        % Just return;
        return;
    end
    
end

end
