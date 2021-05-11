function [x, y, z] = ieShape(type, nSamp, varargin)
%Return x,y,z values of a shape
%
%   [x,y,z] = ieShape(type,nSamp,varargin)
%
% We calculate shapes like circles, ellipses, maybe other stuff later.
%
%Example:
%
%  Positions of the Airy disk zero crossing for an f# 5.6 lens at 550 nm.
%  The units of x,y are meters
%  fNumber = 2.0; wavelength = 550;
%  radius = (2.44*fNumber*wavelength*10^-9);
%  [x,y] = ieShape('circle',200, radius); plot(x,y,'.');
%  axis equal; grid on
%
% Imageval Consulting, LLC, 2015

if ieNotDefined('type'), type = 'circle'; end
if ieNotDefined('nSamp'), nSamp = 200; end
x = zeros(nSamp, 1);
y = x;
z = x;

switch lower(type)
    case {'circle', 'circ'}
        if isempty(varargin), radius = 1;
        else radius = varargin{1};
        end
        theta = (2 * pi * (1:nSamp) / nSamp)';
        x = radius * cos(theta);
        y = radius * sin(theta);
    otherwise
        error('Unknown type:P %s', type);
end

return;