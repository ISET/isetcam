%% Wavefront aberrations and the Zernike polynomial
%
% We illustrate the effects on the PSF of adjusting various
% coefficients. This is example is for defocus and astigmatism and
% black/white image.
%
% https://en.wikipedia.org/wiki/Zernike_polynomials
%
% See also
%  wvf2oi, wvfCreate, wvfCompute
%

%%
ieInit;

%% Create a test scene

% Choose parameters that make it easy to see the defocus and
% astigmatism.
params = FOTParams;
params.blockSize = 64;   % Increase spatial sample
params.angles = [0, pi/4, pi/2];
scene = sceneCreate('freq orient',params);

% Small FOV
scene = sceneSet(scene,'fov',5);

%% Create wavefront object and convert it to an optical image object

% This method attaches the human lens to the optics
[oi, wvf] = oiCreate('wvf human');
wvfPlot(wvf,'psf','unit','um','wave',550,'plotrange',20);  % PSF in micron scale
oiPlot(oi,'psf');

%% Make an ISET optical image

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Diffraction');

% OI is quite yellow
oiWindow(oi);

%% Change the defocus coefficient
%
% Units are microns.  
wvf = wvfCreate('wave',sceneGet(scene,'wave'));
D = [0 1 2];    
for ii=1:length(D)
    wvf = wvfSet(wvf,'zcoeffs',D(ii),{'defocus'});
    wvf = wvfSet(wvf, 'customLca', 'human');
    wvf = wvfCompute(wvf);
    wvfPlot(wvf,'psf','unit','um','wave',550,'plotrange',40);  % PSF in micron scale
    oi = wvf2oi(wvf,'human lens',true);
    oi = oiCompute(oi,scene);
    oi = oiSet(oi,'name',sprintf('Human defocus D %.1f microns',D(ii)));
    oiWindow(oi);
end

%% Increase astigmatism combined with some defocus

% This time, I did not add the human lens.  So the image looks more white.
wvf = wvfCreate('wave',sceneGet(scene,'wave'));
A = [-1, 0, 1];     % Amount of astigmatism
for ii=1:length(A)
    wvf = wvfSet(wvf,'zcoeffs',[2, A(ii)],{'defocus','vertical_astigmatism'});
    wvf = wvfSet(wvf, 'customLca', 'human');
    wvf = wvfCompute(wvf);
    wvfPlot(wvf,'psf','unit','um','wave',550,'plotrange',40);  % PSF in micron scale
    oi = oiCompute(wvf,scene);
    oi = oiSet(oi,'name',sprintf('Human D %.1f microns, A %.1f microns',0.5,A(ii)));
    oiWindow(oi);
end

%%



