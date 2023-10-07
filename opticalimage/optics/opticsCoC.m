function circ = opticsCoC( optics, oDist, unit )
% Calculate the circle of confusion diameter on the sensor surface for
% the optics 
%
%  Syntax:
%    circ = opticsCoC(optics, oDist, [unit='m'])
%
%  Brief description:
%    The computed blur circle is for an object at a distance oDist on
%    the surface of a sensor positioned at the focal distance from the
%    lens.  This calculation is an approximation for a thin lens.
%
%  Parameters
%    optics - optics struct (required)
%    oDist  - distance to the object (required)
%    unit   - spatial units ('m' default)
%
% We only use geometry to compute the circle.  We could impose a limit
% for diffraction.
%
% Suppose the image point is P, and the focal length is f. Then P is
% brought to focus at fP.
%
% The half angle swept out by cone of rays through a point at fP is
% calculated from the right triangle with sides A/2 and fP.
%
% Then we calculate the distance on the sensor surface given the
%
% Programming: Perhaps this should just be a call
%
%      opticsGet(optics,'coc',dist,unit)
%
%  and perhaps we should never let this be smaller than the
%  diffraction limit, and there should be a call
%
%      opticsGet(optics,'diffraction limit diameter');
%
% http://en.wikipedia.org/wiki/Circle_of_confusion#Determining_a_circle_of_confusion_diameter_from_the_object_field
%
% Includes the original wonderful article, written in 1866, describing
% the geometry. 
%
% Example:
%   optics = opticsCreate;
%   oDist = 1;    opticsCoC(optics,oDist,'um')  % Far away
%   oDist = 0.2;  opticsCoC(optics,oDist,'um')  % Close
%
% Copyright Imageval Consulting, LLC 2015
%
% See also
%  s_opticsCoC

% Object plane distance S1 = object distance
% Image plane distance  S2 = in-focus distance
% Aperture diameter      A
% Fnumber of the lens    f

if ieNotDefined('unit'), unit = 'm'; end

% Basic numbers
A = opticsGet(optics,'diameter');
f = opticsGet(optics,'focal length');

% Image point of P
fp = oDist*f / (oDist - f);

% Angle of the cone rays
% tan(phi) = (A/2)/fP = tan(phi)
phi = atan2(A/2,fp);

% Size of the image on the sensor
% tan(phi) = opp/abs(f - fP)
circ = tan(phi)*abs(f-fp);

% This was only the half angle, so double the c
circ = circ*2;

% This is the magnification.  The cone of confusion back in object space is
% the circ times the magnification.
% magnification = fp / oDist;

% Deal with the units
circ = circ*ieUnitScaleFactor(unit);

end




