function [corners,rect] = chartCorners(sensor)
% User selects the corner points of a chart
%
%  [corners,rect] = chartCorners(sensor)
%
% Inputs:
%  Will be obj in the future.  For now, only sensor.
%
% Returns:
%   corners: Structure with upper left (ul) and other slots (ur,ll,lr) of
%   corner positions of the chart.  Data are (row, col), which is (y,x)
%
% The rect is [cmin, rmin, cwidth, rheight]
%
% See also:  macbethSelect.
%
% (c) Imageval Consulting, LLC, 2012

% These are returned as (x,y), which is col,row.
% We flip them to (row,col)
disp('Click right button to end selection');
pts = vcPointSelect(sensor,4,...
    'Select (1) upper left, (2) upper right, (3) lower right, (4) lower left');
pts = fliplr(pts);

% Return labeled corners are row,col)
corners.ul = pts(1,:);
corners.ur = pts(2,:);
corners.lr = pts(3,:);
corners.ll = pts(4,:);

% The rect is 
% [cmin, rmin, cwidth, rheight]

if nargout == 2
    % upper left coordinates
    % the width and height
    rect = [pts(1,2),pts(1,1),pts(2,2)-pts(1,2),pts(3,1)-pts(1,1)];
end

end
