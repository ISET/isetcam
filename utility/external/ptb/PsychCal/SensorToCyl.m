function cyl = SensorToCyl(sensor)
% cyl = SensorToCyl(sensor)
%
% Convert from sensor to cylindrical coordinates.
%
% This is designed for use with the CIE Lxx color
% spaces, so it's assumed that the first input
% coordinate is luminance and this is taken directly
% as height.  The next two input coordiantes are
% assumed to be chromaticity coords.
%
% The returned cylindrical system is luminance, radius, angle,
% with radius and angle computed in the passed chromaticity plane.
%
% Note that angle is returned in radians.
%
% We use the conventions of the CIE Lxx color spaces
% for angle.
%
% See also CylToSensor, SensorToPolar, PolarToSensor.
%
% 10/17/93  dhb   Wrote it by converting CAP C code.
% 2/20/94   jms   Added single argument case to avoid cData.
% 4/5/02    dhb, ly  New calling interface.
% 11/06/06  dhb   No longer allow two passed args.
% 1/3/10    dhb   Elaborated comments a little.

cyl = sensor;
cyl(1,:) = sensor(1,:);
cyl(2,:) = sqrt( sensor(2,:).^2 + sensor(3,:).^2 );

index = find( sensor(2,:) == 0.0 & sensor(3,:) == 0.0 );
if (~isempty(index) )
  cyl(3,index) = zeros(1,length(index)); 
end
index = find( sensor(2,:) == 0.0 & sensor(3,:) > 0.0 );
if (~isempty(index) )
  cyl(3,index) = pi/2*ones(1,length(index));  
end
index = find( sensor(2,:) == 0.0 & sensor(3,:) < 0.0 );
if (~isempty(index) )
  cyl(3,index) = 3*pi/2*ones(1,length(index)); 
end    
index = find( sensor(2,:) > 0.0 & sensor(3,:) > 0.0 );
if (~isempty(index) )
  cyl(3,index) = atan(sensor(3,index) ./ sensor(2,index) ); 
end    
index = find( sensor(2,:) > 0.0 & sensor(3,:) < 0.0 );
if (~isempty(index) )
  cyl(3,index) = 2*pi*ones(1,length(index)) + ...
                 atan(sensor(3,index) ./ sensor(2,index) ); 
end
index = find( sensor(2,:) < 0.0 & sensor(3,:) > 0.0 );   
if (~isempty(index) )
  cyl(3,index) = pi*ones(1,length(index)) + ...
                 atan(sensor(3,index) ./ sensor(2,index) ); 
end   
index = find( sensor(2,:) < 0.0 & sensor(3,:) < 0.0 );   
if (~isempty(index) )
  cyl(3,index) = pi*ones(1,length(index)) + ...
                 atan(sensor(3,index) ./ sensor(2,index) ); 
end   

