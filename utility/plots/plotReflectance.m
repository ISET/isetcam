function [hdl, thisPlot] = plotReflectance(wavelength,reflectance,varargin)
% Utility to plot spectral reflectance data
%
% Syntax
%   [hdl, thisPlot] = plotReflectance(wavelength,reflectance,varargin)
%
% Brief
%   Labels the axes.  Enables some control of the lines.
%
% Inputs
%    wavelength  - Wavelength samples (nm)
%    reflectance    - Columns of radiances
%
% Optional key/value pairs
%    hdl   - Use this hdl instead of opening a new figure with ieFigure
%    title - Default: 'Spectral reflectance'
%    line width - Default: 2
%    line style - One of the usual:  :,;,--,-
%    color - a color letter 'k','r', or a color 3-vector ([0.5,0.3,0.2])
%
% Returns;
%   hdl      - ieNewGraphWin handle
%   thisPlot - Return of the plot command
%
% See also
%   ieFigure, plotRadiance, plot<TAB>
%


%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('wavelength',@isvector);
p.addRequired('radiance',@isnumeric);

p.addParameter('title','Spectral reflectance',@ischar);
p.addParameter('hdl',[],@(x)(isa(x,'matlab.ui.Figure')));
p.addParameter('color',[],@(x)(ischar(x) || isvector(x)));
p.addParameter('linewidth',2,@isnumeric);
p.addParameter('linestyle','-',@ischar);

p.parse(wavelength,reflectance,varargin{:});
strTitle = p.Results.title;
hdl      = p.Results.hdl;

%% Open the window
if isempty(hdl), hdl = ieFigure; end
wavelength = wavelength(:);

%% Handle the case of a transpose in radiance

% The dimension that matches wavelength is the right one
if numel(wavelength) == size(reflectance,2)
    reflectance = reflectance';
end

thisPlot = plot(wavelength(:),reflectance,...
    'LineWidth',p.Results.linewidth);

% Randomly color the lines unless this is set.
if ~isempty(p.Results.color)
    ll = findobj(thisPlot,'type','line');
    for ii= 1:numel(ll)
        set(ll(ii),'Color',p.Results.color);
        set(ll(ii),'linestyle',p.Results.linestyle);
    end
end

%% Label it

xlabel('Wavelength (nm)');
ylabel('Reflectance');
grid on;
title(strTitle);

end
