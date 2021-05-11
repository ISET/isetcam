function infoSimple = ieDNGSimpleInfo(info)
% Returns a simplified version of the DNG header info
%
% Synopsis
%   infoSimple = ieDNGSimpleInfo(allInfo)
%
% Inputs
%    info:  This is the header info from a DNG file.  It can take
%           different formats, depending on the app that wrote the DNG
%           file.
%
% Outputs
%    infoSimple:  ISETCam formatted info.  Much shorter.  May evolve over
%                 time.
%
% See also
%  ieDNGRead
%

% Example:
%{
fname = 'mcc-Centered.dng';
[~, info] = ieDNGRead(fname,'only info',true);
infoSimple = ieDNGSimpleInfo(info)
%}

% Pull out a few fields. We are aware of two types of info structs at
% present.  More may appear over time.
if checkfields(info, 'DigitalCamera')
    % For camera app on the Google Pixel 4a
    infoSimple.isoSpeed = info.DigitalCamera.ISOSpeedRatings;
    infoSimple.exposureTime = info.DigitalCamera.ExposureTime;
    infoSimple.blackLevel = info.SubIFDs{1}.BlackLevel;
    infoSimple.orientation = info.Orientation;
else
    % For openCam files
    infoSimple.isoSpeed = info.ISOSpeedRatings;
    infoSimple.exposureTime = info.ExposureTime;
    infoSimple.blackLevel = info.BlackLevel;
    infoSimple.orientation = info.Orientation;
end

end
