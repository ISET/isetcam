function rtPSFVisualize(optics,figNum,delay)
%Show a movie of the ray trace pointspread functions at all heights and wavelengths
%
%   rtPSFVisualize([optics],[figNum=1],[delay = 0.2])
% 
% The image height increase along the x-axis.  The data are displayed for
% one wavelength first, and then the next wavelength. The horizontal axis 
% indicates the image height in microns.
%
% Example:
%   oi = vcGetObject('oi'); optics = oiGet(oi,'optics');
%   rtPSFVisualize(optics,1)
%
% This example loads, visualizes, rotates, and visualizes again.
%
%   vcImportObject('OPTICS'); rtPSFVisualize([],1);
%   optics = vcGetObject('optics'); optics = rtPSFEdit(optics,0,1,2);
%
% Copyright ImagEval, LLC, 2005

if ieNotDefined('optics'), optics = vcGetObject('optics'); end
if ieNotDefined('figNum'), figNum = 1; end
if ieNotDefined('delay'), delay = 0.2; end

% Not using GraphWin here.  Not sure why.
figure(figNum); clf;
name = opticsGet(optics,'rtname');
set(figNum,'number','off');
set(figNum,'name',sprintf('%s: PSF movie',name));
colormap(gray(256));

wave   = opticsGet(optics,'rtpsfwavelength');
imgHgt = opticsGet(optics,'rtpsffieldheight','um');
psf    = opticsGet(optics,'rtpsfdata');

for jj=1:length(wave)
    for ii=1:length(imgHgt) 
        imagesc(squeeze(psf(:,:,ii,jj))); 
        set(gca,'xticklabel',round([0:16:128] - 64 +imgHgt(ii)),...
            'xtick',[0:16:128],'ytick',[0:16:128]); 
        grid on; axis image
        title(sprintf('Wave %.0f nm',wave(jj)));
        pause(delay);
    end
end

return;