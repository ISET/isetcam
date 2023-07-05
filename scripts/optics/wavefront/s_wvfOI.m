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

%%
wvf = wvfCreate;    % Default wavefront 5.67 fnumber
thisWave = wvfGet(wvf,'wave');

flengthMM = 6; flengthM = flengthMM*1e-3;
fNumber = 3;
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);

%% Slice through the wvf psf

wvfData = wvfPlot(wvf,'psf xaxis','um',thisWave,10);
hold on;

% Convert to OI and plot the same slice.  With the dx/2 shift, they agree
% except for a small scale factor.  Which I don't understand
oi = wvf2oi(wvf,'model','wvf human');
uData = oiGet(oi,'optics psf xaxis');
% dx = uData.samp(2) - uData.samp(1);
plot(uData.samp,uData.data,'go');
legend({'wvf','oi'});

%% Here is the slope.
ieNewGraphWin; plot(wvfData.psf(:),uData.data(:),'ro');
identityLine;

%% wvfplot xaxis code

% The slight shift in dx is the reason for the mis-match
psf  = wvfGet(wvf,'psf');
samp = wvfGet(wvf,'psf spatial samples');
wvfLineData = interp2(samp,samp,psf,0,samp);

% oiplot xaxis code
nSamp = 15;   % Does not seem to matter
thisWave = 550;
units = 'mm';
psfData = opticsGet(oi.optics,'psf data',thisWave,units,nSamp);

X = psfData.xy(:,:,1); Y = psfData.xy(:,:,2); oiSamp = psfData.xy(1,:,1);
oiLineData = interp2(X,Y,psfData.psf,0,oiSamp);

ieNewGraphWin; 
plot(wvfLineData,oiLineData,'ro'); identityLine;
xlabel('wvf PSF'); ylabel('oi PSF'); grid on;

%% Compare the OTFs in WVF and OI representations after wvf2oi

oi = wvf2oi(wvf);
oiData = oiPlot(oi,'otf',[],thisWave);
wvData = wvfPlot(wvf,'otf','mm',thisWave);

% The DC position must account for whether the length of fx is even or odd
ieNewGraphWin;
if isodd(length(wvData.fx)), wvMid = floor(length(wvData.fx)/2) + 1;
else,                 wvMid = length(wvData.fx)/2 + 1;
end
plot(wvData.fx, wvData.otf(:,wvMid),'r-'); hold on;

if isodd(length(oiData.fx)), oiMid = floor(length(oiData.fx)/2) + 1;
else,          oiMid = length(oiData.fx)/2 + 1;
end

% There are some small imaginary parts of the otf
plot(oiData.fx, abs(oiData.otf(:,oiMid)),'bo')
legend({'wvf','oi'})
grid on
xlabel('Frequency'); ylabel('Amplitude');

%% Another match
wvfOTF = wvfGet(wvf,'otf');

oi = wvf2oi(wvf);
oiOTF  = oiGet(oi,'optics otf');

% Compare with a scatter plot.
% You must use fftshift, not ifftshift, to convert OI data to match WVF.
ieNewGraphWin;

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

%% Check across wavelengths with roughly human parameters

waves = 400:50:700;
wvf = wvfCreate('wave',waves);    % Default wavefront 5.67 fnumber

flengthMM = 17; flengthM = flengthMM*1e-3; fNumber = 5.7; 
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);

% Loop through the wavelengths, plotting the psf slice
wvfPlot(wvf,'psf xaxis','um',waves(1),10);
hold on;
for ii = 2:numel(waves)
    uData = wvfPlot(wvf,'psf xaxis','um',waves(ii),10,'no window');
    plot(uData.samp,uData.psf,'x');
end
title('Multiple wavelengths (human)')

%% Check across wavelengths with roughly human parameters
waves = 400:50:700;
wvf = wvfCreate('wave',waves);    

flengthMM = 4; flengthM = flengthMM*1e-3; fNumber = 2.8; 
wvf = wvfSet(wvf,'calc pupil diameter',flengthMM/fNumber);
wvf = wvfSet(wvf,'focal length',flengthM);

wvf = wvfComputePSF(wvf,'lca',false,'force',true);

% Loop through the wavelengths, plotting the psf slice
wvfPlot(wvf,'psf xaxis','um',waves(1),10);
hold on;
for ii = 2:numel(waves)
    uData = wvfPlot(wvf,'psf xaxis','um',waves(ii),10,'no window');
    plot(uData.samp,uData.psf,'x');
end
title('Multiple wavelengths (camera)')

%% END