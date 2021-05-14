function [fig,f,jx,jy] = iePlotJitter(x,y,f,fig,pSymbol)
%Plot points with a little added noise to show multiple repeats
%
%    [fig,f,jx,jy]  = iePlotJitter(x,y,[f],[fig],[pSymbol])
%
% f:      Random jitter amount.  Default is 1/200 of the larger range.
% fig:    Which figure - use fig<0 to suppress plotting
% jx,jy:  Jittered xy values used for plotting
%         These can also be retrieved by u = get(gca,'userdata');
%
% Example:
%
%

if ieNotDefined('f'),
    mx = max((max(x(:)) - min(x(:))),max(y(:))-min(y(:)));
    f = mx/200;
end
if ieNotDefined('fig'),     fig = vcNewGraphWin; end
if ieNotDefined('pSymbol'), pSymbol = '.k'; end

% Make the randomly perturned points
N = length(x);
jx = x(:) + rand(N,1)*f;
jy = y(:) + rand(N,1)*f;

% Plot them as dots.  I guess the symbols should be a parameter
if fig>0
    figure(fig), plot(jx,jy,pSymbol)
    
    % Store them and return
    pts.jx = jx; pts.jy = jy;
    set(gca,'userdata',pts);
end

return
