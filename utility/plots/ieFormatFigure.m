function ieFormatFigure( fig, fontname, fontsize, figsize, border )
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

error('Deprecated.  Call ieFigureFormat');

end
