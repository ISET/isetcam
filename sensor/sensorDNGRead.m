function [sensor, info] = sensorDNGRead(fname,varargin)
% Read a DNG file with the assumption that the sensor is a Sony IMX363
%
% Synopsis
%   sensor = sensorDNGRead(fname,varargin)
%
% Brief
%   Adobe digital negative files (DNG) are close to the raw sensor values.
%   This function reads a DNG file and its header, assigning the image
%   values and other properties to an ISETCam sensor.
%
%   The orientation of the camera is read from the header file and
%   uses that orientation to adjust the CFA pattern (which varies with
%   camera orientation).
%
%   Different camera apps return different formats for the header.  
%
% Inputs
%  fname:  File name of the DNG file
%
% Optional key/val
%  'full info' Returns the full header info by default.  If this is false,
%              the ISET standardized and simpler (reduced) info is
%              returned.
%  crop:       Crop the returned image
%              The crop parameter can be a Rectangle returned by
%              ieROISelect, or a [row,col,height,width] vector
%              (Rectangle.Position), or a number between 0 and 1 for how
%              much of the central portion of the image to return.
% Outputs
%  sensor:   An ISETCam sensor containing the DNG data in the digital
%            values slot.
%  info:     The header information from the DNG file.  This includes a lot
%            of data about isoSpeed, exposure duration, and other stuff.
%
% See Also
%  ieDNGSimpleInfo, ieDNGRead, sensorCreate
%

% Examples:
%{
   fname = 'MCC-centered.dng';
   thisRect = [774  1371  1615  1099];
   [sensor, info] = sensorDNGRead(fname,'crop',thisRect);
   sensorWindow(sensor);
%}
%{
   fname = 'MCC-centered.dng';
   thisFraction = 0.4;  % Central 40 percent of the image
   [sensor, info] = sensorDNGRead(fname,'crop',thisFraction);
   sensorWindow(sensor);
%}

% The info that is returned includes isoSpeed and black level.
%
% If we know how to use the isoSpeed to set the sensor gain, we would.  I
% think they should be used for analog gain and offset, along with black
% level.

%% Parse
varargin = ieParamFormat(varargin);
p = inputParser;

vFunc = @(x)(exist(x,'file'));
p.addRequired('fname',vFunc);
p.addParameter('fullinfo',true,@islogical);

vFunc = @(x)(isnumeric(x) || isa(x,'images.roi.Rectangle'));
p.addParameter('crop',[],vFunc);

p.parse(fname,varargin{:});
fullInfo = p.Results.fullinfo;
crop     = p.Results.crop;
if isa(crop,'images.roi.Rectangle'), crop = crop.Position; end

%% Metadata
[img, info] = ieDNGRead(fname);

% We simplify and standardized the parameter names here
ieInfo      = ieDNGSimpleInfo(info);

if ~fullInfo
    % The user wants just the simpler, standardized version of the full DNG
    % header 
    info = ieInfo;
end

%% Fix up the data

blackLevel   = ceil(ieInfo.blackLevel(1));
exposureTime = ieInfo.exposureTime;  % I hope this is in seconds
img = ieClip(img,blackLevel,[]);   % sets the lower to blacklevel, no upper bound

% Stuff the measured raw data into a simulated sensor
sensor = sensorCreate('IMX363');
sensor = sensorSet(sensor,'size',size(img));
sensor = sensorSet(sensor,'exp time',exposureTime);
sensor = sensorSet(sensor,'black level',blackLevel);
sensor = sensorSet(sensor,'name',fname);
sensor = sensorSet(sensor,'digital values',img); 

%% The Bayer pattern depends on the orientation.
switch ieInfo.orientation
    case 1
        % Counter clockwise 90 deg
        % R G
        % G B
        sensor = sensorSet(sensor,'pattern',[1 2; 2 3]);
    case 3
        % Clockwise 90 deg
        % B G
        % G R
        sensor = sensorSet(sensor,'pattern',[3 2; 2 1]);
    case 6
        % Upright
        % G R
        % B G
        sensor = sensorSet(sensor,'pattern',[2 1; 3 2]);
    case 8
        % Inverted
        % G B
        % R G
        sensor = sensorSet(sensor,'pattern',[2 3; 1 2]);
    otherwise
        error('Unknown Orientation value');
end

%% Check if the user wants us to crop

% To select a rectangular region, the user can use the ISETCam utility
% [~,rect] = ieROISelect(sensor);

if ~isempty(crop)
    if length(crop) == 4
        % We're good.  It's a rect.
    elseif length(crop) == 1 && crop > 0 && crop < 1
        % Find the percentage of the image they want returned
        sz = sensorGet(sensor,'size');
        middlePosition = sz/2;   % Middle position of the image data
        rowcol = crop*sz;        % Fraction the image to return
        row = middlePosition(1) - rowcol(1)/2;
        col = middlePosition(2) - rowcol(2)/2;
        height = rowcol(1); width = rowcol(2);
        crop = round([row, col, height, width]);
    else
        error('Bad crop value %f\n',crop);
    end
    
    % Do the crop
    sensor = sensorCrop(sensor,crop);
end

end