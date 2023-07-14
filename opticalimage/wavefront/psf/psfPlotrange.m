function psfPlotrange(fig,oi,thisWave)
% Set the plot range of an oiPlot 'psf' figures
%
% For example
%   
%
% See also
%   airyDisk, v_opticsFlare, s_wvfDiffraction

if isempty(fig), fig = gcf; end
figure(fig);

if notDefined('thisWave'), thisWave = oiGet(oi,'wave'); end
if numel(thisWave) > 1, thisWave = 550; end

AD = airyDisk(thisWave,oiGet(oi,'optics fnumber'),'units','um','diameter',false);

% Make the range 10, 20, 30 ...
pRange = 10 * ceil( 2.5*AD / 10);

tMarks = round(linspace(-pRange,pRange,5));
set(gca,'xlim',[-pRange pRange],'xtick',tMarks);
set(gca,'ylim',[-pRange pRange],'ytick',tMarks);
title(sprintf("F# %.2f Wave %.0f Airy Radius %.2f",oiGet(oi,'optics fnumber'),thisWave,AD));

end
