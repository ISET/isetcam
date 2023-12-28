function wvfSummarize(wvf)
% Print a summary of key wavefront struct parameters
%
%

fprintf('\nwavefront struct name: %s\n',wvf.name);
fprintf('-------------------\n');

fprintf('n samples\t %d\n',wvf.nSpatialSamples);
fprintf('f number\t %f\n',wvfGet(wvf,'fnumber'))
fprintf('f length\t %f\t mm\n', wvfGet(wvf,'focal length','mm'));
fprintf('um per deg\t %f\t um\n', wvfGet(wvf,'um per degree'));

fprintf('pupil diameter\t %f\t mm\n', wvfGet(wvf,'calc pupil diameter','mm'));

fprintf('zCoeffs:\t %f\n',wvfGet(wvf,'zcoeffs'));
fprintf('zDiameter:\t %f\t mm\n',wvfGet(wvf,'z pupildiameter','mm'));

otfSupport = wvfGet(wvf,'otf support','mm');
fprintf('Max OTF freq\t %f\t cyc/mm\n',max(otfSupport));
fprintf('OTF spacing\t %f\t cyc/mm\n',otfSupport(2)-otfSupport(1));

psfSupport = wvfGet(wvf,'psf support','um');
fprintf('Max PSF support\t %f\t um\n',max(psfSupport));
fprintf('PSF spacing\t %f\t um\n',psfSupport(2)-psfSupport(1));

fprintf('-------------------\n');

end