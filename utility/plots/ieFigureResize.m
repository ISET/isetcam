function ieFigureResize(figOrAx, figpos, units)
% ieFigureResize(ax,figpos)
%
% Not really well thought through.  Work in progress.
%
% Resize the figure so it tightly encloses the axes (including labels, ticks, and title).
%
% Inputs
%   ax - handle to an axes (default: gca)
%
% The figure's PaperPositionMode is respected. Units are temporarily set to 'pixels'
% to compute accurate extents, then restored to the original values.
%
% Example
%   fig = figure;
%   ax = axes;
%   plot(ax, rand(10,1));
%   xlabel('x-axis'); ylabel('y-axis'); title('Example');
%   resizeFigureToAxes(ax);

% setFigureSizeSafe(figOrAx, pos, units)
%   pos   - [x y w h]
%   units - 'pixels' or 'normalized' (default 'pixels')

if nargin < 3 || isempty(units), units = 'normalize'; end
if nargin < 2 || isempty(figpos), figpos = [0.0035 0.4125 0.3266  0.4972]; end

if ~ishandle(figOrAx), error('First arg must be a figure or axes handle.'); end
if strcmp(get(figOrAx,'Type'),'axes')
    ax = figOrAx; 
    fig = ancestor(figOrAx,'figure'); 
else 
    fig = figOrAx; 
    ax = get(figOrAx,'CurrentAxes');
end

% maximize is an option.  If that is set, nothing works.
fig.WindowStyle = 'normal';

% 3) Set units before position
oldUnits  = fig.Units;
oldResize = fig.Resize;
fig.Resize = 'off';
fig.Units  = units;

% 4) Apply size
% We should be able to figure out axes position and insets and set the
% figpos from that.  Not succeeded yet.
%{
ti  = ax.TightInset;  % [left bottom right top] margins around the axes

% Total space needed for axes + labels
outerWidth  = ax.Position(3) + ti(1) + ti(3);
outerHeight = ax.Position(4) + ti(2) + ti(4);

% Compute bottom-left corner relative to figure
bottomLeftX = ax.Position(1) - ti(1);
bottomLeftY = ax.Position(2) - ti(2);

% Leaves the image with too much white space left-right.
%
% Resize figure to fit tightly around axes
fig.Position = [ax.Position(1) + bottomLeftX, ...
             ax.Position(2) + bottomLeftY, ...
             outerWidth, outerHeight];
%}

fig.Position = figpos;

drawnow;

% 5) Restore options
fig.Units  = oldUnits;
fig.Resize = oldResize;

end
%}

%{
fig.WindowStyle = 'normal';      % undock so Position takes effect
fig.Units = 'normalized';        % or 'pixels' if you prefer absolute
fig.Position = [0.007 0.55 0.28 0.36];  % now respected
drawnow;
axis(ax,'tight');                % optional: tighten limits, not size


% fig = ancestor(ax,'figure');
% 
% fig.Position = 1.5*[0.0070 0.5500 0.2800 0.3600];
% drawnow;
% 
% axis tight

end

%}