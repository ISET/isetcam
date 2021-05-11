function oi = rtPSFApply(oi)
%Apply point spread function to the irradiance image in oi
%
%     oi = rtPSFApply(oi)
%
% The PSF is applied after the geometric distortion and relative
% illumination.  The point spread function is applied to each point at each
% wavelength in the irradiance data.
%
% The ISET point spread data are read from Zemax sampled on a 128x128 grid,
% sampled at 0.25 microns (total spread of 32 microns).
%
% This routine is slow.  See notes below for ways to speed it up in the future.
%
% The ray trace pointspread data are interpolated from the Zemax (or Code V) ray
% trace data.  These rdata are stored in optics.rayTrace.
%
% The algorithm here is:
%
%   (a) Defines an eccentricity band within each image height range defined by
%       the sample heights used in Zemax.
%   (b) Finds PSFs corresponding to the inner and outer radius
%   (c) Finds the distance from each pixel (p) to the inner and outer
%       and compute a wgtIn = d(p,out)/(d(p,out) - d(p,in)).
%                    wgtOut = 1 - wgtIn
%   (d) Computes the weighted sum of the inner and outer PSFs for each pixel
%   (e) Rotates the interpolated PSF to the pixel angle
%   (f) Adds the PSF, weighted by the irradiance of the input image, to the
%   output irradiance image
%
% oi (optical image):    Default, the current optical image.
%
% Computational Notes:
%
%  1.  In the current implementation, we compute every PSF for every pixel at
%  every wavelength. This calculation is slow because of the large number
%  of interp2() and imrotate() calls.
%
%  It is possible to speed up the calculation by specifying a resolution,
%  say 50 microns and 9 deg of angle, and precompute the PSFs for those
%  values. This would reduce the number of calls to interp2 and imrotate.
%  Furthermore, we only need to store the first 90 deg and we can use
%  rot90() For example, for a 1 mm image, this for the remaining quadrants.
%  In this way, we would have 20*10 = 200 PSFs.  Then we would use the
%  pre-computed PSFs, rounding each of the pixels to the closest PSF.
%
%  We should definitely try this for speed.  The precomputation of the PSFs
%  at some resolution is a straightforwarda routine to write.
%
%  2.  The initial debugging was very slow because I didn't appreciate some
%  of the physical implications of the PSFs. Not all collections of
%  space-varying PSFs make a reasonable image.
%
%  Here are some notes.
%
%    - The original PSF I used for debugging was rotated by 90 deg
%    (incorrectly).  This produced noise and odd little bends in the image
%    that I thought were due to errors in the logic of the code.  In fact,
%    many image distortions can arise if the PSF is not the right
%    (physically realizable) function.
%
%    - It was useful to test with monochrome uniform image;  it was useful
%    to test with an array of points, say created by
%               scene = sceneCreate('pointarray',64,16);
%               ieAddObject('scene',scene);
%
%    -  To control the spatial sampling density you can set the
%    field of view in the scene larger or smaller.  If you need more field
%    of view at some sampling density, you must increase the number of
%    points
%
%    - Even when testing with Gaussian PSFs, I had some conceptual
%    surprises.  For example, the little dimple at the origin is probably a
%    real effect, though it may be more extreme with our interpolation
%    methods than in reality. The reason is something like this.  Suppose
%    you are a pixel in the center and you have a very small Gaussian
%    spread.  So, you keep all your light close by.  Now, a pixel a few
%    dozen microns away has a broader pointspread.  It gives up its
%    photons, some of which go to the center pixel.  So, if the pixel
%    pointspread is increasing, we expect the very center to accumulate
%    more photons than the pixels that are eccentrically located.  The
%    issue is hard to intuit if the shapes are changing.  In our example
%    Zemax data, the shapes change a lot from center to the first band.
%
%    - Pointspread rotation has some real difficulties on coarse grids. For
%    example, there is no good way to rotate a function 4.9 deg on a
%    sampling grid that is 7x7.  So, don't expect good results when the
%    optical image is coarse.  When I run the current code at 9x9, the
%    first big artifact that is evident are orientation bands.  When I run
%    the code at 25x25 both otherwise unchanged, the orientation bands are
%    gone.  I think that the orientation bands are probably a sign that the
%    imrotate() is having a hard time doing its job at coarse sampling
%    rates.
%
%    I create a warndlg() at less than 16x16. But who knows what level it
%    should really be.   In any case, probably the measure should be in
%    terms of microns, not number of samples.
%
%
%Example:
%
%   oi = rtPSFApply(vcGetObject('oi'));
%
% Copyright ImagEval, LLC, 2005

if ieNotDefined('oi'), oi = vcGetObject('oi'); oiGet(oi, 'name'), end
% if ieNotDefined('displayFlag'), displayFlag = 0; end

% Figure we use to track progress. Code could be better here.
upDateFig = 9999;
units = 'm';

% Confirm the presence of ray trace information
optics = oiGet(oi, 'optics');
if isempty(opticsGet(optics, 'rayTrace')),
    errordlg('No ray trace information.');
    return;
end

% Properties of the current optical image.  This has the distortion and
% relative illuminance computed already
inIrrad = oiGet(oi, 'photons');
imSize = oiGet(oi, 'size');
wavelength = oiGet(oi, 'wavelength');
nWave = oiGet(oi, 'nwave');

% The spatial sampling positions for the ray traced PSF
psfSupportX = opticsGet(optics, 'rtPsfSupportX', units);
psfSupportY = opticsGet(optics, 'rtPsfSupportY', units);

% Define the sample image heights
imgHeight = opticsGet(optics, 'rtpsffieldheight', units);

% We have to figure out how many point samples there are in the image.  I
% think we know because the geometry and RI are computed prior to this
% point.
sSupport = oiGet(oi, 'spatialSamplingPositions', units);
xSupport = sSupport(:, :, 1);

% Make big y upper part of the image for axis xy
ySupport = flipud(sSupport(:, :, 2));

% Determine the  angle and field height of every irradiance position.
[dataAngle, dataHeight] = cart2pol(xSupport, ySupport);
dataAngleDeg = rad2deg(dataAngle);

% Reduce imgHeights to only those within the height of the image.
imgHeight = rtSampleHeights(imgHeight, dataHeight);
fprintf('Eccentricity bands: %.0f \n', length(imgHeight));

% Create an output grid for the PSF. This grid matches the scene radiance and oi irradiance
% image spatial sampling
[xGrid, yGrid] = rtPSFGrid(oi, units);
psfSize = size(xGrid);
fprintf('PSF sample grid: %.0f by %.0f\n', psfSize);
if psfSize(1) < 7
    % Not worth blurring.  Just return.
    disp('rtPSFApply: Spatial sampling too coarse for PSF.');
        oi = oiSet(oi, 'photons', inIrrad);
        return;
    elseif psfSize(1) < 20
        % This criterion of 20 was done by experimenting with just one
        % lens and a uniform image. The number may not be general.
        disp('rtPSFApply: Coarse spatial sampling;imprecise results.');
        disp('rtPSFApply: Suggest increasing scene sampling or decreasing field of view')
    end

    % Set the angles very near the origin to zero to avoid sharp
    % discontinuities. Adjust the rotation angles near the origin.  Do this by
    % setting the angle of everything within 1 horizontal resolution step to 0.
    % aRes = 1.5;
    % l = (dataHeight < aRes*hRes(1));
    % trueDataAngle = dataAngle;
    % dataAngle(l) = 0;

    % The output irradiance imageis padded with extra rows and columns to
    % permit point spread blurring beyond the edge of inIrrad. The inIrrad
    % positions begin at (extraRow/2 + 1, extraCol/2 + 1) in the outIrrad data.
    extraRow = ceil(1.5*psfSize(1));
    extraRow = 2 * ceil(extraRow/2);
    extraCol = ceil(1.5*psfSize(2));
    extraCol = 2 * ceil(extraCol/2);
    outIrrad = zeros(imSize(1)+extraRow, imSize(2)+extraCol, length(wavelength));

    % Adding pixels to the output irradiance image changes the field of view.
    % We adjust the oi field of view here.  This is already done in scenePad,
    % for the diffraction limited calculation.  It might be better to find a
    % way to use scenePad/oiPad here.
    curFOV = oiGet(oi, 'horizontalfieldofview');
    oi = oiSet(oi, 'horizontalfieldofview', curFOV*(1 + (extraCol / imSize(2))));

    % This matrix specifies the locations in the inIrrad that are within the
    % eccentricity band of the current processing step.
    % lBand      = zeros(imSize);
    lAll = zeros(imSize);

    totalPixels = prod(imSize);

    % Loop over wavelengths, image height, and image angles.
    for ww = 1:nWave

        for rr = 2:(length(imgHeight))
            fprintf('Eccentricity band %.0f\n', rr-1);

            % These are the full PSFs, at high spatial sampling resolution
            if rr == 2
                % The imgHeight variable must be in meters (units = 'm') See above
                PSF(:, :, 1) = opticsGet(optics, 'rtpsfdata', imgHeight(rr - 1), wavelength(ww));
                PSF(:, :, 1) = PSF(:, :, 1) / sum(sum(PSF(:, :, 1)));

                PSF(:, :, 2) = opticsGet(optics, 'rtpsfdata', imgHeight(rr), wavelength(ww));
                PSF(:, :, 2) = PSF(:, :, 2) / sum(sum(PSF(:, :, 2)));

            else
                PSF(:, :, 1) = PSF(:, :, 2);
                PSF(:, :, 2) = opticsGet(optics, 'rtpsfdata', imgHeight(rr), wavelength(ww));

            end

            % This fix comes from Kunal and Peter.  We should probably avoid
            % this step by storing the data properly when we read the Zemax
            % data - BW
            PSF(:, :, 1) = rot90(PSF(:, :, 1), -1);
            PSF(:, :, 2) = rot90(PSF(:, :, 2), -1);


            % These are the points between the two image height samples, [0,1],
            % or [1,2], and so forth.
            lBand = (dataHeight >= imgHeight(rr - 1)) & (dataHeight < imgHeight(rr));
            % figure; imagesc(lBand); colorbar;

            % Keep track of all the selected points. Doesn't seem needed any
            % more. It was used in debugging for a while.
            lAll = lAll + lBand;
            % if max(lAll(:)) > 1, error('Pixel included twice'); end

            % Every point gets a weight that define its distance from
            % the two sample positions
            innerDistance = abs(dataHeight-imgHeight(rr - 1));
            % figure; mesh(innerDistance);

            innerWeight = 1 - (innerDistance / (imgHeight(rr) - imgHeight(rr - 1)));
            % figure; mesh(innerWeight); colorbar

            % These are the row and columns in the band.
            [r, c] = find(lBand);
            nPixels = length(r);
            for pp = 1:nPixels

                % Weighted and rotated PSF for this pixel
                wgt = innerWeight(r(pp), c(pp));
                thisPSF = wgt * PSF(:, :, 1) + (1 - wgt) * PSF(:, :, 2);

                % The rotate prior to downsampling is important for precision.
                % In the future, we should precompute a set of PSFs, at
                % relatively high resolution, and just add them in.

                % I believe that this preserves the sample spacing.
                thisPSF = imrotate(thisPSF, dataAngleDeg(r(pp), c(pp)), ...
                    'bilinear', 'crop');

                % Interpolate to the sampling grid of the optical image
                % Extrapolating out of range values to zero.
                thisPSF = interp2(psfSupportX(:)', psfSupportY(:), thisPSF, ...
                    xGrid, yGrid, 'linear');

                % Normalize this PSF to have unit volume under the surface.
                thisPSF = (thisPSF ./ sum(thisPSF(:)));

                % For some reason, thisPSF does not sum to 1 perfectly.  I
                % wonder why. It differs by something like 10^-15.  That may
                % not seem like much, but the inIrrad is on the order of 10^15.
                % So when we multiply through, this may cause a problem.

                % Compute the output row and column positions
                % This differs depending on whether the psfSize is even or odd.
                rExt = floor(psfSize(1)/2);
                cExt = floor(psfSize(2)/2);
                if isodd(psfSize)
                    outRow = ((r(pp) - rExt):(r(pp) + rExt)) + extraRow / 2;
                    outCol = ((c(pp) - cExt):(c(pp) + cExt)) + extraCol / 2;
                else
                    outRow = ((r(pp) - (rExt - 1)):(r(pp) + rExt)) + extraRow / 2;
                    outCol = ((c(pp) - (cExt - 1)):(c(pp) + cExt)) + extraCol / 2;
                end

                % Add result to output radiance
                outIrrad(outRow, outCol, ww) = ...
                    outIrrad(outRow, outCol, ww) ...
                    +inIrrad(r(pp), c(pp), ww) * thisPSF;

                % Bookkeeping and display
                totalPixels = totalPixels - 1;
                if ~mod(totalPixels, 150) || (totalPixels == 1)
                    figure(upDateFig);
                    colormap(gray);
                    set(gcf, 'Units', 'normalized', 'Position', [.55, .6, .42, .32]);
                    set(gcf, 'Name', 'PSF Status', 'NumberTitle', 'off');

                    subplot(1, 2, 1), cla
                    imageSPD(outIrrad);
                    hold on;
                    plot(c(pp)+extraCol/2, r(pp)+extraRow/2, 'o');
                    str = sprintf('[%.2f-%.2f] (mm) %.0f (nm)', ...
                        imgHeight(rr - 1), imgHeight(rr), wavelength(ww));
                    title(str);

                    subplot(1, 2, 2), mesh(thisPSF);
                    str = sprintf('[%.0f,%.0f]', c(pp), r(pp));
                    title(str); pause(0.05)
                end
            end
        end
    end

    % Error checking.  Haven't got here in months.  Delete at some point.
    if sum(lAll(:)) ~= numel(lAll) * nWave
        r = questdlg('Untouched pixels. Stop?');
        if strcmpi(r, 'yes'), keyboard; end
    end

    oi = oiSet(oi, 'photons', outIrrad);

    return;
