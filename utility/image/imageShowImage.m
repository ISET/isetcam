function img = imageShowImage(ip,gam,trueSizeFlag,app)
% Calculate and display the image from an image processor struct.
%
% Synopsis:
%  img = imageShowImage(ip, [gam],[trueSizeFlag],[app])
%
% Brief
%  Calculates and display an image in a window. Typically used for
%  displaying in ipWindow. If app is 0, just returns the image.
%
% Inputs
%  ip:             Image process structure
%  gam:            Gamma for the image display
%  trueSizeFlag:   Logical
%  app:  
%     If 0, the rgb values are returned but not displayed.  
%     If a figure the data are shown in the figure.  
%     If the ipWindow_App the data are shown in app.ipImage axis.
%
% Output:
%  img:   sRGB image to display in the window
%
% Description
%  The RGB data stored in the ip 'result' slot are linear RGB values with
%  respect to the display model.  They can be accessed using the call
%  ipGet(ip,'display linear rgb')
%
% Render Flag:  Standard RGB
%  This function renders the data in the ipWindow by converting those data
%  into sRGB values.  That is, we assume the user has an sRGB display.
%
%  The data are calculated using the display model stored in the ip.
%  We convert the processed RGB data into XYZ values for that display, and
%  then convert the XYZ values into sRGB values using xyz2srgb.  This is
%  why I say that we assume the user has an sRGB display.
%
%  If the render gamma is set in the window, we further transform the sRGB
%  data by the gamma value.  Ordinarily, however, the gamma value is at 1
%  and the xyz2srgb conversion manages the appropriate gamma conversion.
%
%  ** I think this might be obsolete.  Not sure **
%  If scaling flag in the ip structure is set to true, then the srgb data
%  are converted to lrgb, scaled to a max of 1, and then converted back to
%  srgb.
%
% Render Flag:  HDR
% Render Flag:  Gray scale
% Render Flag:  Clip highlights
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also:
%   xyz2srgb, lrgb2srgb, srgb2lrgb, imageDataXYZ, ipGet
%

%% Figure out what the user wants

if ieNotDefined('ip'), cla; return;  end
if ieNotDefined('trueSizeFlag'), trueSizeFlag = 0; end
if ieNotDefined('app')
    % User told us nothing. We think the user wants it in the IP window
    [app,appAxis] = ieAppGet('ip');
elseif isa(app,'ipWindow_App')
    % In this case, they gave us the app window
    appAxis = app.ipImage;
elseif isa(app,'matlab.ui.Figure')
    % Not sure why we are ever here.  Maybe the user had a pre-defined
    % window?
    appAxis = [];
elseif isequal(app,0)
    % User sent in a 0. Just return the values and do not show anywhere.
    appAxis = [];
end

if ieNotDefined('gam'), gam = ipGet(ip,'gamma'); end

%% Test and then convert the linear RGB values stored in result to XYZ.

img = ipGet(ip,'linear display rgb');

if isempty(img)
    % I don't think we get here much, or ever.
    cla; sprintf('There is no image in the ip result slot.');
    return;
end

%% Convert the ip RGB data to XYZ and then sRGB

% imageDataXYZ uses the properties of the display stored in the image
% processor and the values in ip.data.result (also called the 'linear
% display rgb'. 
img = xyz2srgb(imageDataXYZ(ip));

renderFlag = ipGet(ip,'render flag');

switch renderFlag
    case {1,'rgb'}
        % Set the largest srgb to 1.
        %
        % We  do this by converting srgb to lrgb, then scaling to 1, then
        % putting back to srgb.
        if ipGet(ip,'scaleDisplay')
            img = srgb2lrgb(img);
            mxImage = max(img(:));
            img = img/mxImage;
            img = lrgb2srgb(img);
        end
        
        % There may be some negative numbers or numbers
        % > 1 because of processing noise and saturation + noise.
        img = ieClip(img,0,1);
        
        % This is the gamma the user asks for on the ISET window
        % Normally it is 1 because the display data are already
        % in sRGB mode.
        if gam ~=1, img = img.^gam; end

    case {2,'hdr'}
        % Unusual to use HDR in the ipWindow, but ...
        img = hdrRender(img);
        if gam ~=1, img = img.^gam; end

    case {3,'gray','monochrome'}
        tmp = mean(img,3);
        % Maybe a better way to do this?
        for ii=1:3
            img(:,:,ii) = tmp;
        end
        if gam ~=1, img = img.^gam; end

    otherwise
        error('No display method for %s.',ipType);
end

% Either show it in the app window or in a graph window
if isa(appAxis,'matlab.ui.control.UIAxes')    
    axes(appAxis);  % Select the axis
    image(appAxis,img); 
    axis image; axis off;
elseif isequal(app,0)
    % Just return;
    return;
elseif isa(app,'matlab.ui.Figure')
    figure(app);
    image(img); axis image; axis off;
    if trueSizeFlag
        truesize;
    end
end

end
