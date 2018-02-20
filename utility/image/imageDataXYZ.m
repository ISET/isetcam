function dataXYZ = imageDataXYZ(ip,roiLocs)
%Return the XYZ values of  display data 
%
%    dataXYZ = imageDataXYZ(ip,[roiLocs])
%
% The linear primary data are contained in the result field of
% the image processing (ip) structure.  The XYZ of those RGB
% values are computed by multiplying the monitor SPD (in energy)
% with these linear RGB values of the display.
%
% Typically, the entire image is returned in RGB (r,c,w)-format .
%
% IF roiLocs are passed in, the data are returned in XW format, with
% one spatial position (X dimension) for each roiLoc.
%
% Example:
%   [val,vci] = vcGetSelectedObject('VCIMAGE');
%   xyzRGB = imageDataXYZ(vci);
%      
%   roiLocs = vcROISelect(vci);
%   xyzXW   = imageDataXYZ(vci,roiLocs);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('roiLocs')
    % Get the rgb data.  The result field contains linear RGB format for
    % the display.
    data = ipGet(ip,'result');
        
    % Transform
    [data,r,c] = RGB2XWFormat(data);
    dataXYZ    = imageRGB2XYZ(ip,data);
    dataXYZ    = XW2RGBFormat(dataXYZ,r,c);
else
    % The data are returned in XW format    
    data = vcGetROIData(ip,roiLocs,'result');
    dataXYZ = imageRGB2XYZ(ip,data);
end

return;
