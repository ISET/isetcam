function p = iePlot(varargin)
% Working on a method to eliminate all those ieNewGraphWin calls
%
%

ieNewGraphWin;

p = plot(varargin{:});

end
