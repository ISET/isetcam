function oi = opticsOTF(oi, scene)
% Apply the opticalImage OTF to the photon data
%
%    oi = opticsOTF(oi,scene);
%
% The optical transform function (OTF) associated with the optics in the OI
% is calculated and applied to the scene data.  This function is called for
% shift-invariant and diffraction-limited models.  It is not called for the
% ray trace approach.
%
% The  spatial (frequency) support of the OTF is computed from the OI
% information.
%
% The OTF data are not stored or returned.  The OTF can be quite large.  It
% represents every spatial frequency in every waveband.  So we  compute the
% OTF and apply it on the fly, without ever representing the whole OTF
% (support and wavelength).
%
% The programming issues concerning using Matlab to apply the OTF to the
% image (rather than convolution in the space domain) are explained both
% here and in the script s_FFTinMatlab.
%
% In the future, we may permit saving the OTF in the OI structure by
% setting the otfSaveFlag to true (1).  At present, that flag is not
% implemented.  But computers seem to be getting bigger and faster.
%
% See also:  s_FFTinMatlab, oiCalculateOTF, oiCompute
%
% Examples:
%  oi = opticsOTF(oi);      % Not saved
%  oi = opticsOTF(oi,1);    % OTF data are saved -- NOT YET IMPLEMENTED
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('oi'), error('Optical image required.'); end
if ieNotDefined('scene'), scene = vcGetObject('scene'); end
% if ieNotDefined('otfSaveFlag'),  otfSaveFlag = 0; end

optics = oiGet(oi, 'optics');
opticsModel = opticsGet(optics, 'model');

switch lower(opticsModel)
    case {'skip', 'skipotf'}
        irradianceImage = oiGet(oi, 'photons');
        oi = oiSet(oi, 'photons', irradianceImage);

    case {'dlmtf', 'diffractionlimited'}
        oi = oiApplyOTF(oi, scene);

    case {'shiftinvariant', 'custom', 'humanotf'}
        oi = oiApplyOTF(oi, scene, 'mm');

    otherwise
        error('Unknown OTF method');
end

end

%-------------------------------------------
function oi = oiApplyOTF(oi, scene, unit)
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

if ieNotDefined('oi'), error('Optical image required.'); end
if ieNotDefined('unit'), unit = 'cyclesPerDegree'; end

wave = oiGet(oi, 'wave');

% Pad the optical image to allow for light spread.  Also, make sure the row
% and col values are even.
imSize = oiGet(oi, 'size');
padSize = round(imSize/8);
padSize(3) = 0;
sDist = sceneGet(scene, 'distance');
oi = oiPad(oi, padSize, sDist);

% See s_FFTinMatlab to understand the logic of the operations here.
% We used to do this one wavelength at a time.  But this could cause
% dynamic range problems for ieCompressData.  So, for now we are
% experimenting with filtering one at a time but stuffing the whole data
% set in at once.

% Get the current data set.  It has the right size.  We over-write it
% below.
p = oiGet(oi, 'photons');
otfM = oiCalculateOTF(oi, wave, unit); % Took changes from ISETBio.

for ii = 1:length(wave)
    % img = oiGet(oi,'photons',wave(ii));
    img = p(:, :, ii);
    % figure(1); imagesc(img); colormap(gray);

    % For diffraction limited we calculate the OTF.  For other optics
    % models we look up the stored OTF.  Remember, DC is in the (1,1)
    % position.
    % otf = oiCalculateOTF(oi,wave(ii),unit);
    otf = otfM(:, :, ii);
    % figure(1); mesh(otf); otf(1,1)

    % Put the image center in (1,1) and take the transform.
    imgFFT = fft2(img);
    % imgFFT = fft2(fftshift(img));
    % figure(1); imagesc(abs(imgFFT));
    % figure(2); imagesc(abs(otf));
    % colormap(gray)

    % Multiply the transformed otf and the image.
    % Then invert and put the image center in  the center of the matrix
    filteredIMG = abs(ifft2(otf .* imgFFT));
    % filteredIMG = abs(ifftshift(ifft2(otf .* imgFFT)));
    % if  (sum(filteredIMG(:))/sum(img(:)) - 1) > 1e-10  % Should be 1 if DC is correct
    %   warning('DC poorly accounted for');
    % end

    % Temporary debug statements
    %  if ~isreal(filteredIMG),
    %     warning('ISET:complexphotons','Complex photons: %.0f', wave(ii));
    %  end

    % Sometimes we had  annoying complex values left after this filtering.
    % We got rid of it by an abs() operator.  It should never be there.
    % But we think it arises because of rounding error.  We haven't seen
    % this in years, however.
    % figure(1); imagesc(abs(filteredIMG)); colormap(gray)
    %
    % oi = oiSet(oi,'photons',filteredIMG,wave(ii));
    p(:, :, ii) = filteredIMG;
end

% Put all the photons in at once.
oi = oiSet(oi, 'photons', p);

end
