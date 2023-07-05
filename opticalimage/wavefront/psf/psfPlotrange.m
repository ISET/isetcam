function psfPlotrange(fig,oi)
% [uData, fig] = oiPlot(oi,'psf', ...)
%
% Then call this function.
%
% Adjust the spatial support for the plotted PSF.
%
% See also
%   airyDisk, v_opticsFlare, s_wvfDiffraction

if isempty(fig), fig = gcf; end
figure(fig);

thisWave = oiGet(oi,'wave');
if numel(thisWave) > 1, thisWave = 550; end

AD = airyDisk(thisWave,oiGet(oi,'optics fnumber'),'units','um','diameter',false);
pRange = min(ceil(2*AD));

tMarks = round(linspace(-pRange,pRange,5));
set(gca,'xlim',[-pRange pRange],'xtick',tMarks);
set(gca,'ylim',[-pRange pRange],'ytick',tMarks);
title(sprintf("F# %.2f Wave %.0f Airy Radius %.2f",oiGet(oi,'optics fnumber'),thisWave,AD));

end
