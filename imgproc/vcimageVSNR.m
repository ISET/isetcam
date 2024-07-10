function [vSNR,rect] = vcimageVSNR(ip,dpi,dist,rect)
% Calculate visual SNR in a uniform region of the vci
%
% Should be renamed ipVSNR
%
% Synopsis
%   [vSNR,rect] = vcimageVSNR(ip,[dpi],[dist],[rect])
%
% Brief
%   The visual SNR is the inverse of the standard deviation of the S-CIELAB
%   values in a uniform portion of an image.
%
% Input
%  ip   - Image process with a computed image
%  dist - Viewing distance of the display
%  rect - Rectangular region of interest
%
% Output
%   vSNR - Inverse of the st dev of the LAB values in the rect
%   rect - Rectangle in the ip display image
%
% Description
%  The typical PSNR is computed without reference to the eye or a display.
%  The vSNR computed here puts the image data into S-CIELAB space,
%  accounting for color and viewing distance.  The returned value, which is
%  expected to be calculated over a uniform region, is the inverse of the
%  standard deviation of the SCIELAB values in that region.
%
%  ieExamplesPrint('vcimageVSNR');
%
% See also
%   xyz2vSNR

% Example:
%{
 scene = sceneCreate('uniform ee',512); 
 oi = oiCompute(oiCreate,scene);
 sensor = sensorCreate; 
 sensor = sensorSet(sensor,'pixel size same fill factor',[1.4 1.4]*1e-6);
 sensor = sensorSet(sensor,'fov',5,oi);
 sensor = sensorSet(sensor,'noise flag',0);  % No noise, so vSNR is high
 sensor = sensorCompute(sensor,oi);
 ip = ipCompute(ipCreate,sensor);

 % Close, you can see the variation
 dpi = ipGet(ip,'display dpi');  % Relatively high sample
 rect = [18    13   215   174];
 dist = 0.20; % Seen at 18 inches
 [vSNR rect ] = vcimageVSNR(ip,dpi,dist,rect);
 assert(abs(vSNR - 37.74) < 0.1)
 % assert(abs(vSNR - 1.65) < 0.1)

 % Further away the SNR is much better
 dist = 2;  % Two meters
 vSNR = vcimageVSNR(ip,dpi,dist,rect);
 assert(abs(vSNR/36.13 - 1) < 0.1)
%}
%%
if ieNotDefined('ip'), ip = vcGetObject('vci'); end

% Dots per inch on the display and subject's viewing distance
if ieNotDefined('dpi'),  dpi  = ipGet(ip,'display DPI');   end
if ieNotDefined('dist'), dist = ipGet(ip,'display Viewing Distance'); end

% Select the ROI from the ipWindow_App
if ieNotDefined('rect')
    [roiLocs,roi] = ieROISelect(ip);
    rect = round(roi.Position);
else
    roiLocs = ieRect2Locs(rect);
end

% a = get(ipWindow,'CurrentAxes'); hold(a,'on'); ieDrawRect(a,rect)
% Convert the data to an XYZ image
roiXYZ = vcGetROIData(ip,roiLocs,'roixyz');          % Nx3

% Reshape into an image
c = rect(3)+1;r = rect(4)+1;
roiXYZ = XW2RGBFormat(roiXYZ,r,c);

% Set the SCIELAB parameters
whitePtXYZ = ipGet(ip,'display White XYZ');
p = scParams(dpi,dist);

% The filter shouldn't exceed the size of the image.
[r,c,~] = size(roiXYZ);
if r < p.sampPerDeg || c < p.sampPerDeg
    warning('Image size < 1 deg, may be a problem with filter size.')
    p.filterSize = min(r,c);
    % Maybe we should pad the image with the mean image around it?
end

% Call the main vSNR routine
vSNR = xyz2vSNR(roiXYZ,whitePtXYZ,p);

end

