function ax = iePlotShadeBackground(ax,varargin)
% Shade the background of an axis, say for an ieFigure
%
% Synopsis
%   ax = iePlotShadeBackground(ax,varargin);
%
% Brief description
%   Add a shaded background to a graph in a figure. By default a grid
%   is added.  The axis hold state is preserved.
%
% Inputs
%   ax - Axis to shade
%
% Key/Val pairs
%   grid          - 'on' or 'off' (default:  'on')
%   vertex colors - 4 x 3 vector of RGB colors 
%                   [bottomleft; bottomright; upperleft; upperright];
%                   default: [0.8 0.8 0.8; 0.8 0.8 0.8; 1 1 1; 1 1 1]
%
% Outputs
%   ax - Modified axis
%
% See also
%   ieFigure

% Example:
%{
x = linspace(0, 10, 200); y = besselj(1, x);

hdl = ieFigure;
plot(x, y, 'LineWidth', 1.5, 'Color', 'k');
bottomleft = [1 1 1];
bottomright = [0.5 0.5 0.5];
upperleft = [1 0.5 0.5];
upperright = [0.5 0.5 1];
vcolors = [bottomleft; bottomright; upperleft; upperright];

iePlotShadeBackground(hdl.CurrentAxes,'grid','on','vertexcolors',vcolors);
%}

%% Parameters
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('ax',@(x)(isgraphics(ax,'axes')));
p.addParameter('vertexcolors',[0.8 0.8 0.8; 0.8 0.8 0.8; 1 1 1; 1 1 1],@ismatrix);
p.addParameter('grid','on',@(x)(ismember(lower(x),{'on','off'})));
p.parse(ax,varargin{:});

%%
holdstatus = ishold(ax);
axes(ax); hold on;

xlims = get(ax, 'XLim');
ylims = get(ax, 'YLim');

% Define the vertices of the patch to cover the entire plot area
verts = [xlims(1) ylims(1); xlims(2) ylims(1); xlims(2) ylims(2); xlims(1) ylims(2)];

% Define the colors for each vertex (top vertices are light blue, bottom are white)
colors = p.Results.vertexcolors; % [1 1 1; 1 1 1; 0.8 0.9 1; 0.8 0.9 1];

% Create the patch object
background = patch('Vertices', verts, 'Faces', [1 2 3 4], ...
          'FaceVertexCData', colors, ...
          'FaceColor', 'interp', ...
          'EdgeColor', 'none');

% Ensure the patch is in the background
uistack(background, 'bottom');

if isequal(lower(p.Results.grid),'on')
    % Set the axes 'Layer' property to 'top'
    set(ax, 'Layer', 'top');

    % You can also use dot notation:
    % ax.Layer = 'top';

    % Now, turn on the grid
    grid on;
end

% If hold was off, return to that status
if ~holdstatus
    hold off;
end

end
