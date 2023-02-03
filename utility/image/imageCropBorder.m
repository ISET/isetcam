function croppedImage = imageCropBorder(img)
%IMAGECROPBORDER Crop black border from an image

% Don't know if we need to make a binary image first
[r, c] = find(img);
row1 = min(r);
row2 = max(r);
col1 = min(c);
col2 = max(c);
croppedImage = img(row1:row2, col1:col2);

end

