function d = ieRad2deg(r,varargin)
% Convert radians to degrees
%
%  d = ieRad2deg(r)
%
% Also converts to minutes by extra argument.
%
%   ieRad2deg(r);
%   ieRad2deg(r,'arcmin');
%   ieRad2deg(r,'arcsec');
%
% Copyright ImagEval Consultants, LLC, 2005.

if isempty(varargin), d = (180/pi)*r; 
else                  d = r*ieUnitScaleFactor(varargin{1});
end   

return;
