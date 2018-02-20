function [ temp, uv ] = spd2cct( wave, spds )
% Convert a spectral power distribution to a correlated color temperature 
%
% [ CCT, uv ] = spd2cct( WAVE, SPDsEnergy )
%
% Calculates the correlated color temperature of a light from its
% spectral power distribution in energy
%
% CCT : Correlated color temperature.
%
% WAVE: Wavelengths of SPD.
% SPD : Spectral power disbution of the lights.  Can be in the columns of a
% matrix.
%
% Example:
%   d = blackbody(400:10:700, 3500);
%   spd2cct(400:10:700,d)
%
%   d = blackbody(400:10:700, 6500);
%   spd2cct(400:10:700,d)
%   
% 
%   d = blackbody(400:10:700, 8500);
%   spd2cct(400:10:700,d)
%
% Copyright ImagEval Consultants, LLC, 2003.


XYZ = ieXYZFromEnergy(spds',wave);

% ISET returns uprime and vprime, which were defined in the 1960s. The flag
% makes sure we get 'uv' instead.
[u,v] =  xyz2uv(XYZ,'uv');

uv = [u,v]';   % Format Jeff wrote for cct.  u in first row, v in second

temp = cct( uv );

end
