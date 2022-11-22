function rgb = imageSPD(spd,wList,gam,row,col,displayFlag,xcoords,ycoords,thisW)
% Derive an RGB image from an SPD (photons) data
%
%     RGB = imageSPD(spd,[wList],[gam],[row],[col],[displayFlag=1],[xcoords],[ycoords],[thisW])
%
% Brief description
%
%  The RGB image represents the appearance of the spectral power
%  distribution (spd) data.  The input spd data should be in RGB format.
%
% wList: the sample wavelengths of the SPD
%           (default depends on the number of wavelength samples)
% gam:   is the display gamma  (default = 1)
% row,col:  The image size (needed when the data are in XW format)
%
% displayFlag: (if value is 0 or negative, don't display)
%     = 0, +/- 1 compute RGB image
%     = +/- 2,   compute gray scale for IR
%     = +/- 3,   use HDR method (hdrRender.m)
%     = +/- 4,   clip highlights (Set top 0.05 percent of pixels to max)
%
%  xcoords, ycoords: Spatial coords of the image points, to be shown as
%                    image grid
%
%  thisW:  The window_App object.  sceneW.sceneImage or oiW.oiImage is the
%          display axis.
%
% Description:
%  In the typical method, the RGB image is created by converting the image
%  SPD (photons) to XYZ, and then converting the XYZ to sRGB format
%  (xyz2srgb). The conversion to XYZ is managed so that the largest XYZ
%  value is 1.
%
%  The routine can also be used to return the sRGB values without displaying
%  the data. All the conditions with displayFlag < 0 just compute, don't
%  display.
%
%  The image can be displayed with a spatial sampling grid overlaid to
%  indicate the position on the optical image or sensor surface.
%
% Copyright ImagEval Consultants, LLC, 2005.
%
% See also
%   sceneShowImage, oiShowImage

% Examples:
%   imageSPD(spdData,[], 0.5,[],[],1);   % spdData is [r,c,w]
%   imageSPD(spdData,[], 0.6,128,128);   % spdData is [128*128,w]
%   rgb = imageSPD(spdData,[], 0.5,[],[],0);  % rgb is calculated, but not displayed
%

%%
if ~exist('gam','var')||isempty(gam), gam = 1; end
if ~exist('displayFlag','var')||isempty(displayFlag), displayFlag = 1; end

if ~exist('wList','var')||isempty(wList)
    w = size(spd,3);
    if     w == 31,  wList = (400:10:700);
    elseif w == 301, wList = (400:1:700);
    elseif w == 37,  wList = (370:10:730);
    else
        wList = sceneGet(vcGetObject('scene'),'wave');
        if length(wList) ~= w
            errordlg('Problem interpreting imageSPD wavelength list.');
            return;
        end
    end
end

%% Parse the display flag
method = abs(displayFlag);

% Convert the SPD data to a visible range image
if isequal(method,0) || isequal(method,1)
    
    XYZ = ieXYZFromPhotons(spd,wList);
    
    % We are considering getting rid of this normalization.  The user
    % may want to set the relative intensity, so that two scenes with
    % different levels show up as lighter or darker RGB images as
    % well.  By including this, we force all the images to be
    % normalized so tha the brightest point is the same.
    XYZ = XYZ/max(XYZ(:));
    rgb = xyz2srgb(XYZ);
    
   
elseif method == 2    % Gray scale image, used for SWIR, NIR
    
    rgb = zeros(row,col,3);
    rgb(:,:,1) = reshape(mean(spd,3),row,col);
    rgb(:,:,2) = rgb(:,:,1);
    rgb(:,:,3) = rgb(:,:,1);
    
    % We need to scale only for this case.  The othercases handle in their
    % own way.
    rgb = ieScale(rgb,1);
    
elseif method == 3   % HDR display method
    
    XYZ = ieXYZFromPhotons(spd,wList);
    XYZ = XYZ/max(XYZ(:));
    rgb = xyz2srgb(XYZ);
    rgb = hdrRender(rgb);
    
elseif method == 4  % Clip the highlights but use HDR method
    XYZ = ieXYZFromPhotons(spd,wList);
    
    % Find a reasonable place to clip the highlights
    Y = XYZ(:,:,2);
    yClip = prctile(Y(:),99.5);  % We should parameterize this
    %vcNewGraphWin; histogram(Y(:),100);
    
    % Clip the XYZ data so that nothing is bigger than yClip
    XYZ = ieClip(XYZ,0,yClip);
    XYZ = XYZ/max(XYZ(:));   % Scale for rendering in XYZ and then sRGB
    
    rgb = xyz2srgb(XYZ);
    rgb = hdrRender(rgb);
    
else
    error('Unknown display flag value: %d\n',displayFlag);
end

%% Deal with gamma
    
% Person asked for a different gamma than the usual sRGB, so give it
% to them
if ~isequal(gam,1), rgb = rgb.^gam; end

% oiShowImage and sceneShowImage always sets the displayFlag to negative.
% So in that main usage, we never show here.  Instead we show there.
%
% In other cases imageSPD is called directly, not through sceneShowImage.
% In those cases we show the data if the displayFlag sign is positive. If
% displayFlag is negative, imageSPD just returns the rgb values.
if ~exist('thisW','var')||isempty(thisW), thisW = []; end
if displayFlag >= 0
    
    % Make sure the figure is selected and axis is cleared.
    switch class(thisW)
        case 'oiWindow_App'
            figure(thisW.figure1);
            cla(thisW.oiImage);  % Should be called imageAxis
        case 'sceneWindow_App'
            figure(thisW.figure1);
            cla(thisW.sceneImage);  % Should be called imageAxis
        case 'matlab.ui.Figure'
            % There is a figure waiting
            % Perhaps figure(thisW) should be invoked?
        case 'double'
            % Not sure why this is here.
            ieNewGraphWin;
            % cla(thisFig);
    end
    
    if ieNotDefined('xcoords') || ieNotDefined('ycoords')
        imagescRGB(rgb); axis image; axis off
    else
        % User specified a grid overlay
        rgb = rgb/max(rgb(:));
        rgb = ieClip(rgb,0,[]);
        imagesc(xcoords,ycoords,rgb);
        axis image; grid on;
        set(gca,'xcolor',[.5 .5 .5]);
        set(gca,'ycolor',[.5 .5 .5]);
    end
end

end
