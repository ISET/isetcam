function [oi,rect] = oiCrop(oi,rect)
%Crop the data in an optical image
%
%  [oi,rect] = oiCrop(oi,[rect])
%
% Crop the data (photons) in the scene or optical image to within the
% rectangle, rect. If rect is not defined a graphical routine is
% initiated for selecting the rectangle.  The values of rect can be
% returned.
%
% Because these are multispectral data, we can't use the usual imcrop.
% Instead, we use vcROISelect to return the selected data.  Then we turn
% the selected data into a photon image and reset the relevant parameters
% in the scene structure.
%
% Example:
%  newOI = oiCrop(vcGetObject('oi'));
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('oi'), error('You must define an optical image.'); end

if ieNotDefined('rect')
    [roiLocs,rect] = vcROISelect(oi); 
else
    cmin = rect(1); cmax = rect(1)+rect(3);
    rmin = rect(2); rmax = rect(2)+rect(4);
    [c,r] = meshgrid(cmin:cmax,rmin:rmax);
    roiLocs = [r(:),c(:)];
end

wAngular = oiGet(oi,'wangular');
sz = oiGet(oi,'size');
% wave = oiGet(oi,'nwave');

% The number of selected columns and rows
c = rect(3)+1; r = rect(4)+1;

% These are in XW format.
photons = vcGetROIData(oi,roiLocs,'photons');
photons = XW2RGBFormat(photons,r,c);

oi = oiClearData(oi);
oi = oiSet(oi,'photons',photons);
newSz = oiGet(oi,'size');
oi = oiSet(oi,'wangular',(newSz(2)/sz(2))*wAngular);

oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));

return;





