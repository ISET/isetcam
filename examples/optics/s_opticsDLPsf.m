%% Diffraction limited point spread function calculations
%
% The *point spread function* (PSF) is a fundamental measure of
% lens performance. For small changes in position, the PSF in
% most optics has the same shape.
%
% For circular pupils and *diffraction-limited* optics, the PSF
% can be calculated directly from the f-number, focal length,
% wavelength, and angle.  These quantities are plotted here.
%
% The calculation for the diffraction limited case is carried out
% in the oiPlot and plotOTF call as:
%
%   fSupport = opticsGet(optics,'dl fsupport matrix',thisWave,units,nSamp);
%   fSupport = fSupport*4;  % Enlarge the frequency support
%   otf = dlMTF(oi,fSupport,thisWave,units);
%
%   % DC is at (1,1); we plot with DC in the center.
%   otf = fftshift(otf);
%
% See also: t_opticsPSFPlot, oiCreate, oiPlot, dlMTF, rad2deg
%
% (c) Imageval Consulting, LLC, 2012

%%
ieInit;
clear rad2deg

%% Create optical image

% Here, we do the calculation by pulling out the optics
% structure, setting its values, and then replacing it in the oi
% structure.
oi      = oiCreate;
optics  = oiGet(oi,'optics');
fLength = 0.017;
fNumber = 17/3;
optics = opticsSet(optics,'flength',fLength);  % Roughly human
optics = opticsSet(optics,'fnumber',fNumber);   % Roughly human
oi     = oiSet(oi,'optics',optics);

%%  Show linespread at different wavelengths

% The calculation of the line spread function is done inside of
% oiPlot
uData = oiPlot(oi,'ls wavelength');
fNumber = opticsGet(optics,'fnumber','mm');
fLength = opticsGet(optics,'focal length','mm');
title(sprintf('F/# = %.2f  Foc Leng = %.2f (mm)',fNumber,fLength));

%% Show the linespread in units of arc min rather than position (um)

ieNewGraphWin;
posMM = uData.x/1000;              % Microns to mm
aMinutes = atan2d(posMM,fLength) * 3437.75;   % Angle in arcminutes.
mesh(aMinutes,uData.wavelength,uData.lsWave);
view(30,20);
xlabel('angle (arc min)');
ylabel('wavelength (nm)');

%% For a wavelength, show the full psf near the Airy Ring

% The PSF calculation is done inside of oiPlot again.
thisWave = 400;
uData = oiPlot(oi,'psf',[],thisWave);

view(2)
% This is a diameter.
AiryRingUM = (2.44*(thisWave/1000)*fNumber);

% We make the image big enough to show the whole ing.
set(gca,'xlim',[-AiryRingUM AiryRingUM],'ylim',[-AiryRingUM AiryRingUM])

%% Show a slice through the psf as a function of angle
[r,~] = size(uData.x);
mid = ceil(r/2);
psfMid = uData.psf(mid,:);
posMM = uData.x(mid,:)/1000;               % Microns to mm
posMinutes = atan2d(posMM,fLength) * 3437.75;

vcNewGraphWin;
plot(posMinutes,psfMid)
xlabel('Arc min')
AiryRingMM = AiryRingUM/1000;
AiryRingMinutes = rad2deg(atan2(AiryRingMM,fLength)) * 3437.75; % Radians
set(gca,'xlim',2*[-AiryRingMinutes AiryRingMinutes])

pDiameter = opticsGet(optics,'pupil diameter','mm');
str = sprintf('PSF Cross section: Wave %d (nm), fNumber %.2f Pupil %.1f',...
    thisWave,fNumber,pDiameter);
title(str);

%% Or, here is a single line spread
uData = oiPlot(oi,'lswavelength');
posMM = uData.x/1000;
aRadians = atan2(posMM,fLength);    % This is angle in radians
aMinutes = rad2deg(aRadians) * 3437.75;          % This is angle in arc min
plot(aMinutes,uData.lsWave(1,:),'-',...
    aMinutes,uData.lsWave(16,:),'r:',...
    aMinutes,uData.lsWave(31,:),'g--')
legend('400nm','550nm','700nm'); title('Line spread');
grid on; xlabel('arc min')

%% For wvf comparison, here is just at 550nm
thisWave = 550;
uData = oiPlot(oi,'psf',[],thisWave);

view(2)
AiryRingUM = (2.44*(thisWave/1000)*fNumber);
set(gca,'xlim',[-AiryRingUM AiryRingUM],'ylim',[-AiryRingUM AiryRingUM])

[r,c] = size(uData.x);
mid = ceil(r/2);
psfMid = uData.psf(mid,:);
posMM = uData.x(mid,:)/1000;               % Microns to mm
posMinutes = rad2deg(atan2(posMM,fLength)) * 3437.75;

vcNewGraphWin;
plot(posMinutes,psfMid), xlabel('Arc min'), set(gca,'xlim',[-2 2])

%% Now change the f-number and plot in angle again
fNumber = 5*(17/3);
optics  = opticsSet(optics,'fnumber',fNumber);
oi      = oiSet(oi,'optics',optics);

%%  Show linespread at different wavelengths
oiPlot(oi,'ls wavelength');
fNumber = opticsGet(optics,'fnumber','mm');
fLength = opticsGet(optics,'focal length','mm');
title(sprintf('F/# = %.2f  Foc Leng = %.2f (mm)',fNumber,fLength));

%%  Show linespread at different wavelengths
fNumber = 0.5*(17/3);
optics  = opticsSet(optics,'fnumber',fNumber);
oi      = oiSet(oi,'optics',optics);

uData   = oiPlot(oi,'ls wavelength');
fNumber = opticsGet(optics,'fnumber','mm');
fLength = opticsGet(optics,'focal length','mm');
title(sprintf('F/# = %.2f  Foc Leng = %.2f (mm)',fNumber,fLength));

%% The distance of the psf spread depends on the f-number

% We can change the focal length but the spread in distance is
% unchanged
optics = oiSet(oi,'optics flength',fLength);
oiPlot(oi,'psf 550');

oi = oiSet(oi,'optics flength',fLength*10);
oiPlot(oi,'psf 550');

% But if we change the f-number, the spread in distance changes
oi = oiSet(oi,'optics fnumber',fNumber*5);
oiPlot(oi,'psf 550');


%% Note about angle representation
%
% For a fixed aperture, the spread in angle is invariant to f
% length. So, if we change the fnumber, and plot w.r.t angle, we
% get the same spread function.

%%
