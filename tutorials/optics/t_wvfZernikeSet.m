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

wvf = wvfCreate;
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',550,20);
oi = wvf2oi(wvf,'model','diffraction limited');

%% Make an ISET optical image

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Diffraction');
oiWindow(oi);

%% Change the defocus coefficient

wvf = wvfCreate;
D = [0 1 2];    % Amount of defocus
for ii=1:length(D)
    wvf = wvfSet(wvf,'zcoeffs',D(ii),{'defocus'});
    wvf = wvfComputePSF(wvf);
    wvfPlot(wvf,'2d psf space','um',550,20);  % PSF in micron scale
    % wvfPlot(wvf,'2d otf','mm',550);  % Lines per millimeter
    
    oi = wvf2oi(wvf,'model','wvf human');
    oi = oiCompute(oi,scene);
    oi = oiSet(oi,'name',sprintf('Human D %.1f',D(ii)));
    oiWindow(oi);
end

%% Increase astigmatism combined with some defocus

wvf = wvfCreate();  % Create the struct
A = [-1, 0, 1];     % Amount of astigmatism
for ii=1:length(A)
    wvf = wvfSet(wvf,'zcoeffs',[2, A(ii)],{'defocus','vertical_astigmatism'});
    wvf = wvfComputePSF(wvf);
    wvfPlot(wvf,'2d psf space','um',550,20);
    oi = wvf2oi(wvf,'model','wvf human');
    oi = oiCompute(oi,scene);
    oi = oiSet(oi,'name',sprintf('Human D %.1f, A %.1f',0.5,A(ii)));
    oiWindow(oi);
end

%%



