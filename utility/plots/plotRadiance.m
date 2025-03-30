function [hdl, thisPlot] = plotRadiance(wavelength,radiance,varargin)
% Utility to plot and label radiance data
%
% Syntax
%   [hdl, thisPlot] = plotRadiance(wavelength,radiance,varargin)
%
% Inputs
%    wavelength  - Wavelength samples (nm)
%    radiance    - Columns of radiances
%
% Optional key/value pairs
%    title -
%    hdl   - Use this hdl instead of ieNewGraphWin
%    line width
%    color
%
% Returns;
%   hdl      - ieNewGraphWin handle
%   thisPlot - Return of the plot command
%
% See also
%   ieNewGraphWin, plotX
%

% More options to come.  Such as a title.
%

%% Parse

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('wavelength',@isvector);
p.addRequired('radiance',@isnumeric);

p.addParameter('title','Spectral radiance',@ischar);
p.addParameter('hdl',[],@(x)(isa(x,'matlab.ui.Figure')));
p.addParameter('color','',@ischar);
p.addParameter('linewidth',2,@isnumeric);

p.parse(wavelength,radiance,varargin{:});

strTitle = p.Results.title;
hdl      = p.Results.hdl;

%% Open the window
if isempty(hdl), hdl = ieFigure; end

wavelength = wavelength(:);

%% Handle the case of a transpose in radiance

% The dimension that matches wavelength is the right one
nWave = length(wavelength);
if nWave == size(radiance,1)
    thisPlot = plot(wavelength(:),radiance,...
        'LineWidth',p.Results.linewidth);
    if ~isempty(p.Results.color), set(thisPlot,'Color',p.Results.color); end
elseif length(wavelength) == size(radiance,2)
    thisPlot = plot(wavelength(:),radiance',...
        'LineWidth',p.Results.linewidth);
        if ~isempty(p.Results.color), set(thisPlot,'Color',p.Results.color); end
end

%% Label it

xlabel('Wavelength (nm)');
ylabel('Radiance (watts/sr/nm/m^2)');
grid on;
title(strTitle);

end
