%% s_wvfSpatial
% 
% Can we control the sampling spatial resolution?
%

%%
ieInit;

%%
wvf = wvfCreate;    % Default wavefront 5.67 fnumber
thisWave = wvfGet(wvf,'wave');

fNumber = 4; flengthM = 7e-3; flengthMM = flengthM*1e3;
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);
wvf = wvfComputePSF(wvf);

wvfPlot(wvf,'2d psf space','um',thisWave,10,'airy disk');
fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

%% Change the number of sample pixels in the psf and otf

nPixels0 = wvfGet(wvf,'npixels');

wvf = wvfSet(wvf,'npixels',round(nPixels0/4));
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,10,'airy disk');
wvfGet(wvf,'npixels')
wvfGet(wvf,'psf sample spacing')  % Arcmin
fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

wvf = wvfSet(wvf,'npixels',nPixels);

%% Change the ref pupil size
refPupil0 = wvfGet(wvf,'pupil plane size','mm');

% Changing the refPupil size changes the sample spacing
% I am confused about the direction of the change.  Increasing the size
% makes the sample spacing finer in the PSF.

% Multiply by 4
wvf = wvfSet(wvf,'pupil plane size',refPupil0*4,'mm');
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,10,'airy disk');

fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

% Divide by 4
wvf = wvfSet(wvf,'pupil plane size',refPupil0/4,'mm');
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,10,'airy disk');

fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

% Put it back.
wvf = wvfSet(wvf,'pupil plane size',refPupil0);

%% Change the focal length also changes the umperdegree spacing

wvf = wvfSet(wvf,'focal length',flengthM/2);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');
fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));

wvf = wvfSet(wvf,'focal length',flengthM*2);
wvf = wvfComputePSF(wvf);
wvfPlot(wvf,'2d psf space','um',thisWave,20,'airy disk');
fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

%% Loop a bit on focal length

% Overlaps the wvf and oi curves.
fl = linspace(5,20,4)*1e-3;
for ff = fl
    wvf = wvfSet(wvf,'focal length',ff);
    oiD = wvf2oi(wvf);

    wvf = wvfComputePSF(wvf,'force',true,'lca',false);
    oiPlot(oiD,'psf xaxis',[],thisWave,'um'); 
    hold on;
    wvfPlot(wvf,'psf xaxis','um',thisWave,20,'no window');
end

%% The pupil function and the OTF are connected
%
% We calculate the OTF from the pupilFunction -> PSF -> OTF
% But we should be able to calculate pupilFunction -> OTF
%
% I think the issue is that we have to account for the spatial
% transformation between the samples on the pupil function and the samples
% on the PSF side.  When we compute the PSF, we account for this.  But when
% we simply assign pupilfunction -> OTF, we are not accounting for this.
% Though that may be wrong.

% Here is the pupil function
pf  = wvfGet(wvf,'pupilfunction',thisWave);
fx = wvfGet(wvf,'otf support');
[Fx,Fy] = meshgrid(fx,fx);

% Still need to understand.
ieNewGraphWin;
mesh(Fx,Fy,abs(pf));    % Aperture function

ieNewGraphWin;
mesh(Fx,Fy,angle(pf));  % Wavefront aberration

ieNewGraphWin;
otf = wvfGet(wvf,'otf',thisWave);
mesh(Fx,Fy,abs(otf));
