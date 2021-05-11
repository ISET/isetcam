%% Wavefront aberrations and the Zernike polynomial
%
% We illustrate the effects on the PSF of adjusting various
% <https://en.wikipedia.org/wiki/Zernike_polynomials Zernike
% polynomial> coefficients. This is example is for defocus and
% astigmatism and black/white image.  The code relies on the
% wavefront toolbox (*wvf*).
%
% See also: t_opticsWVF, t_opticsWVFZernike
%
% Copyright Imageval Consulting, LLC 2014

%%
ieInit;

%% Create a test scene
scene = sceneCreate('frequency orientation');

%% Create wavefront object and convert it to an optical image object

wvf = wvfCreate;
wvf = wvfComputePSF(wvf);
wvfPlot(wvf, '2d psf space', 'um', 550, 20);
oi = wvf2oi(wvf);

%% Make an ISET optical image

oi = oiCompute(oi, scene);
ieAddObject(oi);
oiWindow;

%% Change the defocus coefficient

wvf = wvfCreate;
D = [0, 2];
for ii = 1:length(D)
    wvf = wvfSet(wvf, 'zcoeffs', D(ii), {'defocus'});
    wvf = wvfComputePSF(wvf);
    wvfPlot(wvf, '2d psf space', 'um', 550, 20);
    oi = wvf2oi(wvf);
    oi = oiCompute(oi, scene);
    oi = oiSet(oi, 'name', sprintf('D %.1f', D(ii)));
    ieAddObject(oi);
    oiWindow;
end

%% Increase astigmatism combined with some defocus

wvf = wvfCreate;
A = [-2, 0, 2];
for ii = 1:length(A)
    wvf = wvfSet(wvf, 'zcoeffs', [2, A(ii)], {'defocus', 'vertical_astigmatism'});
    wvf = wvfComputePSF(wvf);
    wvfPlot(wvf, '2d psf space', 'um', 550, 20);
    oi = wvf2oi(wvf);
    oi = oiCompute(oi, scene);
    oi = oiSet(oi, 'name', sprintf('D %.1f, A %.1f', 0.5, A(ii)));
    ieAddObject(oi);
    oiWindow;
end

%%
