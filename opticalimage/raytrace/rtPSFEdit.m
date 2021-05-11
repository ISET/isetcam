function optics = rtPSFEdit(optics, cntr, rot, visualizeFlag)
%Adjust PSF data so that it is rotated and or made center on the grid
%
%  optics = rtPSFEdit(optics,centerFlag,rot90Deg,visualizeFlag);
%
% If rot90Deg is used as an argument to rot90.
% If 1, the psf is rotated 90 degrees CCW.
% If rot is false (0), there is no rotation.
%
% If cntr is true, the psf is centered on the sampling grid using
%
%    psf = (psf + flipud(psf))/2;
%    psf = (psf + fliplr(psf))/2;
%
% This operation blurs the psf, too.  Other operations could be used, instead.  But,
% I think this is no longer needed or used.
%
% If visualizeFlag is true (> 0), then the PSFs are plotted in a window
% with the number visualizeFlag;
%
% Example:
%  vcImportObject('OPTICS');
%  optics = vcGetObject('optics');
%  rtPSFVisualize(optics);
%  optics = rtPSFEdit(optics,0,1,2);
%  vcExportObject(optics);
%
% Copyright ImagEval, LLC, 2005

if ieNotDefined('optics'), oi = vcGetObject('oi');
    optics = oiGet(oi, 'optics');
end
if ieNotDefined('visualizeFlag'), visualizeFlag = 0; end
if ieNotDefined('rot'), rot = 0; end
if ieNotDefined('cntr'), cntr = 0; end

psf = opticsGet(optics, 'rtpsfdata');

fprintf('cntr %.0f, rot %.0f\n', cntr, rot);

[r, c, h, w] = size(psf);
for ii = 1:h
    for jj = 1:w
        tmp = psf(:, :, ii, jj);
        if cntr
            tmp = 0.5 * (tmp + flipud(tmp));
            tmp = 0.5 * (tmp + fliplr(tmp));
        end
        if rot
            tmp = rot90(tmp, rot);
        end
        psf(:, :, ii, jj) = tmp;
    end
end

optics = opticsSet(optics, 'rtpsfdata', psf);

if visualizeFlag, rtPSFVisualize(optics, visualizeFlag); end

return;
