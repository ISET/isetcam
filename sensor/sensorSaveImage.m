function fullName = sensorSaveImage(sensor,fullName,dataType,gam,scaleMax)
%Save out an RGB image of the sensor image as a png file.
%
%  fullName = sensorSaveImage(isa,fullName,dataType,gam,scaleMax);
%
% If the fullName is not passed in, then the user is queried to select the
% fullpath name of the output file.
%
%Example:
%  sensorSaveImage(sensor,fullpathname);
%
% See also: sensorData2Image, sensorGet(sensor,'rgb')
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('isa'), sensor = ieGetObject('sensor'); end
if ieNotDefined('dataType'), dataType = 'volts'; end
if ieNotDefined('gam'), gam = 1; end
if ieNotDefined('scaleMax'), scaleMax = 1; end

if ieNotDefined('fullName')
    fullName = vcSelectDataFile('session','w');
    if isempty(fullName), return;
    else
        [pathstr,name,~] = fileparts(fullName);
    end
    fullName = fullfile(pathstr,[name '.png']);
end

% These are the displayed sensor data as an RGB image.
img = sensorData2Image(sensor,dataType,gam,scaleMax);

% For internal display in Matlab, the img values range up to 255.  The
% imwrite requires doubles between [0,1].  Or uint8 between 0 and 255.
% We scale to 0,1.  This loses the absolute voltage level which must be
% recovered on the read side.
img = img/max(img(:));
imwrite(img,fullName,'png');

end
