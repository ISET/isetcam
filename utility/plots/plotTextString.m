function t = plotTextString(str,position,delta,fontSize)
%
%   t = plotTextString(str,[position='ur'],[delta=0.2],[fontSize=12])
%
%   Place a text string on a 2D graph in one of several canonical positions.
%   The background of the text is set to white to make the text visible
%   even if the grid is turned on
%
%   This routine could be generalized to 3D, but it has not yet been.
%
%   Possible positions are:  'ul','ur','ll','lr' for upper left, upper
%   right, lower left, and lower right.
%
% Example:
%  txt = 'Hello World';
%  t = plotTextString(txt,'ul');
%
% Copyright Imageval Consulting, LLC 2006

% Programming notes:  Positions aren't right.  Fix.
% We need to account for the scale type when setting these positions.  Not
% done properly yet.  Also, it would be better to account for the string
% length, too.  At the very least, we could count the number of letters to
% set the value of delta.

if ieNotDefined('position'), position = 'ur'; end
if ieNotDefined('delta'), delta = [0.2,0.2]; end
if ieNotDefined('fontSize'), fontSize = 12; end

xlim = get(gca,'xlim');
ylim = get(gca,'ylim');

xscale = get(gca,'xscale');
yscale = get(gca,'yscale');

switch lower(position)
    case 'ul'
        x = xlim(1) + (xlim(2) - xlim(1))*delta(1); 
        y = ylim(2) - (ylim(2) - ylim(1))*delta(2);
    case 'll'
        x = xlim(1) + (xlim(2) - xlim(1))*delta(1); 
        y = ylim(1) + (ylim(2) - ylim(1))*delta(2);
    case 'ur'
        x = xlim(2) - (xlim(2) - xlim(1))*delta(1); 
        y = ylim(2) - (ylim(2) - ylim(1))*delta(2);
    case 'lr'
        x = xlim(2) - (xlim(2) - xlim(1))*delta(1); 
        y = ylim(1) + (ylim(2) - ylim(1))*delta(2);
    otherwise
        error('Unknown position');
end

% Display
t = text(x, y, str);
set(t,'Background','w','Fontsize',fontSize);

return;
