function params = wvfApertureP
% Default parameters for wavefront aperture
%
% We will define these over time and illustrate their impact
%
% See also
%   wvfAperture
%
% We should implement wvfApertureSet/Get

% Example:
%{
wvf = wvfCreate;
params = wvfApertureP;
[aperture, params] = wvfAperture(wvf,params);
%}

params.nsides      = 5;
params.dotmean     = 10;
params.dotsd       = 5;
params.dotopacity  = 0.5;
params.dotradius   = 5;
params.linemean    = 10;
params.linesd      = 5;
params.lineopacity = 0.5;
params.linewidth   = 2;

end
