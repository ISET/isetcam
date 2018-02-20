function [vSNR,rect] = vcimageVSNR(vci,dpi,dist,rect)
% Calculate visual SNR in a uniform region of the vci
%
%   [vSNR,rect] = vcimageVSNR(vci,[dpi],[dist],[rect])
%
% The visual SNR is the inverse of the standard deviation of the S-CIELAB
% values in a uniform portion of an image.
%
% Example
%    vSNR = vcimageVSNR
%
%    vci = vcGetObject('vci');
%    dpi = 100;  % Relatively high sample
%    dist = 0.20; % Seen at 18 inches
%    vSNR = vcimageVSNR(vci,dpi,dist);
%
%    vSNR = vcimageVSNR;
%
% Copyright ImagEval Consultants, LLC, 2009

if ieNotDefined('vci'), vci = vcGetObject('vci'); end

% Dots per inch on the display and subject's viewing distance 
if ieNotDefined('dpi'),  dpi  = ipGet(vci,'displayDPI');   end
if ieNotDefined('dist'), dist = ipGet(vci,'displayViewingDistance'); end

% Select the ROI from the vcimage window
if ieNotDefined('rect'),    [roiLocs,rect] = vcROISelect(vci);
else                        roiLocs = ieRoi2Locs(rect);
end
% a = get(ipWindow,'CurrentAxes'); hold(a,'on'); ieDrawRect(a,rect)
% Convert the data to an XYZ image
roiXYZ = vcGetROIData(vci,roiLocs,'roixyz');          % Nx3

% Reshape into an image
c = rect(3)+1;r = rect(4)+1;
roiXYZ = XW2RGBFormat(roiXYZ,r,c);
% figure(1); Y = roiXYZ(:,:,2); mesh(Y); colormap(jet(255)); mean(Y(:))
% srgb = xyz2srgb(roiXYZ); imagesc(srgb/255);

% Set the SCIELAB parameters
whitePtXYZ = ipGet(vci,'display White XYZ');
p = scParams(dpi,dist);

% The filter shouldn't exceed the size of the image.
[r,c,w] = size(roiXYZ);
if r < p.sampPerDeg || c < p.sampPerDeg
    warning('Image size < 1 deg, may be a problem with filter size.')
    p.filterSize = min(r,c);
    % Maybe we should pad the image with the mean image around it?
end

% Call the main vSNR routine
vSNR = xyz2vSNR(roiXYZ,whitePtXYZ,p);

return

