function oi = opticsOTF(oi,scene,varargin)
% Apply the opticalImage OTF to the photon data
%
% Synopsis
%    oi = opticsOTF(oi,scene,varargin);
%
% Inputs
%  oi            - oi with optical blur not yet applied to photons
%  scene         - the scene from whence the photons came.  Here it is only
%                  used to determine the pad size, because the photons in
%                  the passed oi have already been set up by the calling
%                  routine.
%
% Optional key/val
%  'padvalue'    - How to pad the oi to handle boder effects. {'zero','mean','border','spd'}
%                  See oiPadValue but note that for some reason that takes
%                  different strings for the options above. And that 'spd'
%                  is not implemented. This routine translates the strings
%                  above into what oiPadValue wants.
%
% Return
%   oi          - oi with computed photons inserted.
%
% Description
%   The optical transform function (OTF) associated with the optics in
%   the OI is applied to the scene data.  This function is called for
%   shift-invariant and diffraction-limited models.  It is not called
%   for the ray trace calculation, which uses the (ray trace method)
%   pointspreads derived from Zemax.
%
%   The OTF data are spectral and thus can be rather large.  The
%   spectral OTF represents every spatial frequency in every waveband.
%
%   The programming issues concerning using Matlab to apply the OTF to the
%   image (rather than convolution in the space domain) are explained
%   below.
%
% See also
%  oiCalculateOTF, oiCompute
%
% Examples:
%  oi = opticsOTF(oi);      % Not saved
%  oi = opticsOTF(oi,1);    % OTF data are saved -- NOT YET IMPLEMENTED
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Parse

varargin = ieParamFormat(varargin);
p = inputParser;
p.KeepUnmatched = true;
p.addRequired('oi',@(x)(isstruct(x) && isequal(x.type,'opticalimage')));
p.addRequired('scene',@(x)(isstruct(x) && isequal(x.type,'scene')));
p.addParameter('padvalue','zero',@(x)(ischar(x) || isvector(x)));
p.parse(oi,scene,varargin{:});

%% Get the optics model and fan out as appropriate
optics      = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');

switch lower(opticsModel)
    case {'skip','skipotf'}
        irradianceImage = oiGet(oi,'photons');
        oi = oiSet(oi,'photons',irradianceImage);
        
    case {'dlmtf','diffractionlimited','shiftinvariant','custom','humanotf'}
        oi = oiApplyOTF(oi,scene,'mm',p.Results.padvalue);
        
    otherwise
        error('Unknown OTF method');
end

end

%-------------------------------------------
function oi = oiApplyOTF(oi,scene,unit,padvalue)
% Calculate and apply the otf waveband by waveband
%
%   oi = oiApplyOTF(oi,method,unit);
%
% We calculate the OTF every time, never saving it, because it can take up
% a lot of space and is not that hard to calculate.  Also, any change to
% the optics properties would make us recompute the OTF, and keeping things
% synchronized can be error prone.
%
% Example:
%    oi = oiApplyOTF(oi);
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('oi'),     error('Optical image required.'); end
if ieNotDefined('unit'),   unit   = 'cyclesPerDegree'; end

% Get sampling wavelengths
wave     = oiGet(oi,'wave');

% Pad the optical image to allow for light spread.  Also, make sure the row
% and col values are even.
imSize   = oiGet(oi,'size');
padSize  = round(imSize/8);
padSize(3) = 0;
sDist = sceneGet(scene,'distance');

% ISETBio and ISETCam, historically, used different padding
% strategies.  Apparently, we have zero, mean and border implemented -
% which are not all documented at the top.  We should also allow spd
% and test it. Zero photons was the default for ISETCam, and mean
% photons was the default for ISETBio.  
% 
% This update is being tested as of 9/25/2023.
switch padvalue
    case 'zero'
        padType = 'zero photons';
    case 'mean'
        padType = 'mean photons'; 
    case 'border'
        padType = 'border photons'; 
    case 'spd'
        error('spd padvalue not yet implemented.')
    otherwise
        error('Unknown padvalue %s',padvalue);
end

%% Adjust the data by padding, and get the OTF

% oiGet(oi,'sample size')
oi = oiPadValue(oi,padSize,padType,sDist);
% oiGet(oi,'sample size')

% Get the current photons.  It has the right size.  We over-write it
% below.
p = oiGet(oi,'photons');

% Get the OTF
otfM = oiCalculateOTF(oi, wave, unit); 

%% Calculate blured photons for each wavelength

% Initialize check variables
nWlImagTooBig = 0;
maxImagFraction = 0;
imagFractionTol = 1e-2;
for ii=1:length(wave)
    img = p(:, :, ii);
    % figure(1); imagesc(img); colormap(gray(64));
    
    % For diffraction limited we calculate the OTF.  For other optics
    % models we look up the stored OTF.  Remember, DC is in the (1,1)
    % position.
    % otf = oiCalculateOTF(oi,wave(ii),unit);
    otf = otfM(:,:,ii);
    % figure(1); mesh(abs(otf)); otf(1,1)
    
    % Take the fourier transform.  This leaves DC at (1,1), matched 
    % to the way we store the OTF.
    imgFFT = fft2(img);
    % figure(1); imagesc(abs(imgFFT));
    % figure(2); imagesc(abs(otf));
    % colormap(gray(64))
    
    % Multiply the transformed otf and image. No fftshifts needed here
    % because everything has DC at (1,1).
    %
    % Then invert.  This leaves the image correct because that is what
    % ifft2 does when its input has DC at (1,1), which it does here.
    filteredIMGRaw = ifft2(otf .* imgFFT);

    % Get real and imaginary parts.  The image should be real up to
    % numerical issues. We save the largest deviation over
    % wavelengths, and check outside the loop below.
    filteredIMGReal = real(filteredIMGRaw);
    filteredIMGImag = imag(filteredIMGRaw);
    imagFraction = max(abs(filteredIMGImag(:)))/max(abs(filteredIMGReal(:)));
    if ( imagFraction > imagFractionTol )
        nWlImagTooBig = nWlImagTooBig + 1;
        if (imagFraction > maxImagFraction)
            maxImagFraction = imagFraction;
        end
    end

    % The complex values should never be there. But we think it arises
    % because of rounding error and or asymmetry in the OTF as a
    % result of the interpolation. Take the absolute value to
    % eliminate small imaginary terms
    filteredIMG = abs(filteredIMGRaw);

    % figure(1); imagesc(abs(filteredIMG)); colormap(gray(64))
    p(:,:,ii) = filteredIMG;
end

% Check that the imaginary part was not too big
if (nWlImagTooBig > 0)
    if ( max(abs(filteredIMGImag(:)))/max(abs(filteredIMGReal(:))) > imagFractionTol )
        error('OpticsOTF: Imaginary exceeds tolerance relative to real at %d wavelengths, max fraction %0.1g\n',nWlImagTooBig,maxImagFraction);
    end
end

%% Put all the photons into the oi at once.
oi = oiSet(oi,'photons',p);

end

