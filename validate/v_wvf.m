%% Validate calculations with the wavefront toolbox
% 
% Deprecated - see v_opticsVWF and v_opticsFlare
%
%  Use the wavefront toolbox for calculations with shift-invariant
%  optics and flare.
%

%% Diffraction limited case

wvf = wvfCreate;

% This increases the spatial resolution.
%{
fieldsize = wvfGet(wvf,'fieldsizemm');
wvf = wvfSet(wvf,'fieldsizemm',2*fieldsize);
%}
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20,'airydisk');

%{
ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');
%}

%%  Now with a little defocus
wvf = wvfCreate;
wvf = wvfSet(wvf,'zcoeffs',0.5,{'defocus'});
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'psf','um',550,20);

%{
ieNewGraphWin([], 'wide');
subplot(1,3,1); wvfPlot(wvf,'image pupil amp','um',550,'no window');
subplot(1,3,2); wvfPlot(wvf,'image pupil phase','um',550,'no window');
subplot(1,3,3); wvfPlot(wvf,'image wavefront aberrations','um',550,'no window');
%}

%%





%%