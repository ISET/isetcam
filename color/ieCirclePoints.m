function [x,y] = ieCirclePoints(radSpacing)
%Make samples on a circle
%
% Synopsis 
%  [x,y] = ieCirclePoints([radSpacing = 2*pi/60])
%
% Inputs
% radSpacing: Spacing (in radians) around the circle.
%             (2pi points in a circle.  So 2pi/100 is 100 points)
%
% Return
%  [x,y] - Points on the circle
%
% See also
%

% Example:
%{
    radSpacing = 2*pi/25;   % 25 points
    [x,y] = ieCirclePoints(radSpacing);
    ieNewGraphWin; plot(x,y,'o'); axis equal
%}


if ieNotDefined('radSpacing'), radSpacing = 2*pi/60; end

theta = (0:radSpacing:2*pi);
x = cos(theta); y = sin(theta);

end
