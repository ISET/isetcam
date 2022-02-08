%% The Airy Disk of a diffraction limited system
%
% The *Airy Disk* describes the blur arising from an ideal (diffraction-limited)
% uniformly illuminated, circular aperture. Its name arises from the astronomer
% Lord Airy <https://en.wikipedia.org/wiki/Airy_disk (George Biddell Airy)>.
% This script exposes the code used to calculate and plot the Airy disk for diffraction
% limited optics.
%
% See also: dlMTF, oiCreate; oiCompute, ieShape, ieDrawShape
%
% Copyright ImagEval Consultants, LLC, 2010.

%%
ieInit

%% Establish a scene and a diffraction limited optics
%%
scene = sceneCreate;
oi    = oiCreate;
oi    = oiCompute(scene,oi);

% Pull out the optics
optics = oiGet(oi,'optics');
%% Select spatial samples and wavelength for plotting
%%
nSamp = 25; thisWave = 500; units = 'um';

clear fSupport
val = opticsGet(optics,'dlFSupport',thisWave,units,nSamp);
[fSupport(:,:,1),fSupport(:,:,2)] = meshgrid(val{1},val{2});

%Over sample to make a smooth image. This move increases the spatial
%frequency resolution (highest spatial frequency) by a factor of 4.
fSupport = fSupport*4;

% Frequency units are cycles/micron. The spatial frequency support runs
% from -Nyquist:Nyquist. With this support, the Nyquist frequency is
% actually the highest (peak) frequency value. There are two samples per
% Nyquist, so the sample spacing is 1/(2*peakF)
%
peakF = max(fSupport(:));
deltaSpace = 1/(2*peakF);
%% Calculate the OTF using diffraction limited MTF (dlMTF)
%%
otf = dlMTF(oi,fSupport,thisWave,units);

% Derive the psf from the OTF
psf = fftshift(ifft2(otf));

% Make the spatial support for the PSF
clear sSupport
samp = (-nSamp:(nSamp-1));
[X,Y] = meshgrid(samp,samp);
sSupport(:,:,1) = X*deltaSpace;
sSupport(:,:,2) = Y*deltaSpace;

% Calculate the Airy disk
fNumber = opticsGet(optics,'fNumber');

% This is the Airy disk radius, by formula
radius = (2.44*fNumber*thisWave*10^-9)/2 * ieUnitScaleFactor(units);

% Draw a circle at the first zero crossing (Airy disk)
nCircleSamples = 200;
[adX,adY,adZ] = ieShape('circle',nCircleSamples,radius);
%% Plot the diffraction limited PSF.
%%
x = sSupport(:,:,1); y = sSupport(:,:,2);
ieNewGraphWin;
mesh(x,y,psf);
colormap(jet(64))

% Label the graph and draw the Airy disk
ringZ = max(psf(:))*1e-3;
hold on; p = plot3(adX,adY,adZ + ringZ,'k-');
set(p,'linewidth',3); hold off;
xlabel('Position (um)'); ylabel('Position (um)');
zlabel('Irradiance (relative)');
title(sprintf('Point spread (%.0f nm)',thisWave));

% Store the plotted values.  They can be retrieved using
%
%   uData = get(gcf,'userData');   
%
udata.x = x; udata.y = y; udata.psf = psf;
set(gcf,'userdata',udata);

%% The same result obtains if you use the ISET function
%
% All of these calculations are embedded in the oiPlot() function
%

[theData, hdl] = oiPlot(oi,'psf',[],500,'um');
get(hdl,'userData')

%%
%