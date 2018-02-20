function rgb = oiShowImage(oi,displayFlag,gam)
%Render an image of the scene data
%
%    rgb = oiShowImage(oi,displayFlag,gam)
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

% TODO:  Shouldn't we select the axes for rendering here?  There is only
% one axis in the scene and oi window. But if we ever go to more, this
% routine should  say which axis should be used for rendering.

if isempty(oi), cla; return;  end

if ieNotDefined('gam'), gam = 1; end
if ieNotDefined('displayFlag'), displayFlag = 1; end

% Don't duplicate the data
if checkfields(oi,'data','photons')
    photons = oi.data.photons;
    wList   = oiGet(oi,'wavelength');
    sz      = oiGet(oi,'size');
else 
    cla
    % warning('Photon data are not available for this oi.');
    return;
end
    
% This displays the image in the GUI.  The displayFlag flag determines how
% imageSPD converts the data into a displayed image. The data in img are
% in RGB format.
% We should probably select the window here ... the oi window, that is.
rgb = imageSPD(photons,wList,gam,sz(1),sz(2),displayFlag);

return;

