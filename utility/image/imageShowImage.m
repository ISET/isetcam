function img = imageShowImage(ip,gam,trueSizeFlag,app)
% Calculate and display the image from an image processor struct.
%
% Synopsis:
%  img = imageShowImage(ip, [gam],[trueSizeFlag],[app])
%
% Inputs
%  ip:             Image process structure
%  gam:            Gamma for the image display
%  trueSizeFlag:
%  app:   Either an ipWindow_App object
%         an existing Matlab ui figure, 
%         or 0.  
%
%         If 0, the rgb values are returned but not displayed.  If a figure
%         the data are shown in the figure.  If the ipWindow_App the data
%         are shown in app.ipImage axis.
%
% Output:
%  img:   sRGB image
%
% Description
%  The RGB data stored in the ip structure are displayed.  The display
%  procedure assumes the user has an sRGB display.
%
%  If scaling flag in the ip structure is set to true, then the srgb data
%  are conerted to lrgb, scaled to a max of 1, and then converted back to
%  srgb.
%
%  The srgb data are calculated using the display model stored in the ip.
%  We convert the processed RGB data into XYZ values for that display, and
%  then convert the XYZ values into sRGB values using xyz2srgb.  This is
%  why I say that we assume the user has an sRGB display.
%
%  If the render gamma is set in the window, we transform the sRGB data by
%  the gamma value.  Ordinarily, however, the gamma value is at 1 and the
%  xyz2srgb conversion manages the appropriate gamma conversion.
%
% Examples:
%   imageShowImage(vci{3},1/2.2)
%   imageShowImage(vci{3})
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

img = ipGet(ip,'result');

if isempty(img)
    % I don't think we get here much, or ever.
    cla; sprintf('There is no result image in vci.');
    return;
elseif max(img(:)) > ipGet(ip,'max sensor')
    % Checking for another bad condition in result
    if ~ipGet(ip,'scale display')
        warning('Image max (%.2f) exceeds volt swing (%.2f).\n', ...
            max(img(:)),ipGet(ip,'max sensor'));
        ip = ipSet(ip,'scale display',true);
    end
end

%% Convert the ip RGB data to XYZ and then sRGB

% The data to XYZ conversion uses the properties of the display
% stored in the image processor, ip.
img = xyz2srgb(imageDataXYZ(ip));

% Puzzled by this.  If it is srgb, how can it be anything but 3?
if   ismatrix(img),     ipType = 'monochrome';
elseif ndims(img) == 3, ipType = 'rgb';
else,                   ipType = 'multisensor';
end

switch ipType
    case 'monochrome'
        colormap(gray(256));
        if gam ~= 1, img = img.^(gam); end

    case 'rgb'
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
        
    otherwise
        error('No display method for %s.',ipType);
end

% Either show it in the app window or in a graph window
if isa(appAxis,'matlab.ui.control.UIAxes')
    % Show it in the window
    image(appAxis,img); 
    axis image; axis off;
elseif isequal(app,0)
    % Just return;
    return;
else
    figure(app);
    imshow(img); 
    axis image; axis off;
    if trueSizeFlag
        truesize;
    end
end


end
