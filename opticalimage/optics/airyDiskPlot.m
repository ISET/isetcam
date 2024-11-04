function airyDiskPlot(fig,uData)
% Plots the first zero crossing of the Airy disk on a figure
%
% Synoposis
% [uData, fig] = airyDiskPlot(oi,'psf', ...)
% Then call this.
%
% Adjust the spacing for the plotted PSF.  Maybe this should be called
% psfPlot
%

error('Deprecated.')

figure(fig);

pRange = ceil(max(uData.x(:)));
tMarks = round(linspace(-pRange,pRange,5));
set(gca,'xlim',[-pRange pRange],'xtick',tMarks);
set(gca,'ylim',[-pRange pRange],'ytick',tMarks);

end
