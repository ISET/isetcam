function rgb = oiShowImage(oi,displayFlag,gam,oiW)
% Render an image of the oi data
%
%    rgb = oiShowImage(oi,displayFlag,gam,oiW)
%
% oi:   Optical image
% displayFlag: (see imageSPD; if value is 0 or negative, don't display)
%     = 0, +/- 1 compute RGB image 
%     = +/- 2,   compute gray scale for IR
%     = +/- 3,   use HDR method (hdrRender.m)
%     = +/- 4,   clip highlights (Set top 0.05 percent of pixels to max) 
% gam: Set display gamma parameter
%
% Examples:
%   oiShowImage(oi);       
%   img = oiShowImage(oi,0);   vcNewGraphWin; image(img)
%   img = oiShowImage(oi,2);
%   img = oiShowImage(oi,-2);  img = img/max(img(:)); vcNewGraphWin; imagesc(img);
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
if isempty(oi), cla; return;  end
if ieNotDefined('gam'), gam = 1; end
if ieNotDefined('displayFlag'), displayFlag = 1; end
if ieNotDefined('oiW'), oiW = []; end

if ~isempty(oiW)
    % Make sure it is selected
    figure(oiW.figure1);   
end

%% Don't duplicate the data
if checkfields(oi,'data','photons')
    photons = oi.data.photons;
    wList   = oiGet(oi,'wavelength');
    sz      = oiGet(oi,'size');
else 
    % Object exists, but no data.
    % cla(oiAxis);
    return;
end
    
% This displays the image in the GUI.  The displayFlag flag determines how
% imageSPD converts the data into a displayed image. The data in img are
% in RGB format.
%
% We should probably select the oi window here.
rgb = imageSPD(photons,wList,gam,sz(1),sz(2),-1*abs(displayFlag),[],[],oiW);

%% If displayFlag value is positive, display the rendered RGB. 

% If negative, we just return the RGB values.
if displayFlag >= 0
    if isempty(oiW)
        % Should be called imageAxis.  Not sure it is needed, really.
        ieNewGraphWin
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
