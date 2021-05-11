%
tic
oi = vcGetObject('oi');
inIrrad = oiGet(oi, 'photons');
imSize = oiGet(oi, 'size');
wavelength = oiGet(oi, 'wavelength');
nWave = oiGet(oi, 'nwave');

optics = oiGet(oi, 'optics');

% Get all the image heights and image angles we will use to partition the
% data into blocks
imgHeight = opticsGet(optics, 'rtpsffieldheight', 'mm');

% The angle bands run from -pi to pi
nAngles = 8;
imgAngle = (([0:(nAngles)]) / (nAngles)) * (2 * pi) - pi;

% Now, find the spatial support of the optical image.  We will convert
% these into image height in millimeters and angle.  Then we will
%   (a) March through the set of blocks defined by image height and angle
%   (b) Find the block of pixels satisfying
%        imgHeight1 <= pixCoord < imgHeight2 && imgAngle1 <= pixCoord < imgAngle2
%   (c) Find the 4 PSFs corresponding to imgHeight,imgAngle
%   (d) Find the distance from each pixel in the block to the four corners,
%   and compute a weight
%   (e) Add in the weighted sum of the four PSFs at that pixel
%

% We have to figure out how many point samples there are in the image.  I
% think we know because the geometry and so forth prior to this point.
sSupport = oiGet(oi, 'spatialSamplingPositions', 'mm');
xSupport = sSupport(:, :, 1);

% Make big y upper part of the image for axis xy
ySupport = flipud(sSupport(:, :, 2));

[fieldAngle, fieldHeight] = cart2pol(xSupport, ySupport);

% figure;
% imagesc(fieldAngle)
% imagesc(fieldHeight)

% Adjust  imgHeight based on the actual size of the image.
mxHeight = max(fieldHeight(:));
l = imgHeight > mxHeight;
lastHeight = find(diff(l)) + 1;
imgHeight = imgHeight([1:lastHeight]);

% Create the output grid for the PSF, matched to the image spatial sampling
hRes = oiGet(oi, 'sampleSpacing', 'mm'); % x,y; width,height; col,row
psfSupportY = opticsGet(optics, 'rtpsfSupportRow', 'mm');
psfSupportX = opticsGet(optics, 'rtpsfSupportCol', 'mm');
xMax = max(psfSupportX);
yMax = max(psfSupportY);

xGrid1 = 0:hRes(1):xMax;
tmp = -1 * fliplr(xGrid1);
xGrid1 = [tmp(1:(end -1)), xGrid1];
yGrid1 = 0:hRes(2):yMax;
tmp = -1 * fliplr(yGrid1);
yGrid1 = [tmp(1:(end -1)), yGrid1];
[xGrid, yGrid] = meshgrid(xGrid1, yGrid1);

% Initialize PSF matrix.  Four columns that contain the PSFs at the for
% corners.
psfSize = size(xGrid);
PSF = zeros(psfSize(1)*psfSize(2), 4);

% Initialize the output irradiance image.  This image is padded with some
% extra rows and columns to permit the point spread blurring beyond the
% inIrrad
extraRow = 2 * ceil(psfSize(1)/2); % Always even, and 1 space more than needed.
extraCol = 2 * ceil(psfSize(2)/2);

% The inIrrad positions begin at (extraRow/2 + 1, extraCol/2 + 1) in the
% outIrrad data.  The extra rows and columns handle the light spread.
outIrrad = zeros(imSize(1)+extraRow, imSize(2)+extraCol, length(wavelength));

% This matrix specifies the locations in the inIrrad that are within the
% radius and angle of the current processing step.
lBoth = zeros(imSize);

for ww = 1:nWave
    for rr = 2:(length(imgHeight))
        innerRad = imgHeight(rr-1);
        outerRad = imgHeight(rr);
        lRad = (fieldHeight >= innerRad) & (fieldHeight < outerRad);
        for aa = 2:(length(imgAngle))
            lowerAng = imgAngle(aa-1);
            higherAng = imgAngle(aa);
            lAng = (fieldAngle >= lowerAng) & (fieldAngle < higherAng);
            lBoth = (lAng & lRad);
            rad2deg(lowerAng)
            rad2deg(higherAng)

            if sum(lBoth(:)) < 3, [rr, aa],
            else
                % The rows and columns containing inside the angle/height
                % ranges.
                % Find the four corners, accounting for the fact that cart2pol
                % runs from -pi to pi.
                theta(1) = min(min(fieldAngle(lBoth) + pi)) - pi;
                theta(2) = max(max(fieldAngle(lBoth) + pi)) - pi;
                radius(1) = min(min(fieldHeight(lBoth)));
                radius(2) = max(max(fieldHeight(lBoth)));
                [Xcorners, Ycorners] = pol2cart( ...
                    [theta(1), theta(1), theta(2), theta(2)], ...
                    [radius(1), radius(2), radius(1), radius(2)]);
                corners = [Xcorners(:), Ycorners(:)];

                % Find the spatial position of these rows and columns and the
                % spatial distance from each point to these points.
                x = xSupport(lBoth);
                y = ySupport(lBoth);

                % Find the distance from each point's (x,y) to the corners.
                clear distance;
                for ii = 1:4
                    distance(:, ii) = sqrt( ...
                        (x - corners(ii, 1)).^2+ ...
                        (y - corners(ii, 2)).^2);
                end

                % We can try various functions to determine these weights
                weights = 1 ./ (distance + eps);
                wNorm = sum(weights');
                weights = diag(1./wNorm) * weights;

                % What we want i an Nx4 matrix that contains the four PSFs in
                % the columns, and we want the weights with respect to the four
                % corners.
                % I am not sure why we need the -1 in front of rad2deg.
                % Also, it is possible that the PSF is rotated by 90 deg.
                if aa == 2
                    tmp = rtPSFInterp(optics, radius(1), -rad2deg(theta(1)), ...
                        wavelength(ww), xGrid, yGrid);
                    PSF(:, 1) = tmp(:);
                    tmp = rtPSFInterp(optics, radius(2), -rad2deg(theta(1)), ...
                        wavelength(ww), xGrid, yGrid);
                    PSF(:, 2) = tmp(:);
                else
                    PSF(:, 1) = PSF(:, 3);
                    PSF(:, 2) = PSF(:, 4);
                end

                tmp = rtPSFInterp(optics, radius(1), -rad2deg(theta(2)), wavelength(ww), xGrid, yGrid);
                PSF(:, 3) = tmp(:);
                tmp = rtPSFInterp(optics, radius(2), -rad2deg(theta(2)), wavelength(ww), xGrid, yGrid);
                PSF(:, 4) = tmp(:);
                s = sum(PSF);
                PSF = PSF * diag(1./s);

                % Compute the spatial point spread by the weighted sum
                pixelByPixel = PSF * weights';

                % Add these point spread functions, pixel by pixel, into the
                % output irradiance image.
                nPixels = size(weights, 1);
                pixelByPixel = reshape(pixelByPixel, psfSize(1), psfSize(2), nPixels);
                [r, c] = find(lBoth);
                rExt = floor(psfSize(1)/2);
                cExt = floor(psfSize(1)/2);
                for pp = 1:nPixels
                    outRow = [(r(pp) - rExt):(r(pp) + rExt)] + extraRow / 2;
                    outCol = [(c(pp) - cExt):(c(pp) + cExt)] + extraCol / 2;
                    % Must account for wavelength!
                    outIrrad(outRow, outCol, ww) = outIrrad(outRow, outCol, ww) ...
                        +inIrrad(r(pp), c(pp), ww) * pixelByPixel(:, :, pp);
                end

                figure(5);
                colormap(gray);
                m = max(max(outIrrad(:, :, ww)));
                imagesc(outIrrad(:, :, ww)/m);
                pause(0.1)

                % Just for display
                %             figure(1)
                %             plot(x,y,'c.',0,0,'rx');
                %             line(corners([4 3 1 2],1),corners([4 3 1 2],2))
                %             axis equal
                %             set(gca,...
                %                 'xlim',[-mxHeight mxHeight],...
                %                 'ylim',[-mxHeight mxHeight]);
                %
                %             figure(2);
                %             rMin = min(y); rMax = max(y); r = rMin:hRes(2):rMax;
                %             cMin = min(x); cMax = max(x); c = cMin:hRes(1):cMax;
                %             [cG,rG] = meshgrid(c,r);
                %             z1 = griddata(x,y,weights(:,1),cG,rG); z1 = replaceNaN(z1,0);
                %             z2 = griddata(x,y,weights(:,2),cG,rG); z2 = replaceNaN(z2,0);
                %             z3 = griddata(x,y,weights(:,3),cG,rG); z3 = replaceNaN(z3,0);
                %             z4 = griddata(x,y,weights(:,4),cG,rG); z4 = replaceNaN(z4,0);
                %
                %             subplot(2,2,1), imagesc(c,r,z1); axis image; axis xy;
                %             subplot(2,2,2), imagesc(c,r,z2); axis image; axis xy;
                %             subplot(2,2,3), imagesc(c,r,z3); axis image; axis xy;
                %             subplot(2,2,4), imagesc(c,r,z4); axis image; axis xy;
                %
                %             % axis equal, imagesc(lBoth); pause(0.1);
                %             figure(3), axis image
                %             for ii = 1:4
                %                 img = reshape(PSF(:,ii),psfSize(1),psfSize(2));
                %                 subplot(2,2,ii), imagesc(img), axis image; axis xy
                %             end

                %             title(sprintf('r%.2f, a%.2f',radius(1),-rad2deg(theta(1))))
                %             title(sprintf('r%.2f, a%.2f',radius(2),-rad2deg(theta(1))))
                %             title(sprintf('r%.2f, a%.2f',radius(1),-rad2deg(theta(2))))
                %             title(sprintf('r%.2f, a%.2f',radius(2),-rad2deg(theta(2))))

                %            pause(1)

                %             figure(4); axis image; axis xy
                %             for pp = 1:size(pixelByPixel,3)
                %                 imagesc(squeeze(pixelByPixel(:,:,pp)))
                %                 pause(0.01)
                %             end
            end
        end
    end
end

toc
