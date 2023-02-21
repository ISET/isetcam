function croppedImage = imageCropBorder(img)
%IMAGECROPBORDER Crop black border from an image

threshhold = .06; % black level
grayImage = rgb2gray(img);
binaryImage = imbinarize(grayImage, threshhold);
[r, c] = find(binaryImage);
row1 = min(r);
row2 = max(r);
col1 = min(c);
col2 = max(c);
croppedImage = img(row1:row2, col1:col2, :);

end

