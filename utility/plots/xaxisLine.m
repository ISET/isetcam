function xaxisLine(ax)
% Draw a dark line along the x-axis of a graph
%
% Synopsis
%   xaxisLine(ax);
%
%
% See also
%   identityLine
%

% Examples:
%{
xaxisLine(gca);
%}

%%
if ieNotDefined('ax'), ax = gca; end

%%
xlim = get(ax, 'xlim');

% Here's the line from (m1,m1) to (m2,m2).  Both of these points are on
% the identity line (x = y).
p = line([xlim(1), xlim(2)], [0, 0], 'color', [.3, .3, .3], 'linestyle', '--');


% Set line properties.  These probably want to come in as an argument
set(p, 'linewidth', 2);
grid on

end