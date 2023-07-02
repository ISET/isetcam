%% Conversion tests from wvf to oi
%
% * Create a standard wvf and compare the PSF (diffraction limited)
% * Blur and compare again
% * Try with different wavelengths
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
fNumber = 3; thisWave = 550;
% wvf = wvfSet(wvf,'measured pupil diameter',20);  % Make room for pupil sizes
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);
wData = wvfPlot(wvf,'2d psf space','um',thisWave,10,'airy disk');
AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
title(sprintf("fNumber %.2f Wave %.0f Airy Diam %.2f",wvfGet(wvf,'fnumber'),wvfGet(wvf,'wave'),AD));

%% Slice through the wvf psf

wvfPlot(wvf,'psf xaxis','um',550,10);
hold on;

% Convert to OI and plot the same slice
oi = wvf2oi(wvf,'model','wvf human');
uData = oiGet(oi,'optics psf xaxis'); 
plot(uData.samp,uData.data,'-go');

%% Now create from scratch.

oi = oiCreate('diffraction limited');
oi = oiSet(oi,'fnumber',wvfGet(wvf,'fnumber'));

uData = oiPlot(oi,'psf550');
samp = uData.x(1,:);
foo = interp2(uData.x,uData.y,uData.psf,0,samp);

figure(fig);
hold on; plot(samp,foo,'o');
grid on; set(gca,'xlim',[-5 5],'xtick',-5:1:5);