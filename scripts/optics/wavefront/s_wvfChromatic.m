%% Create different diffraction limited cases
%
% Include human LCA and not
% Different pupil sizes
%
% See also
%  oiGet(oi,'optics psf data')
%  oiGet(oi,'optics psf xaxis')
%  oiPlot() ...

%%
ieInit;

%%  The only time this seems to be right is for 17 mm focal length
%
% Maybe because the umPerDegree is wrong?

% wList = linspace(400,700,7);

wList = 400:10:700;
wvf = wvfCreate('wave',wList);    % Default wavefront 5.67 fnumber

flengthMM = 17; flengthM = flengthMM*1e-3;
fNumber = 3; 
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);
% wvfGet(wvf,'measured wavelength')

% Turn on LCA.  Compute.
wvf = wvfComputePSF(wvf,'lca',true,'force',true);
%{
tmp1 = oiGet(wvf2oi(wvf),'optics otf',700);
ieNewGraphWin; mesh(ifftshift(abs(tmp1)));

tmp2 = wvfGet(wvf,'otf',700);
ieNewGraphWin; mesh(ifftshift(abs(tmp1)));

tmp3 = oiGet(oi,'optics otf',700);
ieNewGraphWin; mesh(ifftshift(abs(tmp1)));

ieNewGraphWin; plot(tmp1(:),tmp2(:),'.');
identityLine;
%}
nPanels = ceil(sqrt(numel(wList)));

ieNewGraphWin; ii = 1;
for ww = wList
    wvf = wvfSet(wvf,'calc wave',ww);
    wvf = wvfComputePSF(wvf,'lca',true,'force',true);

    subplot(nPanels,nPanels,ii)
    wvfPlot(wvf,'image psf space','um',ww,20,'airy disk','no window');
    ii = ii + 1;

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(ww,fNumber,'units','um','diameter',true);
    title(sprintf('Wave %.0f AiryD %.2f',ww,AD));
end

%% Run on an image without LCA
sceneGrid = sceneCreate('grid lines',384,64);
sceneGrid = sceneSet(sceneGrid,'fov',1);

oi = wvfApply(sceneGrid,wvf);

oi = wvf2oi(wvf,'model','diffraction limited');
oi = oiCompute(oi,sceneGrid);
oiWindow(oi);

wvf = wvfComputePSF(wvf,'lca',true,'force',true);
oi = wvf2oi(wvf,'model','diffraction limited');
oi = oiCompute(oi,sceneGrid);
oiWindow(oi);


%% The fnumber is converted correctly if we set the model correctly.

% The default is humanmw.  But it is best to be explicit and in this
% case use 'diffraction limited'.
oi = wvf2oi(wvf,'model','diffraction limited');
assert(wvfGet(wvf,'fnumber') == oiGet(oi,'optics fnumber'))

thisWave = 400;
[~,fig] = oiPlot(oi,'psf',[],thisWave);
psfPlotrange(fig,oi);

thisWave = 700;
oiPlot(oi,'psf',[],thisWave);
psfPlotrange(fig,oi);



%% Measured and calc waves differ, but no LCA in this section
wvf = wvfSet(wvf,'calc wave',550);
wvf = wvfSet(wvf,'measured wave',550);

% BW:  We should be able to specify the LCA, not only use human.
pupilMM = linspace(1.5,8,4);
ieNewGraphWin; ii = 1;
for pp = pupilMM
    wvf = wvfSet(wvf,'calc pupil diameter',pp);
    wvf = wvfComputePSF(wvf,'lca',false,'force',true);

    subplot(2,2,ii)
    wvfPlot(wvf,'image psf space','um',thisWave,5,'airy disk','no window');
    ii = ii+1;

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
    title(sprintf('Pupil %.2f Airy %.2f',pp,AD));
end

%% Measured and calc waves differ, with LCA

% Not working with different wavelength.  It was - so let's figure it out.
thisWave = 600;
wvf = wvfSet(wvf,'calc wave',thisWave);

ieNewGraphWin; ii = 1;

for pp = pupilMM    
    wvf = wvfSet(wvf,'calc pupil diameter',pp);
    wvf = wvfComputePSF(wvf,'lca',true,'force',true);
    
    subplot(2,2,ii)
    wvfPlot(wvf,'image psf space','um',thisWave,10,'airy disk','no window');
    ii = ii + 1;

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
    title(sprintf('Wave %.0f Pupil %.1f AiryD %.2f',thisWave,pp,AD));
end
%% Series of wavelengths with human LCA

wvf = wvfSet(wvf,'calc pupil diameter',3);
wList = linspace(400,700,4);
fig = ieNewGraphWin; ii = 1;
for ww = wList
    wvf = wvfSet(wvf,'calc wave',ww);
    wvf = wvfComputePSF(wvf,'lca',true,'force',true);

    subplot(2,2,ii)
    wvfPlot(wvf,'image psf space','um',ww,20,'airy disk','no window');
    ii = ii + 1;

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(ww,fNumber,'units','um','diameter',true);
    title(sprintf('Wave %.0f AiryD %.2f',ww,AD));
end

%%  Change the spatial resolution via um per degree.

% This is unfortunate.  It appears that when we change um per degree,
% we change the spatial spread of the PSF.  

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


