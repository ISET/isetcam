%
%	Make the dct Algorithms components
%
% cd /wusr5/brian/book/07imgrep/fig/subDctAlgorithm

%makeDctMatrix;

load dctMatrix;
load adam
nGray = 220;
adam = adam(1:128,1:128);
im = scale(adam,1,nGray);
[coefScaleFactor compressionFactor] = makeQTable(50);
compressionFactor
%
%	Read in and print out the clown image
%
% Select a region of the image to process for example
xStart = 35;
yStart = 110;
block = im(xStart:xStart+7,yStart:yStart+7);
%
%	Equivalent to qBlock = dctidct(block,coefScaleFactor)
%
dctCoef = dctMatrix*block*dctMatrix';
qCoef = round(dctCoef .* coefScaleFactor) ./ coefScaleFactor;
qBlock = idctMatrix*qCoef*idctMatrix';
%
%	Now, make the images
%
figure(1)
colormap(gray(nGray));
mp = colormap;
image(im); axis equal; axis off
overlayBox([ xStart yStart; xStart + 7 yStart + 7],[1 1 1]);
X = scale(im,1,nGray);
image(X); axis off; axis equal
tiffwrite(X,mp,'imBox.tif');

X = scale(block,1,nGray);
image(X); axis off; axis equal
tiffwrite(X,mp,'block.tif');

X = scale(log(abs(dctCoef +1)),1,nGray);
image(X); axis off; axis equal
tiffwrite(X,mp,'dctCoef.tif');

X = scale(log(coefScaleFactor),1,nGray);
image(X); axis off; axis equal
tiffwrite(X,mp,'coefScaleFactor.tif');

X = scale(log(abs(qCoef + 1)),1,nGray);
image(X); axis off; axis equal
tiffwrite(X,mp,'qCoef.tif');

X = scale(qBlock,1,nGray);
image(X); axis off; axis equal
tiffwrite(X,mp,'qBlock.tif');

%
%	Now, go through the whole image, block by block
%	and make the compressed image
%
%testIm = im(1:4:m,1:4:n);
%image(testIm)

[m n] = size(im);
compressedIm = zeros(size(im));
for i= 1:8:m-1
    for j=1:8:n-1
        %  [i j]
        block = im(i:i+7,j:j+7);
        dctCoef = dctMatrix*block*dctMatrix';
        qCoef = round(dctCoef .* coefScaleFactor) ./ coefScaleFactor;
        compressedIm(i:i+7,j:j+7) = idctMatrix*qCoef*idctMatrix';
    end
end
image(compressedIm)
axis equal; axis off
mp = colormap;

X = scale(compressedIm,1,nGray);
image(X); axis off; axis equal
tiffwrite(X,mp,'adamCompressed.tif')

diffImage = scale(compressedIm,1,nGray) - scale(im,1,nGray);
X = scale(diffImage,1,nGray);
tiffwrite(X ,mp,'diffImage.tif')

%
%	Look at the difference image a bit
image(X)
mmax(X)
mmin(X)
mean(mean(X))
list = (X > 200);
imagesc(list)
