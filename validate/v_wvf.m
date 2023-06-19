%% Validate calculations with the wavefront toolbox
% 


wvf = wvfCreate;
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20);

ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');


wvf = wvfSet(wvf,'zcoeffs',1,{'defocus'});
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20);

ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');

%% We want to start with a computed wvf, but then adjust the amplitude

% Basically, we want to reset the amplitude and then call this.
wvf = wvfComputePupilFunction(wvf);
