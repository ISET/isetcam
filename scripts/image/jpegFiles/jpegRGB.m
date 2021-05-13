function dctRGB = jpegRGB(coef, qInfo)
%
% dctRGB = jpegRGB(coef,qInfo)
%
% AUTHOR:  Wandell
% DATE:    02.18.97
% PURPOSE:  Calculate the rgb values from the quantized dct coefficients.
%
% Revised 20 February 1999 by Michael Bax

% DEBUGGING
% coef = rCoef;
% coef(1:4,1:4)

% Check for qtable and optional arguments
%
if nargin < 2
    qTable = jpeg_qtables(50, 1);
elseif size(qInfo) == [1, 1]
    qTable = jpeg_qtables(qInfo, 1);
elseif size(qInfo) == [8, 8]
    qTable = qInfo;
else
    error('jpegRGB:  bad qInfo argument')
end

% Make the IDCT matrix for an 8x8 block transform
%
n = 8;
dctMatrix = zeros(n, n);

c = [1 / sqrt(2), 1, 1, 1, 1, 1, 1, 1];
j = 0:n - 1;
for u = 0:n - 1
    dctMatrix(u+1, :) = (2 * c(u + 1) / n) * cos((2 * j + 1)*u*pi/(2 * n));
end
idctMatrix = 4 * dctMatrix';

[r, c] = size(coef);
newr = round(r/8) * 8;
newc = round(c/8) * 8;
if r ~= newr | c ~= newc
    error('jpegRGB: The coefficients seem wrong, not 8x8 block size');
end

dctRGB = zeros(size(coef));
%for i=1:8:(size(coef,1) - 1)
for i = 1:8:size(coef, 1)
    %  for j=1:8:(size(coef,2) - 1)
    for j = 1:8:size(coef, 2)
        block = coef(i:i+7, j:j+7);
        block = idctMatrix * block * idctMatrix';
        %   dctRGB(i:i+7, j:j+7) = round(block ./ qTable) .* qTable;
        dctRGB(i:i+7, j:j+7) = block;
    end
end

% mmax(dctRGB)
% histogram(dctRGB(:))

return
