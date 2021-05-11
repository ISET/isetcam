function ml = mlGetCurrent()
% Get current microlens structure, which is attached to the current sensor
%
%   ml = mlGetCurrent(sensor)
%
% The microlens data are stored in the current sensor structure.
%
% Example:
%   ml = mlGetCurrent();
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming:  This should go away and be replaced by the line below in
% the window and elsewhere

% Get the sensor microlens, fill it with the window data
ml = sensorGet(vcGetObject('sensor'), 'micro lens');

end
