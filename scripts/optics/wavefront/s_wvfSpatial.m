%% s_wvfSpatial
% 
% Illustrating the spatial sampling control in various ways.
% 
%  * Changing the number of pixels
%  * Changing the pupil plane size
%  * Changing the focal length
%  * Illustrating the pupil function and OTF
%

%%
ieInit;

%%
wvf = wvfCreate;    % Default wavefront 5.67 fnumber
thisWave = wvfGet(wvf,'wave');

fNumber = 4; flengthM = 7e-3; flengthMM = flengthM*1e3;
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);
wvf = wvfCompute(wvf);

wvfPlot(wvf,'psf','unit','um','wave',thisWave,'plot range',10,'airy disk',true);
fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

%% Change the number of sample pixels in the psf and otf

nPixels0 = wvfGet(wvf,'npixels');

wvf = wvfSet(wvf,'npixels',round(nPixels0/4));
wvf = wvfCompute(wvf);
wvfPlot(wvf,'psf','unit','um','wave',thisWave,'plot range',10,'airy disk',true);

wvfGet(wvf,'npixels')
wvfGet(wvf,'psf sample spacing')  % Arcmin
fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

wvf = wvfSet(wvf,'npixels',nPixels0);

%% Change the ref pupil size
refPupil0 = wvfGet(wvf,'pupil plane size','mm');

% Changing the refPupil size changes the sample spacing. But BW is confused
% about the direction of the change.  Increasing the size makes the sample
% spacing finer in the PSF.

% Multiply by 4
wvf = wvfSet(wvf,'pupil plane size',refPupil0*4,'mm');
wvf = wvfCompute(wvf);
wvfPlot(wvf,'psf','unit','um','wave',thisWave,'plot range',10,'airy disk',true);

fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

% Divide by 4
wvf = wvfSet(wvf,'pupil plane size',refPupil0/4,'mm');
wvf = wvfCompute(wvf);
wvfPlot(wvf,'psf','unit','um','wave',thisWave,'plot range',10,'airy disk',true);

fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

% Put it back.
wvf = wvfSet(wvf,'pupil plane size',refPupil0);

%% Change the focal length also changes the umperdegree spacing

wvf = wvfSet(wvf,'focal length',flengthM/2);
wvf = wvfCompute(wvf);
wvfPlot(wvf,'psf','unit','um','wave',thisWave,'plot range',20,'airy disk',true);

fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));

wvf = wvfSet(wvf,'focal length',flengthM*2);
wvf = wvfCompute(wvf);
wvfPlot(wvf,'psf','unit','um','wave',thisWave,'plot range',20,'airy disk',true);

fprintf('Npix %d delta Arcmin %.5f\n',wvfGet(wvf,'npixels'), wvfGet(wvf,'psf sample spacing'));
fprintf('um per deg %f\n',wvfGet(wvf,'um per degree'));

%% Loop a bit on focal length, showing overlap of wvf and oi curves

fl = linspace(5,20,4)*1e-3;
for ff = fl
    wvf = wvfSet(wvf,'focal length',ff);
    oiD = wvf2oi(wvf);

    wvf = wvfCompute(wvf);
    oiPlot(oiD,'psf xaxis',[],thisWave,'um'); 
    hold on;
    wvfPlot(wvf,'psf xaxis','unit','um','wave',thisWave,'plot range',20,'airy disk',true,'window',false);

    legend({'oi','airy disk','wvf'});
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
fx  = wvfGet(wvf,'otf support');
[Fx,Fy] = meshgrid(fx,fx);

% Still need to understand.
ieNewGraphWin;
mesh(Fx,Fy,abs(pf));    % Aperture function
%{
% Equivalent
pfa = wvfGet(wvf,'pupil function amplitude');
mesh(Fx,Fy,pfa);
%}

ieNewGraphWin;
mesh(Fx,Fy,angle(pf));  % Wavefront aberration
%{
 % Equivalent
 pfp = wvfGet(wvf,'pupil function phase');
 mesh(Fx,Fy,pfp)
%}

% The pupil function goes to the PSF and then back to the OTF. I would like
% a direct route.
ieNewGraphWin;
otf = wvfGet(wvf,'otf',thisWave);
mesh(Fx,Fy,abs(otf));

%% Pupil aperture and phase functions

wvf = wvfCreate;
wvf = wvfCompute(wvf);

pupilPhase = wvfGet(wvf,'pupil function phase');
apertureFunction = wvfGet(wvf,'pupil function amplitude');
ieNewGraphWin; colormap("jet");
subplot(1,2,1), imagesc(apertureFunction); axis image
subplot(1,2,2), imagesc(pupilPhase); axis image

%% Now with defocus

wave = 400:50:700;
wvf = wvfCreate('wave',wave);
wvf = wvfSet(wvf,'zcoeff',1,{'defocus'});
wvf = wvfCompute(wvf);

thisWave = [400,500,600];
ieNewGraphWin; colormap("jet");
tcl = tiledlayout(3,3);
for ii=1:numel(thisWave)
    % The pupil phase extends over 2*pi.  But the aberration only extnds over
    % pi.  I am not sure why.
    pupilPhase = wvfGet(wvf,'pupil function phase',thisWave(ii));
    apertureFunction = wvfGet(wvf,'pupil function amplitude',thisWave(ii));
    wavefrontabberration = wvfGet(wvf,'wavefront aberration',thisWave(ii));

    nexttile, imagesc(apertureFunction); axis image; 

    nexttile, imagesc(pupilPhase); axis image;
    title(sprintf('wave %d',thisWave(ii)));

    nexttile, imagesc(wavefrontabberration); axis image;
    
end
