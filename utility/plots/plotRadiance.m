function hdl = plotRadiance(wavelength,radiance,varargin)
% Utility to plot and label radiance data
%
% Syntax
%   hdl = plotRadiance(wavelength,radiance,varargin)
%
% Inputs
%    wavelength  - Wavelength samples (nm)
%    radiance    - Columns of radiances
%
% Optional key/value pairs
%    title
%
% Returns;
%   hdl
%
% See also
%   ieNewGraphWin, plotX
%

% More options to come.  Such as a title.
%

%%
p = inputParser;
p.addRequired('wavelength',@isvector);
p.addRequired('radiance',@isnumeric);

p.addParameter('title','Spectral radiance',@ischar);

p.parse(wavelength,radiance,varargin{:});
strTitle = p.Results.title;

%% Open the window
hdl = ieNewGraphWin;
wavelength = wavelength(:);

%% Handle the case of a transpose in radiance

% The dimension that matches wavelength is the right one
nWave = length(wavelength);
if nWave == size(radiance,1)
    plot(wavelength(:),radiance);
elseif length(wavelength) == size(radiance,2)
    plot(wavelength(:),radiance');
end

%% Label it

xlabel('Wavelength (nm)');
ylabel('Radiance (watts/sr/nm/m^2)');
grid on;
title(strTitle);

end
