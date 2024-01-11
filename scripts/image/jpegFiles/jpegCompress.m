function imjpeg = jpegCompress(im, qtable)
% imjpeg = jpegCompress(im, qtable)
%
% Performs JPEG compression on a gray scale input image.
%
% This function is temporary, for teaching purpose.
%
% Xuemei Zhang 2/13/97

% First check the image size. If not multiples of 8, pad with
% zeros.
properSize = ceil(size(im)/8) * 8;
imfull = zeros(properSize);
imfull(1:size(im,1), 1:size(im,2)) = im;

% If the image values are between 0 and 1, scale to between 0 and
% 255
if (max(imfull(:))<=1)
    imfull = round(imfull*255);
    %imfull = (imfull*255);
end

% make the dct basis functions
n = 8;
c = [ 1/sqrt(2) 1 1 1 1 1 1 1 ];
j = 0:n-1;
dctMatrix = zeros(n,n);
for u = 0:n-1
    dctMatrix(u+1,:) = (2*c(u+1) / n)* cos( (2*j+1) * u * pi / (2*n));
end
idctMatrix = 4*dctMatrix';

% DCT transformation and quntization
dctQuant = zeros(size(imfull));

for i=1:8:size(imfull,1)
    for j=1:8:size(imfull,2)
        block = imfull(i:i+7, j:j+7);
        dctCoef = dctMatrix*block*dctMatrix';
        dctQuant(i:i+7, j:j+7) = round(dctCoef ./ qtable) .* qtable;
    end
end

% Decompress
imjpeg = zeros(size(imfull));

for i=1:8:size(imfull,1)
    for j=1:8:size(imfull,2)
        block = dctQuant(i:i+7, j:j+7);
        imjpeg(i:i+7, j:j+7) = idctMatrix*block*idctMatrix';
    end
end

% Convert to similar range as input image was
if (max(im(:))<=1)
    imjpeg = imjpeg/255;
end

end
