function list = faultyList(row, col, nBadPixels, minSeparation)
% Generate a list of faulty pixels
%
%  list = faultyList(row,col,nBadPixels,minSeparation)
%
% The list of faulty pixels is an Nx2 matrix of (row,col) positions.  This
% list is taken as input by FaultyBilinear and the other faulty pixel
% demosaicing replacement routines.
%
% Input arguments:
%   row, col:       Sensor size (default = current sensor size)
%   nBadPixels:     How many bad pixels? (default = 1% of the pixels)
%   minSeparation:  How close can the pixels be?  (default = 5)
%
% Examples:
%   list = faultyList;
%   list = faultyList(256,256,20,4);
%
% Copyright ImagEval Consultants, LLC, 2007.

% row = 288;
% col = 352;
% nBadPixels = 10;

if ieNotDefined('row') || ieNotDefined('col'),
    sensor = vcGetObject('sensor');
    if ~isempty(sensor), sz = sensorGet(sensor, 'size');
        row = sz(1);
        col = sz(2);
    else
        error('No sensor, no row or col');
    end
end
if ieNotDefined('nBadPixels'), nBadPixels = round(row*col*0.01); end
if ieNotDefined('minSeparation'), minSeparation = 2; end

% Create a list, but demand that we get nBadPixels unique samples
list = [];
while size(list, 1) ~= nBadPixels
    xlist = round(rand(1, nBadPixels)*(col - 1)) + 1;
    ylist = round(rand(1, nBadPixels)*(row - 1)) + 1;
    list = [xlist; ylist]';
    list = unique(list, 'rows');
end

% If there are pixels too close, call this routine again and try again
% Hopefully we will never get stuck here in an infinite loop.  Could happen if
% there are a lot of bad pixels.
if nBadPixels * minSeparation * 4 > row * col
    error('Separation parameter and size are poorly chosen.');
end

% No problem on spacing with 1 pixel.  Otherwise, make sure
% they are spaced at least minSeparation.
if nBadPixels == 1, return;
else
    for ii = 1:nBadPixels
        diff = list - repmat(list(ii, :), nBadPixels, 1);
        dist = sort(sqrt(diag(diff * diff')));
        if dist(2) < minSeparation
            % Replace this pixel with another random draw
            while 1
                list(ii, 1) = round(rand(1, 1)*(col - 1)) + 1;
                list(ii, 2) = round(rand(1, 1)*(row - 1)) + 1;
                list = unique(list, 'rows');
                if size(list, 1) == nBadPixels, break; end
            end
            ii = ii - 1;
        end
    end
end


return;
