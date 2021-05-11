function sensorCheckArray(sensor, n)
% Visual check of the color filter array pattern
%
%     sensorCheckArray(sensor,n)
%
% The routine produces an image that shows the color filter array pattern.
%
% The image is n x n, where n = 25 by default
%
% Example:
%   sensorCheckArray(sensorCreate,10);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('n'), n = 25; end

% The config field contains (x,y,color) information for the entire array
% If the ISA array is big, then just plot a portion of it
cfa = sensorDetermineCFA(sensor);

if size(cfa, 1) > n, cfa = cfa(1:n, 1:n); end

sensorImageColorArray(cfa);

return;
