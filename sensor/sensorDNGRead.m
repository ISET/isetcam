function [sensorM, info] = sensorDNGRead(fname,varargin)
% Read a DNG file with the assumption that the sensor is a Sony IMX363
%
% Synopsis
%   sensorM = sensorDNGRead(fname,varargin)
%
% Brief
%   Adobe digital negative files (DNG) are close to the raw sensor values.
%   This function reads a DNG file and its header, assigning the image
%   values and other properties to an ISETCam sensor.
%
%   This function reads the orientation of the camera from the header file
%   and correctly interprets the CFA pattern.
%
%   This is an initial draft.  We will more parameters in the calling
%   arguments over time.
%
% Inputs
%  fname:  File name of the DNG file
%
% Optional key/val
%  full info:  Return the full header info, not the simple form
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

% Examples:
%{
   fname = 'MCC-centered.dng';
   [sensor, info] = sensorDNGRead(fname);
   rect = [774  1371  1615  1099];
   sensor = sensorCrop(sensor,rect);
   sensorWindow(sensor);
%}

%% Parse
varargin = ieParamFormat(varargin);
p = inputParser;

vFunc = @(x)(exist(x,'file'));
p.addRequired('fname',vFunc);
p.addParameter('fullinfo',false);

p.parse(fname,varargin{:});
fullInfo = p.Results.fullinfo;

%% Metadata
if fullInfo
    % All the header information
    [img, info] = ieDNGRead(fname);
else
    % Just a simplified header
    [img, info] = ieDNGRead(fname,'simple info',true);
end

%% Fix up the data

blackLevel = ceil(info.blackLevel(1));
exposureTime = info.exposureTime;  % I hope this is in seconds
img = ieClip(img,blackLevel,[]);   % sets the lower to blacklevel, no upper bound

% Stuff the measured raw data into a simulated sensor
sensorM = sensorCreate('IMX363');
sensorM = sensorSet(sensorM,'size',size(img));
sensorM = sensorSet(sensorM,'exp time',exposureTime);
sensorM = sensorSet(sensorM,'black level',blackLevel);
sensorM = sensorSet(sensorM,'name',fname);
sensorM = sensorSet(sensorM,'digital values',img);

% If we know how to use the isoSpeed to set the sensor gain, we would.  I
% think they should be used for analog gain and offset, along with black
% level. 

%% The Bayer pattern depends on the orientation.
switch info.orientation
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