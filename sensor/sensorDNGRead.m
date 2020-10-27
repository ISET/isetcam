function [sensorM, info] = sensorDNGRead(fname)
% Read a DNG file with the assumption that the sensor is a Sony IMX363
%
% Synopsis
%   sensorM = sensorDNGRead(fname)
%
% Brief
%   Adobe digital negative files (DNG) are close to the raw sensor values.
%   This function reads a DNG file and its header, assigning the image
%   values and other properties to an ISETCam sensor.
%
%   This is a scratch file.  We will add the opportunity to set more
%   parameters in the calling arguments over time.
%
% Inputs
%  fname:  File name of the DNG file
%
% Outputs
%  sensorM:  An ISETCam sensor containing the DNG data in the digital
%            values slot.
%  info:     The header information from the DNG file.  This includes a lot
%            of data about isoSpeed, exposure duration, and other stuff.
%
% See Also
%  sensorCreate
%

% Metadata
if ~exist(fname,'file')
    error('No file found %s\n',fname);
else
    img          = dcrawRead(fname);
    info         = imfinfo(fname);
    if checkfields(info,'DigitalCamera')
        % For camera app files
        isoSpeed     = info.DigitalCamera.ISOSpeedRatings;
        exposureTime = info.DigitalCamera.ExposureTime;
        blackLevel   = info.SubIFDs{1}.BlackLevel;
    else
        % For openCam files
        isoSpeed     = info.ISOSpeedRatings;
        exposureTime = info.ExposureTime;
        blackLevel   = info.BlackLevel;
    end
end

blackLevel = ceil(blackLevel(1));
img = ieClip(img,blackLevel,[]);   % sets the lower to blacklevel, no upper bound

% Stuff the measured raw data into a simulated sensor
sensorM = sensorCreate('IMX363');
sensorM = sensorSet(sensorM,'size',size(img));
sensorM = sensorSet(sensorM,'exp time',exposureTime);
sensorM = sensorSet(sensorM,'black level',blackLevel);
sensorM = sensorSet(sensorM,'name',fname);
sensorM = sensorSet(sensorM,'digital values',img);

% If we know how to use the isoSpeed to set the sensor gain, we would
%

%% The Bayer pattern depends on the orientation.
switch info.Orientation
    case 1
        % Counter clockwise 90 deg
        % R G
        % G B
        sensorM = sensorSet(sensorM,'pattern',[1 2; 2 3]);
    case 3
        % Clockwise 90 deg
        % B G
        % G R
        sensorM = sensorSet(sensorM,'pattern',[3 2; 2 1]);
    case 6
        % Upright
        % G R
        % B G
        sensorM = sensorSet(sensorM,'pattern',[2 1; 3 2]);
    case 8
        % Inverted
        % G B
        % R G
        sensorM = sensorSet(sensorM,'pattern',[2 3; 1 2]);
    otherwise
        error('Unknown Orientation value');
end

end