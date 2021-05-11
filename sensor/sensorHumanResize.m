function sensor = sensorHumanResize(sensor, rows, cols)
% Add or subtract rows and columns from a sensor for eye movement modeling
%
% sensor = sensorHumanResize(sensor,rows,cols)
%
% Inputs
%   sensor:  Human sensor
%   rows:    [topRows, bottomRows];
%   cols:    [leftCols, bottomCols];
%
% This routine is written to model eye movements.
%
% To add and subtract rols/cols from the sensor, use positive and negative
% numbers. The rows and cols parameters add or subtract from the top/bottom
% (rows) and from the left/right (columns).  When a row or col is added,
% the black (K type, number 1) sensor type is added.
%
% To change the sensor size so that it has a larger field of view, use the
% routine sensorSetSizeToFOV.
%
% Example:
%  sensor = sensorCreate('human');
%  p = sensorGet(sensor,'pattern');
%
% Add two bottom row and one left column
%  rows = [0,2]; cols = [1,0];
%  sensor = sensorHumanResize(sensor,rows,cols);
%
% Remove two bottom rows and one left column
%  rows = [0,-2]; cols = [-1,0];
%  sensor = sensorHumanResize(sensor,rows,cols);
%
% Test for equality
%  p2 = sensorGet(sensor,'pattern');
%  isequal(p,p2)
%
% See also:  sensorSetSizeToFOV
%
% (c) Copyright Imageval, 2012

sz = sensorGet(sensor, 'size');
pattern = sensorGet(sensor, 'pattern');

newSZ(1) = sz(1) + sum(rows);
newSZ(2) = sz(2) + sum(cols);

%% Add or delete  columns

% A pattern value of 1 means empty slot.  L,M,S are 2,3,4.
% adjust left
if cols(1) > 0, pattern = horzcat(ones(size(pattern, 1), cols(1)), pattern);
elseif cols(1) < 0, pattern = pattern(:, (1 + abs(cols(1))):end);
end
% adjust right
if cols(2) > 0, pattern = horzcat(pattern, ones(size(pattern, 1), cols(2)));
elseif cols(2) < 0, pattern = pattern(:, 1:(end -abs(cols(2))));
end

%% Add or delete  rows

% adjust top
if rows(1) > 0, pattern = vertcat(ones(rows(1), size(pattern, 2)), pattern);
elseif rows(1) < 0, pattern = pattern((1+abs(rows(1))):end, :);
end
% adjust below
if rows(2) > 0, pattern = vertcat(pattern, ones(rows(2), size(pattern, 2)));
elseif rows(2) < 0, pattern = pattern(1:(end -abs(rows(2))), :);
end

%% Set size, pattern, and return
sensor = sensorSet(sensor, 'size', newSZ);
sensor = sensorSet(sensor, 'pattern', pattern);

end