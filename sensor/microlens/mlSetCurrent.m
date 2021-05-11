function mlSetCurrent(ml)
% Store the microlens from the window in the current sensor
%
%   mlSetCurrent(ml)
%
% Example:
%
%  mlSetCurrent(ml);
%
% See also: mlGetCurrent
%
% Imageval Consulting, LLC, Copyright 2005

if ieNotDefined('ml'), error('Microlens required'); end

sensor = sensorSet(vcGetObject('sensor'), 'micro lens', ml);
vcReplaceObject(sensor);

end

% if ieNotDefined('ml'),      error('Microlens required'); end
% if ieNotDefined('handles'), error('Handles to microLensWindow required'); end
% if ieNotDefined('sensor'),  sensor = vcGetObject('sensor'); end
%
% % Store ml in sensor and replace the current sensor with this one
% sensor = sensorSet(sensor,'microlens',ml);
% vcReplaceObject(sensor);

% Update the window with the ml data
% mlFillWindowFromML(handles,ml);
