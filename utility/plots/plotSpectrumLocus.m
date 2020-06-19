function [p,l] = plotSpectrumLocus(fig)
%
%   [p,l] = plotSpectrumLocus([fig])
%
%  Draw the outline of the spectrum locus on the chromaticity
%  diagram.  It is a white background with a grid.
%
% See also: chromaticityPlot
%
% Example:
%   plotSpectrumLocus;
%
% Copyright Imageval 2003

if ieNotDefined('fig'), ieNewGraphWin; 
else, figure(fig);
end

wave = 370:730;
XYZ = ieReadSpectra('XYZ',wave);

% Here are the shifts in the chromaticity of the display
% as the display intensity shifts
spectrumLocus = chromaticity(XYZ);

% These are the (x,y) points of the spectral lines
p = plot(spectrumLocus(:,1),spectrumLocus(:,2),'k--');
hold on;

% Add a line to close up the outer rim of the spectrum locus curve
l = line([spectrumLocus(1,1),spectrumLocus(end,1)],...
    [spectrumLocus(1,2),spectrumLocus(end,2)], ...
    'Color',[0 0 0],'LineStyle','--');

hold on;
axis equal; grid on

end