function img = imageShowImage(ip,gam,trueSizeFlag,fig)
% Display the image in the processor window.
%
%  img = imageShowImage(ip, [gam],[trueSizeFlag],[figNum])
%
% The RGB data stored in the ip structure are displayed.  The
% display procedure assumes the user has an sRGB display.  
%
% If scaling flag in the ip structure is set to true, then the
% srgb data are conerted to lrgb, scaled to a max of 1, and then
% converted back to srgb.
%
% The srgb data are calculated using the display model stored in
% the ip. We convert the processed RGB data into XYZ values for
% that display, and then convert the XYZ values into sRGB values
% using xyz2srgb.  This is why I say that we assume the user has
% an sRGB display.
%
% If the render gamma is set in the window, we transform the sRGB
% data by the gamma value.  Ordinarily, however, the gamma value
% is at 1 and the xyz2srgb conversion manages the appropriate
% gamma conversion.
%
% Examples:
%   imageShowImage(vci{3},1/2.2)
%   imageShowImage(vci{3})
%
% See also: xyz2srgb, lrgb2srgb, srgb2lrgb, imageDataXYZ, ipGet
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('ip'), cla; return;  end
if ieNotDefined('gam'),  gam = 1; end
if ieNotDefined('trueSizeFlag'), trueSizeFlag = 0; end
if ieNotDefined('fig'),  fig = ieSessionGet('ip window'); end

% Bring up the figure.  If figNum is false (0), we don't plot
if ~isequal(fig,0)
    if isempty(fig), vcNewGraphWin;
    else, figure(fig); 
    end
end

% Test and then convert the linear RGB values stored in result to XYZ.  I
% don't think we get here much, or ever.
img = ipGet(ip,'result');
if isempty(img)
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

% Convert the ip RGB data to XYZ and then sRGB
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
        if fig, imagesc(img); axis image; axis off;
            if trueSizeFlag, truesize; end    
        end
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
        else
            % No scaling. 
        end
        
        % There may be some negative numbers or numbers
        % > 1 because of processing noise and saturation + noise.
        img = ieClip(img,0,1);
        
        % This is the gamma the user asks for on the ISET window
        % Normally it is 1 because the display data are already
        % in sRGB mode.
        if gam ~=1, img = img.^gam; end
        
        % Maybe this has to do with Matlab 2014b?  Or maybe just testing
        % for a false figure number?
        if ~isequal(fig,0) 
            image(img); axis image; axis off;
            if trueSizeFlag
                truesize;
                set(fig,'name',sprintf('ip:%s gam: %.2f',ipGet(ip,'name'),gam));
            end
        end
        
    otherwise
        error('No display method for %s.',ipType);
end

end
