function wvfSummarize(wvf)
% Print a summary of key wavefront struct parameters
%
% A tutorial is in t_wvfOverview.mlx
%

% Test with
% wvf = wvfCreate('wave',[500:50:700]);

wave = wvfGet(wvf,'wave');

fprintf('\nwavefront struct name: %s\n',wvf.name);
if numel(wave) > 1, fprintf('Summarizing for wave %d nm.\n',wave(1));end
fprintf('-------------------\n');

fprintf('f number\t %f\n',wvfGet(wvf,'fnumber'))
fprintf('f length\t %f\t mm\n', wvfGet(wvf,'focal length','mm'));
fprintf('um per deg\t %f\t um\n', wvfGet(wvf,'um per degree'));
fprintf('calc pupil diam\t %f\t mm\n', wvfGet(wvf,'calc pupil diameter','mm'));

fprintf('\nReference\n------\n')
fprintf('n samples\t %d\n',wvf.nSpatialSamples);
fprintf('ref pupil plane\t %f\t mm\n', wvfGet(wvf,'pupil plane size','mm',wave(1)));
fprintf('ref pupil dx\t %f\t um\n',wvfGet(wvf, 'pupil sample spacing','um'));

fprintf('\nMeasured\n------\n')
zcoeffs = wvfGet(wvf,'zcoeffs');
fprintf('zCoeffs:\t '); fprintf('%.2f ',zcoeffs); fprintf('\n');   
fprintf('zDiameter:\t %f\t mm\n',wvfGet(wvf,'z pupildiameter','mm'));

otfSupport = wvfGet(wvf,'otf support','mm',wave(1));
fprintf('Max OTF freq\t %f\t cyc/mm\n',max(otfSupport));
fprintf('OTF df\t\t %f\t cyc/mm\n',otfSupport(2)-otfSupport(1));

psfSupport = wvfGet(wvf,'psf support','um',wave(1));
fprintf('Max PSF support\t %f\t um\n',max(psfSupport));
fprintf('PSF dx\t\t %f\t um\n',psfSupport(2)-psfSupport(1));

fprintf('-------------------\n');

end