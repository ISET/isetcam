%% Conversion tests from wvf to oi
%
% * Create a standard wvf and compare the PSF (diffraction limited)
% * Blur and compare again
% * Try with different wavelengths
% 
%
% Current status - Everything matches on July 3, 2023.
%
% See also
%  s_wvfDiffraction, v_opticsWVF

%%
ieInit;

%% Show that Airy disk matches at different f#

wvf = wvfCreate;    % Default wavefront 5.67 fnumber
thisWave = wvfGet(wvf,'wave');

flengthMM = 6; flengthM = flengthMM*1e-3;

fNumber = linspace(3,7,4);
ieNewGraphWin([],'upper left big');
tiledlayout(2,2);
for ii=1:numel(fNumber)

    wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber(ii));
    wvf = wvfSet(wvf,'focal length',flengthM);

    wvf = wvfComputePSF(wvf,'lca',false,'force',true);

    % Slice through the psf
    nexttile;
    wvfPlot(wvf,'psf xaxis','um',thisWave,10,'no window');
end


%% Conversion to OI preserves the PSF and AD

wvf = wvfCreate; 

% Recompute the pupil function
wvf = wvfComputePSF(wvf,'lca',false,'force',true);

% Plot a slice through the psf
wvfData = wvfPlot(wvf,'psf xaxis','um',thisWave,10);
hold on;

% Convert the wvf to an oi and overlay
oi = wvf2oi(wvf);
uData = oiGet(oi,'optics psf xaxis');
plot(uData.samp,uData.data,'go');

%% We can also show the scatter plot between wvf and oi data

%{
ieNewGraphWin; 
plot(wvfData.psf(:),uData.data(:),'ro');
identityLine;
xlabel('wvf data'); ylabel('oi data');
%}

%% Show the OTF matches as well

wvfOTF = wvfGet(wvf,'otf');
oiOTF  = oiGet(oi,'optics otf');

ieNewGraphWin;

% You must use fftshift, not ifftshift, to convert OI OTF data to
% match the WVF data.
oiOTFS = fftshift(oiOTF);
subplot(1,2,1)
plot(abs(oiOTFS(:)),abs(wvfOTF(:)),'.');
identityLine;
title('OTF: oi converted to wvf')

% And ifftshift to convert WVF data to match OI.
subplot(1,2,2);
wvfOTFS = ifftshift(wvfOTF);
plot(abs(oiOTF(:)),abs(wvfOTFS(:)),'.');
identityLine;
title('OTF: wvf converted to oi')

%% Check across wavelengths - human LCA

waves = linspace(450,650,9);
wvf = wvfCreate('wave',waves);    % Default wavefront 5.67 fnumber

flengthMM = 17; flengthM = flengthMM*1e-3; fNumber = 5.7; 
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',true,'force',true);
oi = wvf2oi(wvf);

ieNewGraphWin([],'upper left big');
tiledlayout(3,3);
% Loop through the wavelengths, plotting the psf slice
for ii = 1:numel(waves)
    oiLine = oiGet(oi,'optics psf xaxis',waves(ii),'um');
    wvfLine = wvfGet(wvf,'psf xaxis','um',waves(ii));
    nexttile;
    plot(oiLine.samp,oiLine.data,'k.',wvfLine.samp,wvfLine.data,'r--');
    grid on; xlabel('Pos (um)');
end

%% Check across wavelengths with diffraction, no LCA

waves = linspace(450,650,9);
wvf = wvfCreate('wave',waves);    % Default wavefront 5.67 fnumber

flengthMM = 17; flengthM = flengthMM*1e-3; fNumber = 5.7; 
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);
oi = wvf2oi(wvf);

ieNewGraphWin;
tiledlayout(3,3);
% Loop through the wavelengths, plotting the psf slice
for ii = 1:numel(waves)
    oiLine = oiGet(oi,'optics psf xaxis',waves(ii),'um');
    wvfLine = wvfGet(wvf,'psf xaxis','um',waves(ii));
    nexttile;
    plot(oiLine.samp,oiLine.data,'k.',wvfLine.samp,wvfLine.data,'r--');
    grid on; xlabel('Pos (um)');
end

%% END