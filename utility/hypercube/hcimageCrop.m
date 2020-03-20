function [hc, rect] = hcimageCrop(img,rect,cPlane)
% Select region to crop from a hypercube image
%
% img:   Hypercube input (required)
% rect:  If you know the rect, send it in (default = user chooses)
% cPlane: Which plane to use for cropping (default = 1);
%
% hc:    Cropped hc image
% rect:  rectangle used for croppig
%
% Example:
%    [hc, rect] = hcimageCrop(img,[],1)
%
% (c) Imageval

if ieNotDefined('img'), error('hyper cube image required'); end
if ieNotDefined('cPlane'), cPlane = 1; end

if ieNotDefined('rect')
    % We use a square root to avoid problems with bright, saturating
    % pixels.
    tmp = sqrt(double(img(:,:,cPlane))); 
    tmp = tmp/max(tmp(:));
    f = ieNewGraphWin;
    imagesc(tmp); colormap(hot); axis image
    [d,rect] = imcrop;
    close(f)
else
    d = imcrop(double(img(:,:,cPlane)),rect);
end

% Create space for cropped image
[r,c] = size(d);
w = size(img,3);
if isa(img,'uint16'),  hc = zeros(r,c,w,'uint16');
else,                  hc = zeros(r,c,w,'double');
end

% Crop each plane
h = waitbar(0,'Cropping');
for ii=1:w
    waitbar(ii/w,h);
    hc(:,:,ii) = imcrop(img(:,:,ii),rect); 
end
close(h);
return
