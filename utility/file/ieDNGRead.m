function [img,info] = ieDNGRead(fname,varargin)
% Read a DNG file data
%
% Synopsis
%    [img,info,infoSimple] = ieDNGRead(fname,varargin)
%
% Inputs
%   fname:  DNG file
%
% Optional key/val pairs
%   only info :    Do not read the data Logical (default: false)
%   simple info:   Only a few header fields are returned.  exposure, speed,
%                  orientation and black level  (default: false)
%   rgb:           Return an RGB image, not the raw image
%
% Returns
%   img:  Image data mosaic, or if rgb flag is set an RGB file
%   info: The header information.  I am unsure whether exposure time is in
%         seconds, I think.
%
% See also
%   sensorDNGRead, dcrawRead

% Examples:
%{
  fname = 'MCC-centered.dng';
  [img,info] = ieDNGRead(fname);
%}
%{
  [~,info] = ieDNGRead(fname,'simple info',true,'only info',true);
%}
%{
  [img,info] = ieDNGRead(fname,'simple info',true);
%}

%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;

vFunc = @(x)(exist(x,'file'));
p.addRequired('fname',vFunc);

p.addParameter('onlyinfo',false);
p.addParameter('simpleinfo',false);
p.addParameter('rgb',false,@islogical);

p.parse(fname,varargin{:});

onlyInfo   = p.Results.onlyinfo;
simpleInfo = p.Results.simpleinfo;
rgbflag    = p.Results.rgb;

%% Read the info with imfinfo (Matlab)

% The user may want only the simple info or all the info.  Over time we may
% expand what is in the simple info struct.
allInfo = imfinfo(fname);

if simpleInfo
    % Pull out a few fields. We are aware of two types of info structs at
    % present.  More may appear over time.
    if checkfields(allInfo,'DigitalCamera')
        % For camera app on the Google Pixel 4a
        infoSimple.isoSpeed     = allInfo.DigitalCamera.ISOSpeedRatings;
        infoSimple.exposureTime = allInfo.DigitalCamera.ExposureTime;
        infoSimple.blackLevel   = allInfo.SubIFDs{1}.BlackLevel;
        infoSimple.orientation  = allInfo.Orientation;
    else
        % For openCam files
        infoSimple.isoSpeed     = allInfo.ISOSpeedRatings;
        infoSimple.exposureTime = allInfo.ExposureTime;
        infoSimple.blackLevel   = allInfo.BlackLevel;
        infoSimple.orientation  = allInfo.Orientation;
    end
    info = infoSimple;
else
    info = allInfo;
end

%%  Return the img data too

if onlyInfo
    img = [];
    return;
else
    % dcraw needs a full path name, often.
    fullFile = which(fname); 
    if isempty(fullFile)
        error('Cannot find file %s',fname);
    end

    if rgbflag
        img = imread(fullFile);
    else
        % Raw mosaic will be returned.  This is the default.
        img = dcrawRead(fullFile);
    end
end

end
