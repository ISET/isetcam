%% Conversion tests from wvf to oi
%
% * Create a standard wvf and compare the PSF (diffraction limited)
% * Blur and compare again
% * Try with different wavelengths
% 
% * Current status - there is a dx/2 shift, and the scaling is not quite
% the same as we convert from OTF to PSF. I believe, however, that the OTFs
% are matched.  Check that next.  If they are, then the conversion from OTF
% to PSF is slightly different.
%
% See also
%  s_wvfDiffraction, v_opticsWVF

%%
ieInit;

%%  The only time this seems to be right is for 17 mm focal length
%
% Maybe because the umPerDegree is wrong?

wvf = wvfCreate;    % Default wavefront 5.67 fnumber

flengthMM = 6; flengthM = flengthMM*1e-3;
fNumber = 3;
% wvf = wvfSet(wvf,'measured pupil diameter',20);  % Make room for pupil sizes
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);

%% Slice through the wvf psf

wvfPlot(wvf,'psf xaxis','um',550,10);
hold on;

% Convert to OI and plot the same slice.  With the dx/2 shift, they agree
% except for a small scale factor.  Which I also don't understand
oi = wvf2oi(wvf,'model','wvf human');
uData = oiGet(oi,'optics psf xaxis');
dx = uData.samp(2) - uData.samp(1);
plot(uData.samp+dx/2,uData.data,'-go');

%% Now check across wavelengths 
waves = 400:50:700;
wvf = wvfCreate('wave',waves);    % Default wavefront 5.67 fnumber

flengthMM = 17; flengthM = flengthMM*1e-3;
fNumber = 5.7; thisWave = 550;
% wvf = wvfSet(wvf,'measured pupil diameter',20);  % Make room for pupil sizes
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);

% Loop through the wavelengths, plotting the psf slice
wvfPlot(wvf,'psf xaxis','um',waves(1),10);
hold on;
for ii = 2:numel(waves)
    uData = wvfPlot(wvf,'psf xaxis','um',waves(ii),10,'no window');
    plot(uData.samp,uData.psf,'x');
end

%% Slice through the wvf psf for each wavelength

% Convert to OI and plot the same slice
oi = wvf2oi(wvf,'model','wvf human');

oiPlot(oi,'psf xaxis',waves(1));
hold on;
set(gca,'xlim',[-10 10]);

for ii = 2:numel(waves)
    uData = oiPlot(oi,'psf xaxis',[],waves(ii),'um','no window');
    
    % uData = oiGet(oi,'optics psf xaxis',waves(ii));
    plot(uData.samp,uData.data,'-ko');
end

%% Shift by half dx.  But do not scale

% Good spatial aligning after shifting. But the scaling is not right.
ieNewGraphWin;
for ii = 1:numel(waves)
    wData = wvfGet(wvf,'psf xaxis','um',waves(ii));
    dx = uData.samp(2) - uData.samp(1);
    uData = oiGet(oi,'optics psf xaxis',waves(ii),'um');
    plot(uData.samp + dx/2,uData.data,'-ko'); hold on;
    plot(wData.samp,wData.data,'rx'); hold on;
end
set(gca,'xlim',[-10 10]);

%% Scale the to peak of 1 and shift by half dx.  Then plot together

% Good match after scaling and shifting.  So probably we are computing the
% fft slightly differently or spatially interpolating a little off?
ieNewGraphWin;
for ii = 1:numel(waves)
    wData = wvfGet(wvf,'psf xaxis','um',waves(ii));
    dx = uData.samp(2) - uData.samp(1);
    uData = oiGet(oi,'optics psf xaxis',waves(ii),'um');
    plot(uData.samp + dx/2,uData.data/max(uData.data(:)),'-ko'); hold on;
    plot(wData.samp,wData.data/max(wData.data(:)),'rx'); hold on;
end
set(gca,'xlim',[-10 10]);

%%