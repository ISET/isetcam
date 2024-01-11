function psfPlotrange(fig,oi,thisWave)
% Set the plot range of a figure created by oiPlot 'psf'
%
% Brief
%   This helps see the details of the PSF.  It sets the axis limits to
%   a multiple (2.5 times) of the Airy Disk size.  It only uses the
%   fnumber from the oi.
%
% Synopsis
%   psfPlotrange(fig,oi,thisWave)
%
% Inputs
%   fig  - Figure handle to adjust
%   oi   - Optical image
%   thisWave - Which wavelength
%
% Optional key/val
%
% Outputs
%  N/A
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
