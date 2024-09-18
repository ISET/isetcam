%% Wavefront aberrations and the Zernike polynomial
%
% We illustrate the effects on the PSF of adjusting Zernike
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

[oi, wvf] = oiCreate('wvf');
wvfPlot(wvf,'psf','unit','um','wave',550,'plotrange',20);  % PSF in micron scale
oiPlot(oi,'psf');

%% Make an ISET optical image

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Diffraction');

oiWindow(oi);

%% Increase astigmatism combined with some defocus

wvf = wvfCreate('wave',sceneGet(scene,'wave'));
A = [-1, 0, 1];     % Amount of astigmatism
D = 2;
for ii=1:length(A)
    wvf = wvfSet(wvf,'zcoeffs',[D, A(ii)],{'defocus','vertical_astigmatism'});
    wvf = wvfCompute(wvf);
    wvfPlot(wvf,'psf','unit','um','wave',550,'plotrange',40);  % PSF in micron scale
    oi = oiCompute(wvf,scene);
    thisD = oiGet(oi,'wvf','zcoeffs','defocus');
    thisA = oiGet(oi,'wvf','zcoeffs','vertical_astigmatism');
    oi = oiSet(oi,'name',sprintf('Defocus %.1f microns, A %.1f microns',thisD,thisA));
    oiWindow(oi);
end

%% End



