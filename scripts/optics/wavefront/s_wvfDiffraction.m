%% Illustrate diffraction limited cases
%
% * Different pupil sizes
% * Different focal lengths
% * LCA and no LCA
%
% See also
%  oiGet(oi,'optics psf data'), oiGet(oi,'optics psf xaxis')
%  oiPlot(), wvfPlot()
%

%%
ieInit;

%% The Airy Disk matches 

wvf = wvfCreate;    % Default wavefront 5.67 fnumber

flengthMM = 6; flengthM = flengthMM*1e-3;
fNumber = 3; thisWave = 550;
% wvf = wvfSet(wvf,'measured pupil diameter',20);  % Make room for pupil sizes
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfCompute(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,10,'airy disk');
AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
title(sprintf("fNumber %.2f Wave %.0f Airy Diam %.2f",wvfGet(wvf,'fnumber'),wvfGet(wvf,'wave'),AD));

%% The fnumber is converted correctly from wvf to oi
%
% And the Airy disk matches after conversion

oi = wvf2oi(wvf);
assert(wvfGet(wvf,'fnumber') == oiGet(oi,'optics fnumber'))

[~, fig] = oiPlot(oi,'psf',thisWave);
psfPlotrange(fig,oi);

%% A line through the origin for detail

% The little red circles are the expected Airy Disk.
oiPlot(oi,'psf xaxis',[],thisWave,'um');

%% No LCA in this section
%
% Shifting the pupil size from small to large.

pupilMM = linspace(1.5,8,4);
ieNewGraphWin;
tiledlayout(2,2);
for pp = pupilMM
    wvf = wvfSet(wvf,'calc pupil diameter',pp);
    wvf = wvfCompute(wvf);

    nexttile;
    wvfPlot(wvf,'image psf space','um',thisWave,5,'airy disk','no window');    

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
    title(sprintf('Pupil %.2f Airy %.2f',pp,AD));
end

%% Same but make the calc wave from measured

thisWave = 400;
wvf = wvfSet(wvf,'calc wave',thisWave);

pupilMM = linspace(1.5,8,4);
ieNewGraphWin;
tiledlayout(2,2);
for pp = pupilMM
    wvf = wvfSet(wvf,'calc pupil diameter',pp);
    wvf = wvfCompute(wvf);

    nexttile;
    wvfPlot(wvf,'image psf space','um',thisWave,5,'airy disk','no window');    

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
    title(sprintf('Pupil %.2f Airy %.2f',pp,AD));
end

%% Series of wavelengths with human LCA

wvf = wvfSet(wvf,'calc pupil diameter',3);

thisWave = 550;
wvf = wvfSet(wvf,'calc wave',thisWave);
wList = linspace(400,700,4);

ieNewGraphWin;
tiledlayout(2,2);

for ww = wList
    wvf = wvfSet(wvf,'calc wave',ww);
    wvf = wvfCompute(wvf,'human lca',true);

    nexttile;
    wvfPlot(wvf,'image psf space','um',ww,20,'airy disk','no window');    

    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(ww,fNumber,'units','um','diameter',true);
    title(sprintf('Wave %.0f AiryD %.2f',ww,AD));
end

%%  Change the spatial resolution via um per degree.

wvf = wvfCreate;    % Default wavefront 5.67 fnumber
thisWave = wvfGet(wvf,'wave');

fNumber = 4;
flengthM = 7e-3; 
flengthMM = flengthM*1e3;
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);
wvf = wvfCompute(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

wvf = wvfSet(wvf,'focal length',flengthM/2);
wvf = wvfCompute(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

wvf = wvfSet(wvf,'focal length',flengthM*2);
wvf = wvfCompute(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

%% Loop on focal length a bit

fl = linspace(5,20,4)*1e-3;
for ff = fl
    wvf = wvfSet(wvf,'focal length',ff);
    wvf = wvfCompute(wvf);
        
    wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');

    oiD = wvf2oi(wvf);
    [~, fig] = oiPlot(oiD,'psf',[],thisWave); psfPlotrange(fig,oiD);
    
    oiPlot(oiD,'psf xaxis',thisWave);
end

%%


