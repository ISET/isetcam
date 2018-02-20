function dctQuant = jpegCoef(im,qInfo)
% 
% coef = dctQC(im,qInfo)
% 
% AUTHOR:  Wandell
% DATE:    02.18.97
% PURPOSE:  Calculate the quantized dct coefficients of an image.
%
% Revised 20 February 1999 by Michael Bax
%
% qInfo:
%    If this is a real number, then it is a quality factor
%    If it is a matrix, then it must be a qTable
% 

% DEBUGGING
% 
% qInfo = 50;

if nargin < 2
  qTable = jpeg_qtables(50,1);
elseif size(qInfo) == [1 1]
  disp('jpegCoef:  Using passed quality factor') 
  qTable = jpeg_qtables(qInfo,1);  
elseif size(qInfo) == [8 8]
  disp('jpegCoef:  Using passed lookup table') 
  qTable = qInfo;
else
  error('jpegCoef:  Bad qInfo argument')
end

% Make the DCT matrix for an 8x8 block transform
% 
n = 8;
dctMatrix = zeros(n,n);

c = [ 1/sqrt(2) 1 1 1 1 1 1 1 ];
j = 0:n-1;
for u = 0:n-1
  dctMatrix(u+1,:) = (2*c(u+1) / n)* cos( (2*j+1) * u * pi / (2*n));
end

% Compute the quantized coefficients.  I am not doing the right
% thing here about padding the final block.  Sigh.  I am just
% clipping the whole damn image.
% 
[r c] = size(im);
newr = floor(r/8)*8;
newc = floor(c/8)*8;
if r ~= newr | c ~= newc
  im = im(1:newr,1:newc);
  fprintf('Shrinking image for block size.  Size %4.0f %4.0f\n', ...
	newr,newc);
end

if max(im(:)) < 1.001
  fprintf('Image max < 1.  Treating as 8 bit input\n');
  im = im*255;
end

dctQuant = zeros(size(im));
%for i=1:8:(size(im,1) - 8)
for i=1:8:size(im,1)
%  for j=1:8:(size(im,2) - 8)
  for j=1:8:size(im,2)
    block = im(i:i+7, j:j+7);
    dctCoef = dctMatrix*block*dctMatrix';
    dctQuant(i:i+7, j:j+7) = round(dctCoef ./ qTable) .* qTable;
  end
end

% hist(block(:))
% hist(dctQuant(:))

return
