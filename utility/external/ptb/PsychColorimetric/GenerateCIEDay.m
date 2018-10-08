function [spd,xd,yd,M1,M2] = GenerateCIEDay(Temp,B)
% [spd,xd,yd] = GenerateCIEDay(Temp,[B])
% 
% Generate CIE daylights of the desired correlated color
% temperature.  Formulae are from W+S, pp. 145-146.
%
% The required basis vectors may be obtained by loading
% the file B_cieday.
%
% INPUT
%   Temp - row vector of color temperatures.  These should be
%       in the range 4000 - 25000.
%   B - CIE daylight basis vectors.
% 
% OUTPUT
%   spd - desired spectral power distributions
%   xd  - row vector of x chromaticities
%   yd  - row vector of y chromaticities
%
% 9/28/93   dhb, jms  Changed argument name to Temp
%                     If B not passed, return spd = [] and other data

% Get sizes
[null,m] = size(Temp);
xd = zeros(1,m);
yd = zeros(1,m);

% Compute xd chromaticities
index = find(Temp < 7000);
if (length(index) > 0)
  xd(index) = -4.6070*1e9./(Temp(index).^3) + 2.9678*1e6./(Temp(index).^2) ...
              + 0.09911*1e3./(Temp(index)) + 0.244063;
end
index = find(Temp >= 7000);
if (length(index) > 0)
  xd(index) = -2.0064*1e9./(Temp(index).^3) + 1.9018*1e6./(Temp(index).^2) ...
               + 0.24748*1e3./(Temp(index)) + 0.237040;
end

% Compute yd chromaticities
yd = -3.*(xd.^2) + 2.870.*xd - 0.275;

% Compute M0, M1 and M2
M0 = ones(1,m);
M1 = (-1.3515 - 1.7703.*xd + 5.9114.*yd) ./ ...
     (0.0241 + 0.2562.*xd - 0.7341 .* yd);
M2 = (0.03 - 31.4424.*xd + 30.0717.*yd) ./ ...
     (0.0241 + 0.2562.*xd - 0.7341 .* yd);

% Compute the SPD
M = [M0 ; M1 ; M2];
if (nargin == 2)
  spd = B*M;
else
  spd = [];
end

