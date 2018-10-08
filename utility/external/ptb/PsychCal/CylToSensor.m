function sensor = CylToSensor(cyl)
% sensor = CylToSensor(cyl)
%
% Convert from cylindrical to sensor coordinates.
% We use the conventions of the CIE Lxx color spaces
% for angle.  This inverts SensorToCyl, see that routine
% for description of coordinate systems.
%
% See also SensorToCyl, SensorToPolar, PolarToSensor.
%
% 10/17/93    dhb   Wrote it by converting CAP C code.
% 2/20/94     jms   Added single argument case to allow avoiding cData
% 4/5/02      dhb, ly  Change name.
% 11/6/06     dhb   Only allow one arg.

sensor(1,:) = cyl(1,:);
sensor(2,:) = cyl(2,:) .* cos( cyl(3,:) );
sensor(3,:) = cyl(2,:) .* sin( cyl(3,:) );
