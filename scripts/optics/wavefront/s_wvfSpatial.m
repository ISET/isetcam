%% s_wvfSpatial
% 
% Can we control the sampling spatial resolution?
%

ieInit;

%%
wvf = wvfCreate;    % Default wavefront 5.67 fnumber
thisWave = wvfGet(wvf,'wave');

fNumber = 4;
flengthM = 7e-3; 
flengthMM = flengthM*1e3;
wvf = wvfSet(wvf,'measured pupil diameter',20);
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

wvf = wvfSet(wvf,'focal length',flengthM/2);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

wvf = wvfSet(wvf,'focal length',flengthM*2);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

%% Cross section through the wvf psf
psf  = wvfGet(wvf,'psf',550);
samp = wvfGet(wvf,'psf spatial samples','um',550);

% X axis
foo = interp2(samp,samp,psf,0,samp);
radius = airyDisk(550,wvfGet(wvf,'fnumber'),'units','um','diameter',false);
ieNewGraphWin;
plot(samp,foo,'ko-'); grid on;
hold on; plot([-radius, radius],[0 0],'ro');
set(gca,'xlim',[-20 20]);

%% Loop a bit
fl = linspace(5,20,4)*1e-3;
for ff = fl
    wvf = wvfSet(wvf,'focal length',ff);
    wvf = wvfComputePSF(wvf,'force',true,'lca',false);
    wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

    oiD = wvf2oi(wvf,'model','diffraction limited');
    [~, fig] = oiPlot(oiD,'psf',thisWave); psfPlotrange(fig,oiD);
    oiPlot(oiD,'psf xaxis',thisWave);
end

%% This one is like the one above, but shifted slightly negative
oi = wvf2oi(wvf);

% Show it via OI
uData = oiGet(oi,'optics psf xaxis'); 

fig = ieNewGraphWin;
plot(uData.samp,uData.data,'-k');
grid on; set(gca,'xlim',[-5 5],'xtick',-5:1:5);

oi = oiCreate('diffraction limited');
oi = oiSet(oi,'fnumber',wvfGet(wvf,'fnumber'));

uData = oiPlot(oi,'psf550');
samp = uData.x(1,:);
foo = interp2(uData.x,uData.y,uData.psf,0,samp);

figure(fig);
hold on; plot(samp,foo,'o');
grid on; set(gca,'xlim',[-5 5],'xtick',-5:1:5);

%%