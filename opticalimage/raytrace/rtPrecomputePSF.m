function svPSF = rtPrecomputePSF(oi, angStepSize, cPosition)
%Precompute shift-variant PSFs for ray trace model
%
%    svPSF = rtPrecomputePSF([oi],[angStepSize],[cPosition = (0,0)])
%
% The svPSF is a structure that contains the PSFs from the ray trace
% portion of the optical image, oi. The shift-variant psf (svPSF) structure
% is derived from the ray trace information stored in the optics slot.
% This structure is calculated for a specific computation, and then the
% structure is stored in the oi.psf slot, not inside the optics.
%
% The svPSF contains the point spreads functions (psf) for all the image
% height, wavelength, and angles in the optical image.
%
% The psf dimensionality is [nAngles, M radial heights, and W wavelengths].
% The M radial heights are at the heights of the original PSF estimates.
%
% Angles are measured every angStepSize (degrees).  The default is 1 deg.
% The angles represented are [0:angStepSize:360], to include both 0 and
% 360, because that helps subsequent interpolation (see rtAngleLUT).
%
% Examples:
%   psfStruct = rtPrecomputePSF;   % Default shift-variant psf struct
%
%   oi = vcGetObject('OI'); scene = vcGetObject('scene');
%   oi = oiCompute(scene,oi);
%   angStep = 10;     % Set angle step
%   psfStruct = rtPrecomputePSF(oi,angStep);  % PSF is single precision
%   oi = oiSet(oi,'psfStruct',psfStruct);
%
% Copyright ImagEval, LLC, 2005

if ieNotDefined('oi'), oi = vcGetObject('oi'); oiGet(oi, 'name'), end
if ieNotDefined('angStepSize'), angStepSize = 1; end % Angular step size in deg

% We can place the input image off center to enable a smaller total field
% with an emphasis on the periphery.  But the default is to be on-axis.
% center position units are m, to match the spatial sampling positions
% below.
if ieNotDefined('cPosition'), cPosition = [0, 0]; end

scene = ieGetObject('scene');
if isempty(scene)
    error('A scene must be selected in the database.');
else
    fprintf('Setting up for scene %s\n', scene.name);
    end

    optics = oiGet(oi, 'optics');
    if isempty(opticsGet(optics, 'rayTrace'))
        errordlg('No ray trace information.');
        return;
    end

    % We create a shift-variant psf structure that can be added to the optical
    % image
    svPSF = [];

    % Properties of the optical image
    % inIrrad = oiGet(oi,'photons');
    % imSize = oiGet(oi,'size');
    wavelength = oiGet(oi, 'wavelength');
    nWave = oiGet(oi, 'nwave');

    % Specify the sample angles (deg).  We want both 360 and 0 so when we
    % interpolate the angles values between 350 and 360 easily map back to 360,
    % which is the same as 0.
    sampAngles = (0:angStepSize:360);
    nAngles = length(sampAngles);

    % The spatial sampling positions for the ray traced PSF
    psfSupportX = opticsGet(optics, 'rtPsfSupportX', 'mm');
    psfSupportY = opticsGet(optics, 'rtPsfSupportY', 'mm');

    % Define the sample image height in meters
    imgHeight = opticsGet(optics, 'rt PSF field Height', 'm');

    % We have to figure out how many point samples there are in the image.  I
    % think we know because the geometry and so forth prior to this point.
    sSupport = oiGet(oi, 'spatial support', 'm');
    xSupport = sSupport(:, :, 1);
    % Make big y upper part of the image for axis xy
    ySupport = flipud(sSupport(:, :, 2));

    % Can we deal with the center position (cPosition) just once, here, when we
    % set the spatial support and angles?  This approach must be the same when
    % we apply the rtPSF in the next routine.
    xSupport = xSupport - cPosition(1);
    ySupport = ySupport - cPosition(2);

    % Determine the angle and field height of every irradiance position.
    [~, dataHeight] = cart2pol(xSupport, ySupport);
    % dataAngleDeg = rad2deg(dataAngle);

    % Reduce imgHeights to those within the image height
    imgHeight = rtSampleHeights(imgHeight, dataHeight);
    nFieldHeights = length(imgHeight);
    fprintf('Eccentricity bands: %.3f (um)\n', imgHeight*1e6);

    % Create an output grid for the PSF. This grid matches the irradiance
    % image spatial sampling.
    [xGrid, yGrid] = rtPSFGrid(oi, 'mm');
    psfSize = size(xGrid);
    fprintf('PSF sample grid: %.0f by %.0f\n', psfSize);
    if psfSize(1) < 7
        % Not worth blurring.  Just return.
        warndlg('Scene spatial sampling is too coarse for ray trace PSF. No blurring applied.');
            disp('Suggest increasing scene sampling or decreasing field of view')
            svPSF = [];
            return;
        elseif psfSize(1) < 20
            % This criterion of 20 was done by experimenting with just one
            % lens and a uniform image. The number may not be general.
            warndlg('Coarse scene spatial sampling;increase scene sampling for more precision.');
                pause(2);
                disp('Suggest increasing scene sampling (or decrease field of view).')
            end

            % Averaging filter to smooth interpolation noise.  This is not so great.
            smooth = fspecial('average');

            % Wait bar
            showWaitBar = ieSessionGet('waitbar');
            if showWaitBar
                str = sprintf('Computing psfs: %.0f heights and %.0f waves', nFieldHeights, nWave);
                wBar = waitbar(0, str);
            end

            % Set up the shift-variant PSF structure for the optical image
            svPSF.name = opticsGet(optics, 'rt lens file');
            svPSF.psf = cell(nAngles, length(imgHeight), length(wavelength));
            svPSF.sampAngles = sampAngles;
            svPSF.imgHeight = imgHeight;
            svPSF.wavelength = wavelength;

            % Compute the svPSFs
            for ww = 1:nWave

                for hh = 1:nFieldHeights
                    if showWaitBar
                        str = sprintf('Computing psfs: Wave: %.0f nm Height: %.0f (um)', wavelength(ww), imgHeight(hh)*1e6);
                        wBar = waitbar(hh/nFieldHeights, wBar, str);
                    end

                    % Field height units are meters. Wave in nanometers.
                    tmpPSF = opticsGet(optics, 'rtpsfdata', imgHeight(hh), wavelength(ww));
                    % tmpPSF = fliplr(flipud(tmpPSF));
                    tmpPSF = rot90(tmpPSF, 2);

                    for aa = 1:nAngles

                        % Compute the different angles.  But, don't rotate the inner
                        % two bands.
                        % Try only hh ==1, not also hh == 2
                        if (hh == 1 || hh == 2), thisAngle = sampAngles(1);
                        else, thisAngle = svPSF.sampAngles(aa);
                        end

                        % This is the slowest line in here by far.  If you can, find a
                        % way to speed it up.
                        PSF = imrotate(tmpPSF, thisAngle, 'bilinear', 'crop');

                        %Smooth noise introduced by rotation
                        PSF = imfilter(PSF, smooth, 'replicate');

                        %Match the optical image resolution
                        PSF = interp2(psfSupportX(:)', psfSupportY(:), PSF, xGrid, yGrid, 'linear');
                        PSF = PSF / sum(PSF(:));
                        svPSF.psf{aa, hh, ww} = single(PSF); % Stored as single floats.
                        % vcNewGraphWin; imagesc(PSF);
                    end
                end
            end
            if showWaitBar, close(wBar); end

        end
