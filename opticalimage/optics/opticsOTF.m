function oi = opticsOTF(oi,scene,varargin)
% Apply the opticalImage OTF to the photon data
%
% Synopsis
%    oi = opticsOTF(oi,scene,varargin);
%
% Inputs
%   oi
%  scene
%
% Optional key/val
%
% Return
%   oi
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
%Calculate and apply the otf waveband by waveband
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

% oiGet(oi,'sample size')
oi = oiPadValue(oi,padSize,padType,sDist);
% oiGet(oi,'sample size')

% See t_codeFFTinMatlab to understand the logic of the operations here.
% We used to do this one wavelength at a time.  But this could cause
% dynamic range problems for ieCompressData.  So, for now we are
% experimenting with filtering one at a time but stuffing the whole data
% set in at once.

% Get the current data set.  It has the right size.  We over-write it
% below.
p = oiGet(oi,'photons');
otfM = oiCalculateOTF(oi, wave, unit);  % Took changes from ISETBio.

nWlImagTooBig = 0;
maxImagFraction = 0;
imagFractionTol = 1e-3;
for ii=1:length(wave)
    % img = oiGet(oi,'photons',wave(ii));
    img = p(:, :, ii);
    % figure(1); imagesc(img); colormap(gray(64));
    
    % For diffraction limited we calculate the OTF.  For other optics
    % models we look up the stored OTF.  Remember, DC is in the (1,1)
    % position.
    % otf = oiCalculateOTF(oi,wave(ii),unit);
    otf = otfM(:,:,ii);
    % figure(1); mesh(otf); otf(1,1)
    
    % Put the image center in (1,1) and take the transform.
    imgFFT = fft2(img);
    % imgFFT = fft2(fftshift(img));
    % figure(1); imagesc(abs(imgFFT));
    % figure(2); imagesc(abs(otf));
    % colormap(gray(64))
    
    % Multiply the transformed otf and the image.
    % Then invert and put the image center in  the center of the matrix
    filteredIMGRaw = ifft2(otf .* imgFFT);
    filteredIMGReal = real(filteredIMGRaw);
    filteredIMGImag = imag(filteredIMGRaw);
    imagFraction = max(abs(filteredIMGImag(:)))/max(abs(filteredIMGReal(:)));
    if ( imagFraction > imagFractionTol )
        nWlImagTooBig = nWlImagTooBig + 1;
        if (imagFraction > maxImagFraction)
            maxImagFraction = imagFraction;
        end
    end

    % Take the absolute value to get rid of imaginary parts
    filteredIMG = abs(filteredIMGRaw);

    % filteredIMG = abs(ifftshift(ifft2(otf .* imgFFT)));
    % if  (sum(filteredIMG(:))/sum(img(:)) - 1) > 1e-10  % Should be 1 if DC is correct
    %   warning('DC poorly accounted for');
    % end
    
    % Temporary debug statements
    %  if ~isreal(filteredIMG)
    %     warning('ISET:complexphotons','Complex photons: %.0f', wave(ii));
    %  end
    
    % Sometimes we had  annoying complex values left after this filtering.
    % We got rid of it by an abs() operator above.  It should never be there.
    % But we think it arises because of rounding error.  We haven't seen
    % this in years, however.
    % figure(1); imagesc(abs(filteredIMG)); colormap(gray(64))
    %
    % oi = oiSet(oi,'photons',filteredIMG,wave(ii));
    p(:,:,ii) = filteredIMG;
end

if (nWlImagTooBig > 0)
    if ( max(abs(filteredIMGImag(:)))/max(abs(filteredIMGReal(:))) > imagFractionTol )
        error(sprintf('OpticsOTF: Imaginary part exceeds fractional tolerance relative to real part at %d wavelengths, max fraction %0.1g\n',nWlImagTooBig,maxImagFraction));
    end
end

% Put all the photons in at once.
oi = oiSet(oi,'photons',p);

end

