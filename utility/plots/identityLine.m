function p = identityLine(ax,threeD)
%Draw an identity line on the current axis
%
%   p = identityLine(ax,threeD)
%
% See also
%    xaxisLine
%
% Example:
%   plot(1:10,randn(1,10),'o')
%   identityLine(gca);
%
% (c) Stanford VISTA Team

%%
if ieNotDefined('ax'), ax = gca; end
if ieNotDefined('threeD'), threeD = false; end

%% Minimum and maximum of axes

if threeD
    xlim = get(ax, 'xlim');
    ylim = get(ax, 'ylim');
    zlim = get(ax, 'zlim');
    
    m1 = min([xlim(1), ylim(1), zlim(1)]); % Smallest of x,y,z
    m2 = max([xlim(2), ylim(2), zlim(2)]); % Biggest of x,y,z
    
    % from x = y = z smallest (m1) to x = y = z biggest (m2).
    p = line([m1 m2], [m1 m2], [m1 m2], 'color', [.5 .5 .5], 'linestyle', '--');
else
    xlim = get(ax, 'xlim');
    ylim = get(ax, 'ylim');
    m1 = min(xlim(1), ylim(1));  % Smallest point on x and y axes
    m2 = max(xlim(2), ylim(2));  % Largest point on x and y axes
    
    % Here's the line from (m1,m1) to (m2,m2).  Both of these points are on
    % the identity line (x = y).
    p = line([m1 m2], [m1 m2], 'color', [.5 .5 .5], 'linestyle', '--');
end

% Set line properties.  These probably want to come in as an argument
set(p,'linewidth',2);
grid on

end