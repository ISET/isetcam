function ieFormatFigure(fig, fontname, fontsize, figsize, border)
%Formats a figure for presentations or papers.
%
%   ieFormatFigure( [FIG], [FONTNAME], [FONTSIZE], [FIGSIZE], [BORDER] )
%
%  The font style, font size,figure size and border size can be adjusted.
%  All parameters are optional.  Using this makes it easier to save the
%  figure in an appropriate format for Adobe Illustrator.
%
% FIG     : Figure handle.
% FONTNAME: Name of the font as a string.
% FONTSIZE: Size of the font (points) as a vector.
%           Format: [axes_labels tick_labels]
% FIGSIZE : Size of the figure [width height] (inches) as a vector.
% BORDER  : Space around the figure (inches) as a vector.
%           Format: [left bottom right top] or
%                   [left/right  botom/top]
%
% Default settings of the inputs are:
%   FIG     : gcf (current figure)
%   FONTNAME: 'Helvetica'
%   FONTSIZE: [18 14]
%   FIGSIZE : [6 6]
%   BORDER  : [0.75 0.35]
%
% Note: Function has a problem settiing the font size of the legend
% sometimes.  If the legend font is the wrong size, call this function
% again.  The second call corrects the problem.  We believe this to be a
% Matlab problem.
%
% Copyright ImagEval Consultants, LLC, 2005.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Format the input parameters.

% Load default paramemters.

if ieNotDefined('fig'), fig = 0; end % Root
if ieNotDefined('fontname'), fontname = 'Helvetica'; end
if ieNotDefined('fontsize'), fontsize = [18, 14]; end
if ieNotDefined('figsize'), figsize = [6.5, 6.5]; end
if ieNotDefined('border'), border = [1, 0.5]; end

% Check the fontsize.

if (length(fontsize) == 1), fontsize = [fontsize, fontsize]; end

% Check the figure size.
if (length(figsize) == 1), figsize = [figsize, figsize]; end

% Check the border.
if (length(border) == 2), border = [border(1), border(1), border(2), border(2)]; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the figure axes.

if (~ieNotDefined('fig') ~= 1 | fig == 0), fig = gcf; end
axs = get(fig, 'CurrentAxes');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the current figure position.

if (strcmp(get(fig, 'Units'), 'inches') == 1), pos = get(fig, 'Position');
else pos = [0, 0, 0, 0]; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the figure properties.

set(fig, 'Units', 'inches');
set(fig, 'Position', [pos(1:2), figsize]);
set(fig, 'PaperPosition', [4.25 - figsize(1) / 2, 5.5 - figsize(2) / 2, figsize]);
set(fig, 'Color', [1, 1, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the axes properties.

set(get(axs, 'Title'), 'FontName', fontname, ...
    'FontSize', fontsize(1));
set(get(axs, 'XLabel'), 'FontName', fontname, ...
    'FontSize', fontsize(1));
set(get(axs, 'YLabel'), 'FontName', fontname, ...
    'FontSize', fontsize(1));
set(get(axs, 'ZLabel'), 'FontName', fontname, ...
    'FontSize', fontsize(1));
set(axs, 'FontName', fontname, ...
    'FontSize', fontsize(2));

set(axs, 'Units', 'inches');
set(axs, 'Position', [border(1:2), (figsize - border(1:2) - border(3:4))]);

return;
