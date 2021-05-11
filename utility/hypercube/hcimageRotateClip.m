function [cImg, cPixels] = hcimageRotateClip(hc, clipPrctile, nRot)
% Clip and rotate hypercube data. Used for visualization with specularities
%
%  hc:          Hypercube image data, uint16 usually
%  clipPrctile:  0-100, percentile for clipping
%  nRot:         Number of counter-clockwise rotation steps, usually 0 or 1.
%
% Example:
%
%
%  clipPrctile = 99.9; nRot = 1;
%  [hc,cPixels] = hcimageRotateClip(img,clipPrctile,nRot);
%  vcNewGraphWin; imagesc(cPixels)
%
% (c) Imageval, 2012

if ieNotDefined('hc');
    error('hyper cube image required');
end
if ieNotDefined('clipPrctile'), clipPrctile = 99.9; end
if ieNotDefined('nRot'), nRot = 1; end

[r, c, w] = size(hc);
if abs(nRot) == 1
    cPixels = zeros(c, r); % We rotate the image before clipping, so r,c inverted
    cImg = zeros(c, r, w);
else
    cPixels = zeros(c, r);
    if isa(img, 'uint16'), cImg = zeros(r, c, w, 'uint16');
    else cImg = zeros(c, r, w, 'double');
    end
end

% For each waveband, rotate as requested and clip
h = waitbar(0, 'Rotating and clipping');
for ii = 1:w
    waitbar(ii/w, h)
    if nRot ~= 0
        tmp = rot90(double(hc(:, :, ii)), nRot);
    end
    if clipPrctile < 100
        mx = prctile(tmp(:), clipPrctile);
        cPixels = cPixels + (tmp > mx);
        tmp(tmp > mx) = 0;
    end
    cImg(:, :, ii) = tmp;
end
close(h)

% subplot(1,2,1), imagesc(tmp); axis image; colormap(gray);
% subplot(1,2,2), imagesc(foo); axis image; colormap(gray);
%
return