%% Wavefront calculations
%
% ISET includes two ways to calculate defocus, one based on
% Hopkins and diffraction calculations described in
% <http://white.stanford.edu/~brian/papers/color/MarimontWandell1994.pdf Marimont and Wandell (1994, JOSA)>.
%
% More recently, we introduced a method based on wavefront
% aberrations described in terms of Zernike polynomials.  This
% new method is explained here.
%
% This script illustrates the principles of the calculation and
% validates the method for a diffraction limited case.
%
% The script also validates that we are mapping the wavelengths
% and frequency support correctly between the original ISET and
% WVF toolbox correctly.
%
% See also:  wvfGet/Set/Create, wvfPlot
%
% Copyright Imageval Consulting, LLC 2015

%%
ieInit

%% Create diffraction limited wvf object roughly like human eye

wave = 400:50:700;
pupilMM = 3;      % Human range is 8 to 2 mm
fLengthM = 17e-3; % 17 mm matches human eye

wvfP  = wvfCreate('wave',wave,'name',sprintf('%d-pupil',pupilMM));
wvfP  = wvfSet(wvfP,'pupil diameter',pupilMM);
wvfP  = wvfComputePSF(wvfP);
wvfP  = wvfSet(wvfP,'focal length',fLengthM);  % 17 mm focal length for deg per mm

%% Show the diffraction limited PSF depends sensibly on wavelength

thisWave = 400;  % nm
pRange = 15;     % Microns
wvfPlot(wvfP,'2d psf space','um',thisWave,pRange);

% Draw the expected size of the Airy ring
fNumber = wvfGet(wvfP,'focal length','mm')/pupilMM;
radius = (2.44*fNumber*thisWave*10^-9)/2 * ieUnitScaleFactor('um');
nSamp = 200;
[adX,adY,adZ] = ieShape('circle',nSamp,radius);
adZ = adZ + max(wvfP.psf{1}(:))*5e-3;
hold on; p = plot3(adX,adY,adZ,'k-'); set(p,'linewidth',3); hold off;
title(sprintf('wave %.0f radius %.2f um',thisWave,radius));

% Now check for 700 nm which has a larger Airy ring
thisWave = 700;
pRange = 15;  % Microns
wvfPlot(wvfP,'2d psf space','um',thisWave,pRange); % No LCA
fNumber = wvfGet(wvfP,'focal length','mm')/pupilMM;

radius = (2.44*fNumber*thisWave*10^-9)/2 * ieUnitScaleFactor('um');
nSamp = 200;
[adX,adY,adZ] = ieShape('circle',nSamp,radius);
adZ = adZ + max(wvfP.psf{1}(:))*5e-3;
hold on; p = plot3(adX,adY,adZ,'k-'); set(p,'linewidth',3); hold off;
title(sprintf('wave %.0f radius %.2f um',thisWave,radius));

%% Convert from the wvf data to the oi data based on the OTF

% This work is done in wvf2oi function typically.

% The frequency support in the pupil plane is wavelength
% dependent in the wavefront toolbox.  In ISET, we specify the
% frequency support on the image surface in cyc/mm. To convert,
% we need to find the highest fx in all of the wavelengths.  We
% use this as the maximum fx in ISET.  We interpolate the OTF
% data in the wavefront representation to the OTF data in ISET as
% below.

% Find the wavelength with the largest range of frequency support in
% wavefront structure
fMax = 0;
for ww=1:length(wave)
    f = wvfGet(wvfP,'otf support','mm',wave(ww));
    if max(f(:)) > fMax
        fMax = max(f(:)); maxWave = wave(ww);
    end
end

% Make the frequency support in ISET as the same number of samples with the
% wavelength with the highest frequency support from WVF.
fx = wvfGet(wvfP,'otf support','mm',maxWave);
fy = fx;
[X,Y] = meshgrid(fx,fy);
c0 = find(X(1,:) == 0); r0 = find(Y(:,1) == 0);

% Now set up the OTF variable for use in the ISET representation
nWave = length(wave); nSamps = length(fx);
otf = zeros(nSamps,nSamps,nWave);

% Interpolate the WVF OTF data into the ISET OTF data for each wavelength.
for ww=1:length(wave)
    f = wvfGet(wvfP,'otf support','mm',wave(ww));
    thisOTF = wvfGet(wvfP,'otf',wave(ww));
    est = interp2(f,f',thisOTF,X,Y,'cubic',0);
    
    % It is tragic that fftshift does not shift so that our DC is
    % in (1,1). Rather, if we use fftshift, the highest position
    % is in 201,201. otf(:,:,ww) = fftshift(otf(:,:,ww));
    
    % So, we use circshift.  This is also the process followed in
    % the psf2otf and otf2psf functions in the image processing
    % toolbox.  Makes me think that Mathworks had the same issue.
    % Very annoying. (BW)
    
    % We identified the (r,c) that represent frequencies of 0
    % (i.e., DC). We circularly shift so that that (r,c) is at
    % the (1,1) position.
    otf(:,:,ww) = circshift(est,-1*[r0-1,c0-1]);
    
end

% I sure wish this was real all the time. Sometimes (often?) it is.
psf = otf2psf(otf(:,:,ww));
if ~isreal(psf), disp('psf not real'); end

% vcNewGraphWin; mesh(psf)

%% Place the frequency support and OTF data into the ISET oi structure.

oi = oiCreate('shift invariant');
oi = oiSet(oi,'wave',wave);

% Note the awful wave repetition below.  Someday this should get better.
oi = oiSet(oi,'optics OTF fx', fx);
oi = oiSet(oi,'optics OTF fy', fy);
oi = oiSet(oi,'optics otfdata', otf);
oi = oiSet(oi,'optics wave',wave);
oi = oiSet(oi,'optics OTF wave',wave);

%% Compare the OTF plots from the wavefront and oi structures

thisWave = 550;
oiData = oiPlot(oi,'otf',[],thisWave);
wvData = wvfPlot(wvfP,'2D otf','mm',thisWave);

vcNewGraphWin;
if isodd(length(wvData.fx)), wvMid = floor(length(wvData.fx)/2) + 1;
else                 wvMid = length(wvData.fx)/2 + 1;
end
plot(wvData.fx, wvData.otf(:,wvMid),'r-'); hold on;

if isodd(length(oiData.fx)), oiMid = floor(length(oiData.fx)/2) + 1;
else          oiMid = length(oiData.fx)/2 + 1;
end
plot(oiData.fx, oiData.otf(:,oiMid),'b-')
legend({'wvf','oi'})
xlabel('Frequency (cyc/mm)')
ylabel('Amplitude')
grid on

%% PSF plots

% Get the oiData.  The plot is ugly, but should get better.
oiData = oiPlot(oi,'psf','um',550);

% Zoom in using the returned oiData
pRange = 10;
c = logical(-pRange < oiData.x(1,:)) & logical(oiData.x(1,:) < pRange);
r = logical(-pRange < oiData.y(:,2)) & logical(oiData.y(:,2) < pRange);
vcNewGraphWin;
mesh(oiData.x(r,c),oiData.y(r,c),abs(oiData.psf(r,c)))

% Compare with the wavefront plot
wvfPlot(wvfP,'2d psf space','um',550,pRange);

%%
