function thisLine = yaxisLine(ax,xval)
% Draw a dark line parallel to the y-axis of a graph
%
% Synopsis
%   yaxisLine(ax,val);
%
% Brief description
%   By default this is along the x=0 axis.  You can choose a different x
%   value by the 2nd argument
%
% Input
%  axes -   Default is gca
%  xval  -  Default is y = 0
%
% Output
%  thisLine - Handle to the plotted line
%
% See also
%   identityLine, xaxisLine

% Example:
%{
ieNewGraphWin;
yaxisLine(gca,0.5);
%}

%%
if ieNotDefined('ax'), ax = gca; end
if ieNotDefined('xval'), xval = 0; end

%%
ylim = get(ax, 'ylim');

% Here's the line from (m1,m1) to (m2,m2).  Both of these points are on
% the identity line (x = y).
thisLine = line([xval xval], [ylim(1) ylim(2)], 'color', [.3 .3 .3], 'linestyle', '--');


% Set line properties.  These probably want to come in as an argument
set(thisLine,'linewidth',2);
grid on

end