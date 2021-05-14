function Iout = rtOTF(scene,oi)
%Optical transfer function computation using ray tracing data
%
%    Iout = rtOTF(scene,oi)
%
% The spatially varying lens PSF is applied to an irradiance image.  Prior
% to arriving at this point the optical image irradiance data have been
% distorted and relative illumination has been applied.
%
% The PSFs applied in this routine are determined at each field location
% (height and angle) and for each wavelength.  The distortion data are used
% to determine where we are located in the field.  We use this position to
% interpolate the PSF.
%
% The algorithm is
%
%   (a) Extract the irradiance image at a single wavelength
%   (b) Extract data from a block
%        (number of blocks per field height sample can be set)
%   (c) Pad the block data
%   (d) Retrieve the relevant optics PSF and interpolate it to match the block data
%   (e) Convolve the data with PSF
%   (f) Add the result into an intermediate computational image
%
% Copyright ImagEval Consultants, LLC, 2003.

% Algorithm notes
%
% We should re-write this algorithm.
%
% The next iteration should
%
%  (a) Skip the rtGeometry phase for Zemax because we think the geometry may be
%  already in the point spread function. To check, using Dmitry's data.
%
%  (b) Do the point spread calculation for each point in the image but
%  using interpolated PSF measurements.  The way to approach this might be:
%     - Calculate a PSF for the corners of each block
%     - For each block
%        -- upsample the block to the PSF resolution
%        -- find the distance from each point to each PSF
%        -- output the distance-weighted sum of the PSF convolutions
%        -- downsample the result to the irradiance resolution
%
%  This uses a small number of PSFs to calculate a point-by-point
%  shift-variant output.

% Programming notes
%
% The irradiance image has dimension row,col
% The padded irradiance image accomodates the block size evenly.
%   It has dimension rowP = scenePadding + row, and colP
% The output image is further increased to allow for the block padding during convolution
%   It has dimension rowO = rowP + blockPadding = row + scenePadding + blockPadding
%   and similarly colO.
%
% The block data we filter have dimensions blockSamples
% The padded irradiance block data have dimensions
%   rowF = blockSamples + 2*blockPading
%
% Never let the data block size (in microns) limit the extent of the PSF.
% Always choose a rowF,colF value that allows the entire PSF to be
% captured.

if ieNotDefined('scene'), error('Scene undefined.'); end
if ieNotDefined('oi'), error('Optical image undefined.'); end

rows = sceneGet(scene,'rows');  cols = sceneGet(scene,'cols');
wavelength = sceneGet(scene,'wavelength'); nWave = sceneGet(scene,'nWave');
optics = oiGet(oi,'optics');

% We prefer a block size so that we have at least s blocks per field
% height sample, the #samples is a power of 2, and we have an odd number of
% section samples. Is this possible?
stepsFH = opticsGet(optics,'rtBlocksPerFieldHeight');
[nBlocks, blockSamples, irradPadding] = rtChooseBlockSize(scene,oi,optics,stepsFH);
blockPadding = blockSamples/2;  % Use this variable to replace secPadding
rowP = nBlocks*blockSamples(1);
colP = nBlocks*blockSamples(2);

% This is the size of the final, output image.
rowO = rowP + 2*blockPadding(1);
colO = colP + 2*blockPadding(2);
Iout = zeros(rowO,colO,nWave);

% Find the spatial support for the PSF and for the filtered block in mm
% units.
% TODO:
% Never let the data block size (in microns) limit the extent of the PSF.
% Always choose a rowF,colF value that allows the entire PSF to be
% captured.
[filteredBlockX, filteredBlockY, mmPerRow, mmPerCol] = ...
    rtFilteredBlockSupport(oi,blockSamples,blockPadding);
rowF = length(filteredBlockY);
colF = length(filteredBlockX);

% Find image center needed to calculate the field height and field angle.
imageCenter = [floor(rowP/2) + 1, floor(colP/2) + 1];
showBar = ieSessionGet('waitbar');

if showBar, wbar = waitbar(0,'Ray Trace OTF'); end

tic
ii = 0;
for ww = 1:nWave
    irradiance = oiGet(oi,'photons',wavelength(ww));
    irradianceP = padarray(irradiance,irradPadding);
    str = sprintf('Ray Trace OTF (wave: %.0f)', wavelength(ww));
    
    % Comment out some time
    figure(1); colormap(gray); imagesc(irradianceP); axis image; axis tight;
    r = [0:blockSamples(1):rowP] + 1;
    c = [0:blockSamples(2):colP] + 1;
    for rr = 1:nBlocks, line([1,colP],[r(rr),r(rr)]); end
    for cc = 1:nBlocks, line([c(cc),c(cc)], [1,rowP]); end
    set(gca,'xtick',c,'ytick',r');
    
    for rBlock=1:nBlocks
        for cBlock = 1:nBlocks
            if showBar, waitbar(ii/(nWave*nBlocks*nBlocks),wbar,str); end
            ii = ii + 1;
            [blockData,rList,cList] = rtExtractBlock(irradianceP,blockSamples,rBlock,cBlock);
            % figure(5); colormap(gray);
            % imagesc(blockData); axis image; axis equal; axis tight
            % max(abs(irradianceP(rList,cList) - blockData))
            
            d = rtBlockCenter(rBlock,cBlock,blockSamples) - imageCenter;
            [fieldAngle,fieldHeight] = cart2pol(d(1)*mmPerRow,d(2)*mmPerCol);
            fieldAngle = rad2deg(fieldAngle);
            % fieldAngle = 0;
            
            % fprintf('rBlock %.0f cBlock %.0f fieldHeight %.3f (mm) fieldAngle %.0f (deg)\n',...
            %    rBlock,cBlock,fieldHeight,fieldAngle);
            PSF = rtPSFInterp(optics,...
                fieldHeight,fieldAngle,wavelength(ww),...
                filteredBlockX(:)',filteredBlockY(:));
            PSF(isnan(PSF)) = 0;
            % figure; mesh(filteredBlockX(:)',filteredBlockY(:),PSF)
            
            % PSF = fspecial('gaussian',[rowF,colF],(fieldHeight + 1)*(rowF/30));
            
            filteredData = padarray(blockData,blockPadding);
            % figure(4); imagesc(filteredData), colormap(gray), axis tight
            % Make sure we are still at unit area
            k = sum(PSF(:));
            if k > 0, PSF = PSF/k; end
            
            % If it is worth filtering, do it.  Otherwise, just copy it in.
            if max(PSF(:)) < .98
                filteredData = conv2(PSF,filteredData,'same');
            end
            
            Iout(:,:,ww) = rtInsertBlock(Iout(:,:,ww),filteredData,blockSamples,blockPadding,rBlock,cBlock);
            figure(6); colormap(gray); imagesc(Iout(:,:,ww));
            title(sprintf('%.0f',wavelength(ww)));
            pause(0.01);
        end
    end
end
toc
if showBar, delete(wbar); end

% Now, we could clip the Iout data back a bit, no?

return;

%----------------------------------------------------------
function [blockX, blockY, mmRow, mmCol] = rtFilteredBlockSupport(oi,blockSamples,blockPadding);

mmRow = oiGet(oi,'hspatialresolution','mm');
mmCol = oiGet(oi,'wspatialresolution','mm');

% This is the size of the filtered section
rowF = blockSamples(1) + 2*blockPadding(1);
colF = blockSamples(2) + 2*blockPadding(2);

% Call the middle pixel 0.  The middle pixel is always on the sampling
% grid.  I am unsure whether the position of the 0 with respect to the
% sampling grid matters.  But it might shift things.
blockX = [1:colF]*mmCol;
blockX = blockX - blockX(floor(colF/2) + 1);

blockY = [1:rowF]*mmRow;
blockY = blockY - blockY(floor(rowF/2) + 1);

blockX =  blockX(:)';
blockY =  blockY(:);

return;

