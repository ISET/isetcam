function RGB = imageSPD(SPD,wList,gam,row,col,displayFlag,xcoords,ycoords)
% Derive an RGB image from an SPD (photons) data
%
%     RGB = imageSPD(SPD,[wList],[gam],[row],[col],[displayFlag=1],[x coords],[y coords])
%
% The RGB image represents the appearance of the spectral power
% distribution (spd) data.  The input spd data should be in RGB format.
%
% In the typical method, the RGB image is created by converting the image
% SPD (photons) to XYZ, and then converting the XYZ to sRGB format
% (xyz2srgb). The conversion to XYZ is managed so that the largest XYZ
% value is 1.
%
% The routine can also be used to return the sRGB values without displaying
% the data. All the conditions with displayFlag < 0 just compute, don't
% display.
%
% The image can be displayed with a spatial sampling grid overlaid to
% indicate the position on the optical image or sensor surface.
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
%  x and y:  Coords (spatial positions) of the image points, to be shown as
%            image grid
%
% Examples:
%   imageSPD(spdData,[], 0.5,[],[],1);   % spdData is [r,c,w]
%   imageSPD(spdData,[], 0.6,128,128);   % spdData is [128*128,w]              
%   rgb = imageSPD(spdData,[], 0.5,[],[],0);  % rgb is calculated, but not displayed
%
% Copyright ImagEval Consultants, LLC, 2005.

%%
if ieNotDefined('gam'), gam = 1; end
if ieNotDefined('displayFlag'), displayFlag = 1; end

if ieNotDefined('wList')
    w = size(SPD,3);
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
show = false;
if displayFlag > 0, show = true; end
    
% Convert the SPD data to a visible range image
if isequal(method,0) || isequal(method,1)
    
    XYZ = ieXYZFromPhotons(SPD,wList);
    
    % We are considering getting rid of this normalization.  The user
    % may want to set the relative intensity, so that two scenes with
    % different levels show up as lighter or darker RGB images as
    % well.  By including this, we force all the images to be
    % normalized so tha the brightest point is the same.
    XYZ = XYZ/max(XYZ(:));
    RGB = xyz2srgb(XYZ);
    
    % Person asked for a different gamma, so give it to them
    if ~isequal(gam,1), RGB = RGB.^gam; end

elseif method == 2    % Gray scale image, used for SWIR, NIR
    
    RGB = zeros(row,col,3);
    RGB(:,:,1) = reshape(mean(SPD,3),row,col);
    RGB(:,:,2) = RGB(:,:,1);
    RGB(:,:,3) = RGB(:,:,1);
    
    % We need to scale only for this case.  The othercases handle in their
    % own way.
    RGB = ieScale(RGB,1);

elseif method == 3   % HDR display method
    
    XYZ = ieXYZFromPhotons(SPD,wList);
    XYZ = XYZ/max(XYZ(:));
    RGB = xyz2srgb(XYZ);
    RGB = hdrRender(RGB);

elseif method == 4  % Clip the highlights (NYI)
    XYZ = ieXYZFromPhotons(SPD,wList);
    
    % Find a reasonable place to clip the highlights
    Y = XYZ(:,:,2);
    yClip = prctile(Y(:),99.5);  % We should parameterize this
    %vcNewGraphWin; hist(Y(:),100);
    
    % Clip the XYZ data so that nothing is bigger than yClip
    XYZ = ieClip(XYZ,0,yClip);
    XYZ = XYZ/max(XYZ(:));   % Scale for rendering in XYZ and then sRGB
    
    RGB = xyz2srgb(XYZ);
    RGB = hdrRender(RGB);
    
else
    error('Unknown display flag value: %d\n',displayFlag);
end

%% Deal with gamma
if ~isequal(gam,1), RGB = RGB.^gam; end

% If value is positive, display the rendered RGB. If negative, we just
% return the RGB values.
if show
    if ieNotDefined('xcoords') || ieNotDefined('ycoords')
        imagescRGB(RGB); axis image; axis off
    else
        % User specified a grid overlay
        RGB = RGB/max(RGB(:));
        RGB = ieClip(RGB,0,[]);
        imagesc(xcoords,ycoords,RGB);
        axis image; grid on;
        set(gca,'xcolor',[.5 .5 .5]);
        set(gca,'ycolor',[.5 .5 .5]);
    end    
end

end