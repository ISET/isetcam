function p = iePlot(varargin)
% Working on a method to eliminate all those ieNewGraphWin calls
%
% I created ieFigure.  This method takes the plot() arguments and
% passes them along after opening up a figure.

ieFigure;
p = plot(varargin{:});

end
