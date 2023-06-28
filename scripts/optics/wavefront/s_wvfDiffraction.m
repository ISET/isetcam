%% Create different diffraction limited cases
%
% Include human LCA and not
% Different pupil sizes
%
% See also
%  
%%
ieInit;

%%
wvf = wvfCreate;    % Default wavefront 5.67 fnumber

flengthM = 7e-3;
thisWave = 600;
wvf = wvfSet(wvf,'measured pupil diameter',20);
wvf = wvfSet(wvf,'focal length',flengthM);

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