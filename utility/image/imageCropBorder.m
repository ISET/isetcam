function croppedImage = imageCropBorder(img)
%IMAGECROPBORDER Crop black border from an image

threshhold = .06; % black level

if isequal(class(img),'cell')
    img = img{1};
end
try
    grayImage = rgb2gray(img);
catch
    grayImage = im2gray(img);
end
binaryImage = imbinarize(grayImage, threshhold);
[r, c] = find(binaryImage);
row1 = min(r);
row2 = max(r);
col1 = min(c);
col2 = max(c);

% crop if we got results
if (row2 > row1) && (col2 > col1)
    croppedImage = img(row1:row2, col1:col2, :);
else
    croppedImage = img;
end

