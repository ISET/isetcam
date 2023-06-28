%% Create different diffraction limited cases

%%
ieInit;

%%
wvf = wvfCreate;    % Default wavefront 5.67 fnumber

flengthM = 7e-3;
thisWave = 600;
wvf = wvfSet(wvf,'measured pupil diameter',20);
wvf = wvfSet(wvf,'focal length',flengthM);

% This way, no LCA included
wvf = wvfSet(wvf,'calc wave',thisWave);
wvf = wvfSet(wvf,'measured wave',thisWave);

% BW:  We should be able to specify the LCA, not only use human.
pupilMM = [1, 3, 6, 9];
for pp = pupilMM
    
    wvf = wvfSet(wvf,'calc pupil diameter',pp);
    wvf = wvfComputePSF(wvf,'lca',false);
    wvfPlot(wvf,'image psf space','um',thisWave,20,'airy disk');
    fNumber = wvfGet(wvf,'fnumber');
    AD = airyDisk(thisWave,fNumber,'units','um','diameter',true);
    title(sprintf('Pupil %.2f Airy %.2f',pp,AD));

end

%%