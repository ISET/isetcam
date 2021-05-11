function [x, y] = ieCirclePoints(radSpacing)
%Make samples on a circle
%
%  [x,y] = ieCirclePoints(radSpacing)
%
% radSpacing: Spacing (in radians) around the circle.
%             (2pi points in a circle.  So 2pi/100 is 100 points)
% Example
%    radSpacing = 2*pi/25;
%    [x,y] = ieCirclePoints(radSpacing);
%    plot(x,y,'o'); axis equal
%
% Copyright Imageval 2012

theta = (0:radSpacing:2 * pi);
x = cos(theta);
y = sin(theta);

return;
