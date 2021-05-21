function hdl = plotDisplayGamut(ip)
%Plot the display gamut on a CIE xy graph
%
%   hdl = plotDisplayGamut(vci)
%
% The gamut is shown within the spectrum locus of the CIE 1931
% xy-chromaticity diagaram.  The display primaries are plotted as circles.
% The gamut is the triangle that connects the three primary points.
%
% Example:
%   plotDisplayGamut;
%
% See also: plotDisplayColor
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('ip'), ip = vcGetObject('ip'); end

xy = ipGet(ip,'display primaries xy');
L =  ipGet(ip,'display max luminance');

hdl = chromaticityPlot(xy);
hold on; line(xy(:,1),xy(:,2),'color','k');
line(xy([3,1],1),xy([3,1],2),'color','k');
hold off

xlabel('x-chromaticity');
ylabel('y-chromaticity');
title(sprintf('Gamut (%.0f cd/m^2 peak)',L));

data.xy = xy;
set(gca,'userdata',data);

return
