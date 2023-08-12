function thisLine = xaxisLine(ax,yval)
% Draw a dark line parallel to the x-axis of a graph
%
% Synopsis
%   xaxisLine(ax,val);
%
% Brief description
%   By default this is along the y=0 axis.  You can choose a different y
%   value by the 2nd argument
%
% Input
%  axes -   Default is gca
%  yval  -  Default is y = 0
%
% Output
%  thisLine - Handle to the plotted line
%
% See also
%   identityLine
%{
xaxisLine(gca,0.5);
%}

%%
if ieNotDefined('ax'), ax = gca; end
if ieNotDefined('yval'), yval = 0; end

%%
xlim = get(ax, 'xlim');

% Here's the line from (m1,m1) to (m2,m2).  Both of these points are on
% the identity line (x = y).
thisLine = line([xlim(1) xlim(2)], [yval yval], 'color', [.3 .3 .3], 'linestyle', '--');


% Set line properties.  These probably want to come in as an argument
set(thisLine,'linewidth',2);
grid on

end