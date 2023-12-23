function [OTF2D, fSupport] = custom2OTF(oi,fSupport,wavelength,units)
% Calculate the OTF2D and freq support for a specific shift-invariant
% OI
%
% Brief
%  This routine returns appropriate spectral OTF given the spatial
%  sampling in the optical image.  This version supercedes customOTF,
%  by using the wavefront methods rather than the interp2() methods we
%  used for many years.
%
% Synopsis
%  [OTF2D,fSupport] = custom2OTF(oi,[fSupport],[wavelength = :],[units='mm'])
%
% Input
%  oi         - Optical image
%  fSupport   - Frequency support required for the samples in the
%               optical image (default: oiGet(oi,'fSupport',units);
%  wavelength - Wavelengths (nm) used for the spectral OTF (default:
%               oiGet(oi,'wavelength')
%  units      - 'mm','m','um','deg'  (default:  'mm')
%
% Output
%   OTF2D     - Spectral 2D OTF
%   fSupport  - See above
%
% Description
%  In the shift-invariant optics model, custom data are stored in the
%  optics.OTF slot.  This routine reads the otf data and interpolates
%  them to the fSupport and wavelength of the optical image or optics
%  structure.
%
%  The returned OTF is normalized so that all energy is transmitted
%  (i.e., the DC value is 1).  This is done by normalizing the peak
%  value to one. If we ever have a case when the peak is other than
%  the DC, we have a problem with energy conservation - where did the
%  photons go?
%
%  The default units for the frequency support are cycles/millimeters.
%
%  TODO:  We can accept fSupport in
%  various units. But we can also set 'units'.  It is possible that
%  the user sends in fSupport in, say, cyc/deg and sends in units as
%  'mm'.  The case we do not want is fSupport is in cyc/deg and units
%  is in mm.
%
% See also:
%   oiCalculateOTF, dlCore.m
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('oi'),         error('Optical image required.'); end
if ieNotDefined('wavelength'), wavelength = oiGet(oi,'wavelength'); end

% If the user sent in fSupport, they have to deal with units.  If they
% did not, they might have sent in units, in which case we retrieve
% the fSupport with the units they sent in.
if ieNotDefined('fSupport')
    if ieNotDefined('units'),      units = 'mm'; end
    fSupport = oiGet(oi,'fSupport',units); 
end

fx    = fSupport(:,:,1); fy = fSupport(:,:,2);
nX    = size(fx,2);      nY = size(fy,1);
nWave = length(wavelength);

optics = oiGet(oi,'optics');
wvf    = optics2wvf(optics);
wvf    = wvfSet(wvf,'wave',wavelength);

% {
% Can we match the oi support by setting the parameters of the wvf
% wvfGet(wvf,'psf support','um')

% We want the OTF and PSF to be nX by nY
% The 

% We want the spatial samples in the wvf to match the spatial sample
% spacing in the oi
oiDelta  = oiGet(oi,'sample spacing','mm');

psf_sample = oiDelta(1); % mm

focallengthMM = wvfGet(wvf, 'focal length','mm');
ref_wavelength = 550; % nm
lambda = ref_wavelength * 1e-6; %  mm
nPixels = nX;
pupil_sample = lambda * focallengthMM/(nPixels * psf_sample);

% according to ChatGPT, 2 to 4 times the aperture seems a good number
pupilPlanDiameterMM = wvf.calcpupilMM * 2;
scaleFactor = pupilPlanDiameterMM/ (nPixels * pupil_sample);

if scaleFactor > 1
    scaleFactor = ceil(scaleFactor);
    nPixels = scaleFactor*nPixels;
    fprintf('Scale the pupil plane by %d times to have a proper PSF calculation.\n',scaleFactor)
else
    scaleFactor = 1;
end

fieldSizeMM = nPixels * pupil_sample; % pupil_sample is smaller by scaleFactor times
% This is the 
% wvfDelta = wvfGet(wvf,'pupil spatial sample','mm');

%{
  % We want this
  [OTF.fx,OTF.fy] = wvfSupport(pupilDiameter,focalLength,sampleSpacing,nSamples)
  OTF.OTF = wvfComputeOTF(zcoefs,pupilDiameter,OTF.fx,OTF.fy,OTF.wave);
  optics = opticsSet(optics,'otf',OTF)
%}

% whether we should use diagonal of film which we can get with:
% diagonal = oiGet(oi,'diagonal','mm')
% Another thing we need to fix is that OTF .* FFT2(image), the size of OTF
% and Image has to be the same, it means we will pad zeros to image
% (addition to the original padding?) 

% nSpatialSamples = ceil(refSizeOfFieldMM/oiDelta(1));

% Match the field size of the OI.  This impacts the sampling density
% in the PSF representation.  We would like this to match the sampling
% density of oiDelta.  It matches with 2*oiDelta.  We don't
% understasnd that, but perhaps it is a radius vs. diameter thing.  We
% aren't sure why the number of samples has to be 10x either.


wvf = wvfSet(wvf,'field size mm',fieldSizeMM, ref_wavelength);

% This forces the number of spatial samples to be nX
wvf = wvfSet(wvf, 'spatial samples', nPixels);

% We need to force the size of the image to be 
% refSizeOfFieldMM = wvf.calcpupilMM; % focallength/fnumber

wvf = wvfCompute(wvf);  
% wvfPlot(wvf,'psf','unit','um','wave',550,'plot range',15);

%{
% These should match
S = wvfGet(wvf,'otf support','mm',550);
S(end)
otfSupport = opticsGet(optics,'otfSupport','mm');
otfSupport.fx(end)


psf_support = wvfGet(wvf, 'psf spatial samples', 'um', 550);

psf_sample_interval = psf_ss(2)-psf_ss(1);


oi_sample_interval = oiGet(oi,'sample spacing','um'); 

fprintf('PSF sample interval is %f.2 um; \n OI sample interval is %f.2 um \n', psf_sample_interval/scaleFactor, oi_sample_interval(1));
%}

OTF2D = zeros(nX,nX,nWave);

for ii = 1:nWave
    psf = wvfGet(wvf, 'psf', wavelength(ii));
    % Original grid
    [rows, cols] = size(psf);
    [X, Y] = meshgrid(1:cols, 1:rows);

    % New grid for resampling
    [Xq, Yq] = meshgrid(1:scaleFactor:cols, 1:scaleFactor:rows);

    psf_subsampled = interp2(X, Y, psf, Xq, Yq, 'cubic');

    psf_subsampled = psf_subsampled/sum(psf_subsampled(:));
    % compare them
    %{
    figure;plot(psf);title('Before');clim([min(psf(:)) 1e-8]);
    figure;imagesc(psf_subsampled);title('After');clim([min(psf_subsampled(:)) 1e-8]);
    %}

    [~,~,OTF2D(:,:,ii)] = PsfToOtf([],[],psf_subsampled);
end

%}
%{
% This OTF is a property of the optics and we represent it when we
% create the original OI.  The frequency sampling may or may not match
% the frequency sampling we need for the current oi.
%
% The OTF default units are cycles per millimeter.  But we can use
% other units if specified by the user.
otfSupport = opticsGet(optics,'otfSupport',units);
[X,Y]      = meshgrid(otfSupport.fy,otfSupport.fx);

% Find the OTF at each wavelength. 
% 
% This may require interpolating the optics data to match the current
% OI.  The interpolation method can have significant consequences for
% the result when we are working with very high dynamic range scenes.
% (ZL, BW, 12/2023).
if length(wavelength) == 1

    OTF2D = opticsGet(optics,'otfData',wavelength);
    % figure(1); mesh(X,Y,OTF2D);
    % figure(1); mesh(X,Y,abs(OTF2D))
    
    % We interpolate the stored OTF2D onto the support grid for the
    % optical image.
    %
    % The OTF2D representation stores DC is in (1,1). So we would want
    % the fSupport to run from 1:N. The otfSupport that we use to
    % create X and Y, runs from -N:N. To make things match up, we
    % apply an fftshift to the OTF2D data prior to interpolating to
    % the spatial frequencies, fx and fy, that are required given the
    % spatial sampling of the optical image.
    %
    % BW:  Can't this also be fftshift?  Like below?
    OTF2D    = ifftshift(interp2(X, Y, fftshift(OTF2D), fx, fy, 'linear',0));
    
else    
    % Same as above, but wavelength by wavelength
    OTF2D = zeros(nY,nX,nWave);
    for ii=1:length(wavelength)
        tmp = opticsGet(optics,'otfData',wavelength(ii));
        %  ieNewGraphWin; mesh(X,Y,fftshift(abs(tmp)));
        %  ieNewGraphWin; mesh(fftshift(abs(fft2(tmp))));
        % fftshift(interp2(X, Y, fftshift(tmp), fx, fy, 'linear',0));
        OTF2D(:,:,ii) = ...
            fftshift(interp2(X, Y, fftshift(tmp), fx, fy, 'linear',0));
        %{
          ieNewGraphWin; 
          mesh(fx,fy,fftshift(abs(OTF2D(:,:,ii))));  
          set(gca,'xlim',[-1000 1000],'ylim',[-1000 1000]);
          ieNewGraphWin; imagesc(fftshift(abs(ifft2(OTF2D(:,:,ii)))));
        %}
    end
end
%}
end
