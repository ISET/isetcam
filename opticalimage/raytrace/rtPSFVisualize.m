function rtPSFVisualize(optics, varargin)
%Show a movie of the ray trace pointspread functions at all heights and wavelengths
%
%   rtPSFVisualize(optics,[delay = 0.2])
%
% The image height increase along the x-axis.  The data are displayed for
% one wavelength first, and then the next wavelength. The horizontal axis
% indicates the image height in microns.
%
% Copyright ImagEval, LLC, 2005
%
% See also rtPlot, rtPSFEdit

% Examples:
%{
oi = oiCreate('raytrace');
rtPSFVisualize(oiGet(oi,'optics')); % Fast
rtPSFVisualize(oiGet(oi,'optics'),'delay',0.3);  % Slowed
%}

%%
p = inputParser;
p.addRequired('optics', @isstruct)
p.addParameter('delay', 0.0, @isscalar);
p.parse(optics, varargin{:});

delay = p.Results.delay;

%%
hdl = vcNewGraphWin;
name = opticsGet(optics, 'rtname');
set(hdl, 'name', sprintf('%s: PSF movie', name));
colormap(gray(256));

wave = opticsGet(optics, 'rtpsfwavelength');
imgHgt = opticsGet(optics, 'rtpsffieldheight', 'um');
psf = opticsGet(optics, 'rtpsfdata');

for jj = 1:length(wave)
    for ii = 1:length(imgHgt)
        imagesc(squeeze(psf(:, :, ii, jj)));
        set(gca, 'xticklabel', round(0:16:128 - 64 + imgHgt(ii)), ...
            'xtick', 0:16:128, 'ytick', 0:16:128, 'GridColor', [1, 1, 1], 'GridAlpha', 0.5);
        grid on; axis image
        title(sprintf('Wave %.0f nm:  Field height: %.1f um', wave(jj), imgHgt(ii)));
        drawnow;
        if delay > 0, pause(delay); end
    end
end

return;