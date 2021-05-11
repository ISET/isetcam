function PSF = rtPSFInterp(optics, fieldHeight, fieldAngle, wavelength, xGrid, yGrid)
% Interpolate ray trace PSF for the field height and angle.
%
%    PSF = rtPSFInterp(optics,fieldHeight,fieldAngle,wavelength)
%
% fieldHeight (m)  represents the distance from the center of the image.
% xGrid, yGrid (m) sampling grid in meters
% fieldAngle  (deg) is the angle.
% wavelength:  Wavelength field of the optics data (nm)
%
% When we store the PSF, it has unit area.  The interpolated PSF should
% also have unit area. Thus, no light is lost by application of the PSF.
%
% See rtApplyPSF for an example call.
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
% This routine is a target for speeding up.

if ieNotDefined('optics'), optics = sceneGet(vcGetObject('oi'), 'optics'); end
if ieNotDefined('fieldHeight'), fieldHeight = 0; end
if ieNotDefined('fieldAngle'), fieldAngle = 0; end
if ieNotDefined('wavelength'), wavelength = 550; end

if isempty(opticsGet(optics, 'rayTrace'))
    errordlg('No ray trace information present.');
    PSF = [];
    return;
end

% These values should be in millimeters.
distimght = opticsGet(optics, 'rtdistortionfunction', wavelength, 'm');

% Convert the field height into an index that can be used to retrieve the
% proper PSF.
[idx1, idx2] = ieFieldHeight2Index(distimght, fieldHeight);

% Pack PSF into transform or computational space dimensions
PSF1 = opticsGet(optics, 'rtpsfdata', distimght(idx1), wavelength);
PSF2 = opticsGet(optics, 'rtpsfdata', distimght(idx2), wavelength);

k = abs(distimght(idx2)-distimght(idx1));
if k > 0
    H = (fieldHeight - distimght(idx1)) / (distimght(idx2) - distimght(idx1));
    PSF = (1 - H) * PSF1 + H * PSF2; %interpolate PSF
else PSF = PSF1;
end

% figure;
% psfSupportX = opticsGet(optics,'rtPsfSupportX','mm');
% psfSupportY = opticsGet(optics,'rtPsfSupportY','mm');
% mesh(psfSupportX,psfSupportY,PSF);
% mesh(PSF1); mesh(PSF2);

% Rotate for proper field angle using Mathwork's version.
if fieldAngle ~= 0
    PSF = imrotate(PSF, fieldAngle, 'bilinear', 'crop');
end

% This is PM's version.  Not sure which to use.
% PSF = rtImageRotate(PSF,fieldAngle);

% Find a faster 2D interpolation.  Something in this routine
% takes a long time.  Maybe I have some NaNs in some step?
if ieNotDefined('xGrid') || ieNotDefined('yGrid')
    % Leave the PSF on its own measurement space
else
    % Person asked to have the psf interpolated to a new grid
    % Can we use fast n furious here?
    psfSupportX = opticsGet(optics, 'rtPsfSupportX', 'm');
    psfSupportY = opticsGet(optics, 'rtPsfSupportY', 'm');
    if max(xGrid) > max(psfSupportX(:)),
        warning('Possible PSF truncation');
    end

    % Interpolate giving extrapolating out of range values to zero.
    PSF = interp2(psfSupportX(:)', psfSupportY(:), PSF, xGrid, yGrid, 'linear');
    % Can use extrapval 0 in interp2 for Matlab 7.  But in 6.5, must
    % replace ourselves.
    PSF = replaceNaN(PSF, 0);
end
% mesh(xGrid,yGrid,PSF);


return;