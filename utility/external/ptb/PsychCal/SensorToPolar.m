function [pol] = SensorToPolar(sensor)
% [pol] = SensorToPolar(sensor)
%
% Converts from sensor rectangular coordinates to polar
% coordinates.
%
% Polar coordinates are defined as radius, azimuth, and elevation.
%
% See also PolarToSensor, SensorToCyl, CylToSensor.
%
% 9/9/93 jms	It didn't work for matrix inputs, because a 
%				matrix '^' needed to be a by-element '.^'
% 9/26/93 dhb   Added calData argument.
% 2/6/94  jms   Changed 'polar' to 'pol'
% 2/20/94 jms   Added single argument case to avoid cData
% 4/6/96  dhb	Fixed bug noted by ccc.  Need to use four quadrant
%				arctangent atan2().
% 5/20/98 dhb   Fix little bug, make sure index is not empty.
% 4/5/02  dhb, ly  New calling interface.
% 11/6/06 dhb   Only allow one input argument.
% 2/10/07 dhb   Finish above fix.

[n,m] = size(sensor);
if (n ~= 3)
  error('Cannot handle sensor coordinates with dimension other than 3');
end

pol = zeros(n,m);
pol(1,:) = sqrt(sensor(1,:).^2 + sensor(2,:).^2 + sensor(3,:).^2);
pol(2,:) = atan2(sensor(2,:),sensor(1,:));
index = find(pol(2,:) < 0);
if (~isempty(index))
	pol(2,index) = 2*pi*ones(size(index))+pol(2,index);
end
pol(3,:) = atan(sensor(3,:) ./ sqrt(sensor(1,:).^2 + sensor(2,:).^2) );

