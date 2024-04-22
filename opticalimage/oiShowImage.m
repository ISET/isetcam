function rgb = oiShowImage(oi,renderFlag,gam,oiW,titleString)
% Render an image of the oi data
%
% Synopsis
%    rgb = oiShowImage(oi,renderFlag,gam,oiW)
%
% Inputs
%  oi:   Optical image
%  renderFlag: (see imageSPD; if value is 0 or negative, don't display)
%     = 0, +/- 1 compute RGB image
%     = +/- 2,   compute gray scale for IR
%     = +/- 3,   use HDR method (hdrRender.m)
%     = +/- 4,   clip highlights (Set top 0.05 percent of pixels to max)
%     = -5,      clip Highlights aggresively -- 5% (sb parameter instead)
%  gam: Set display gamma parameter
%
% Examples:
%   oiShowImage(oi);
%   img = oiShowImage(oi,0);   vcNewGraphWin; image(img)
%   img = oiShowImage(oi,2);
%   img = oiShowImage(oi,-2);  img = img/max(img(:)); vcNewGraphWin; imagesc(img);
%
% See also
%  sceneShowImage

%%
if ~exist('oi','var') || isempty(oi) || ~checkfields(oi,'data'), cla; return;  end
if ~exist('gam','var') || isempty(gam), gam = 1; end
if ~exist('displayFlag','var'), renderFlag = 1; end
if ~exist('oiW','var'), oiW = []; end
if ~exist('titleString','var'), titleString = 'OI Display'; end

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
rgb = imageSPD(photons,wList,gam,sz(1),sz(2),-1*abs(renderFlag),[],[],oiW);

%% If displayFlag value is positive, display the rendered RGB.

% If negative, we just return the RGB values.
if renderFlag >= 0
    if isempty(oiW)
        % Should be called imageAxis.  Not sure it is needed, really.
        ieNewGraphWin('','',titleString);
    end
    if ~exist('xcoords','var') || ~exist('ycoords','var') ...
            || isempty(xcoords) || isempty(ycoords)
        imagescRGB(rgb); axis off
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
