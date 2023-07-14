function psfPlot(fig,uData)
% [uData, fig] = oiPlot(oi,'psf', ...)
% Then call this.
%
% Adjust the spacing for the plotted PSF.  Maybe this should be called
% psfPlot
%
figure(fig);

pRange = ceil(max(uData.x(:)));
tMarks = round(linspace(-pRange,pRange,5));
set(gca,'xlim',[-pRange pRange],'xtick',tMarks);
set(gca,'ylim',[-pRange pRange],'ytick',tMarks);

end
