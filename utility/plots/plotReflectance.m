function [hdl, thisPlot] = plotReflectance(wavelength,reflectance,varargin)
% Utility to plot and label reflectance data
%
% Syntax
%   [hdl, thisPlot] = plotReflectance(wavelength,reflectance,varargin)
%
% Inputs
%    wavelength  - Wavelength samples (nm)
%    reflectance    - Columns of radiances
%
% Optional key/value pairs
%    title
%
% Returns;
%   hdl      - ieNewGraphWin handle
%   thisPlot - Return of the plot command
%
% See also
%   ieNewGraphWin, plotRadiance, plot<X>
%

% More options to come.  Such as a title.
% Maybe this should be plotX(... 'type','radiance')
%

%%
p = inputParser;
p.addRequired('wavelength',@isvector);
p.addRequired('radiance',@isnumeric);

p.addParameter('title','Spectral reflectance',@ischar);

p.parse(wavelength,reflectance,varargin{:});
strTitle = p.Results.title;

%% Open the window
hdl = ieNewGraphWin;
wavelength = wavelength(:);

%% Handle the case of a transpose in radiance

% The dimension that matches wavelength is the right one
nWave = length(wavelength);
if nWave == size(reflectance,1)
    thisPlot = plot(wavelength(:),reflectance,'LineWidth',2);
elseif length(wavelength) == size(reflectance,2)
    thisPlot = plot(wavelength(:),reflectance','LineWidth',2);
end

%% Label it

xlabel('Wavelength (nm)');
ylabel('Reflectance');
grid on;
title(strTitle);

end
