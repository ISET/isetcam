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

wvf = wvfCreate;    % Default wavefront 5.67 fnumber

flengthMM = 6; flengthM = flengthMM*1e-3;
fNumber = 3; thisWave = 550;
wvf = wvfSet(wvf,'measured pupil diameter',20);
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);
wvfPlot(wvf,'2d psf space','um',thisWave,10,'airy disk');
AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
title(sprintf("fNumber %.2f Wave %.0f Airy Diam %.2f",wvfGet(wvf,'fnumber'),wvfGet(wvf,'wave'),AD));

%% The fnumber is converted correctly if we set the model correctly.
%
% The default is humanmw.  But it is best to be explicit and in this
% case use 'diffraction limited'.
oi = wvf2oi(wvf,'model','diffraction limited');
% oi = wvf2oi(wvf,'model','humanmw');

uData = oiPlot(oi,'psf',thisWave);
assert(wvfGet(wvf,'fnumber') == oiGet(oi,'optics fnumber'))

AD = airyDisk(oiGet(oi,'wave'),oiGet(oi,'optics fnumber'),'units','um','diameter',true);
pRange = ceil(max(uData.x(:)));
tMarks = round(linspace(-pRange,pRange,5));
set(gca,'xlim',[-pRange pRange],'xtick',tMarks);
set(gca,'ylim',[-pRange pRange],'ytick',tMarks);
title(sprintf("fNumber %.2f Wave %.0f Airy Diam %.2f",oiGet(oi,'optics fnumber'),thisWave,AD));

%% Let's plot a line through the origin for detail.
oiPlot(oi,'psf xaxis',[],thisWave,'um');

%% Measured and calc waves differ, but no LCA in this section
wvf = wvfSet(wvf,'calc wave',thisWave);
wvf = wvfSet(wvf,'measured wave',550);

% BW:  We should be able to specify the LCA, not only use human.
pupilMM = [1, 3, 6, 9];
for pp = pupilMM
    
    wvf = wvfSet(wvf,'calc pupil diameter',pp);
    wvf = wvfComputePSF(wvf,'lca',false,'force',true);
    wvfPlot(wvf,'image psf space','um',thisWave,20,'airy disk');
    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
    title(sprintf('Pupil %.2f Airy %.2f',pp,AD));

end

%% Measured and calc waves differ, with LCA

pupilMM = [1, 3, 6, 9];
for pp = pupilMM
    
    wvf = wvfSet(wvf,'calc pupil diameter',pp);
    wvf = wvfComputePSF(wvf,'lca',true,'force',true);
    wvfPlot(wvf,'image psf space','um',thisWave,20,'airy disk');
    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
    title(sprintf('Wave %.2f Airy %.2f',pp,AD));

end
%% Series of wavelengths with human LCA

wvf = wvfSet(wvf,'calc pupil diameter',3);
for ww = 400:50:700
    wvf = wvfSet(wvf,'calc wave',ww);
    wvf = wvfComputePSF(wvf,'lca',true,'force',true);
    wvfPlot(wvf,'image psf space','um',ww,20,'airy disk');
    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(ww,fNumber,'units','um','diameter',true);
    title(sprintf('Pupil %.2f Airy %.2f',ww,AD));
end

%%  Change the spatial resolution via um per degree.

% This is unfortunate.  It appears that when we change um per degree,
% we change the spatial spread of the PSF.  

wvf = wvfCreate;    % Default wavefront 5.67 fnumber


fNumber = 4;
flengthM = 7e-3; 
flengthMM = flengthM*1e3;
wvf = wvfSet(wvf,'measured pupil diameter',20);
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

airyDisk(550,wvfGet(wvf,'fnumber'),'diameter',true,'units','um')

% This does not seem right to me.  It is about twice the diameter.
% Suspect there is a factor of two wrong somewhere.
umPerDeg = tand(1)*wvfGet(wvf,'focal length','um');
wvfSet(wvf,'um per degree',umPerDeg);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',550,20,'airy disk');
airyDisk(550,wvfGet(wvf,'fnumber'),'diameter',true,'units','um')

wvf = wvfSet(wvf,'umperdegree',300);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',550,20,'airy disk');


% This does not seem right to me.
wvf = wvfSet(wvf,'umperdegree',300);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',550,20,'airy disk');

% The mis-match is different if we change this
wvf = wvfSet(wvf,'umperdegree',150);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',550,20,'airy disk');

% Again.  This starts to look more like Zhenyi's PSF.
wvf = wvfSet(wvf,'umperdegree',600);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',550,20,'airy disk');

psf = wvfGet(wvf,'psf',550);
samp = wvfGet(wvf,'psf spatial samples','um',550);
foo = interp2(samp,samp,psf,0,samp);
ieNewGraphWin;
plot(samp,foo,'o');
grid on;
set(gca,'xlim',[-20 20]);

%% Not great.

wvf = wvfCreate;    % Default wavefront 5.67 fnumber

flengthM = 7e-3;
wvf = wvfSet(wvf,'measured pupil diameter',20);
wvf = wvfSet(wvf,'calc pupil diameter',3);
wvf = wvfSet(wvf,'focal length',flengthM);

airyDisk(550,wvfGet(wvf,'fnumber'),'diameter',true)

wvf = wvfComputePSF(wvf);

psf = wvfGet(wvf,'psf',550);
samp = wvfGet(wvf,'psf spatial samples','um',550);
foo = interp2(samp,samp,psf,0,samp);

lineFig = ieNewGraphWin;
plot(samp,foo,'o');
grid on; set(gca,'xlim',[-5 5],'xtick',-5:1:5);

%% This one is like the one above, but shifted slightly negative
oi = wvf2oi(wvf);

% Show it via OI
uData = oiGet(oi,'optics psf xaxis'); 
ieNewGraphWin;
plot(uData.samp,uData.data,'-k');
grid on; set(gca,'xlim',[-5 5],'xtick',-5:1:5);


%%  This one is correct.

oi = oiCreate('diffraction limited');
oi = oiSet(oi,'fnumber',wvfGet(wvf,'fnumber'));

uData = oiPlot(oi,'psf550');
samp = uData.x(1,:);
foo = interp2(uData.x,uData.y,uData.psf,0,samp);

figure(lineFig);
hold on; plot(samp,foo,'o');
grid on; set(gca,'xlim',[-5 5],'xtick',-5:1:5);

%%


