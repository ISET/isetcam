function gridimg = drawgrid(imgfile, boxwidth)
% Draw grid with the specified boxwidth on the image
%
% fractal-dimension toolbox
%
% See also
%   getfractaldim (all should be renamed).
%   Just the two functions should go into utilities on ISETCam

img = imread(imgfile);
gridimg = img;
%%%% If image has only 1 channel, convert to RGB format (3 channels)
if length(size(img)) < 3
    gridimg = cat(3, img, img, img);
end
[m, n, p] = size(gridimg);
%%% Construct (magenta) grid lines
for i=1:boxwidth:m
    for j=1:n
        for k=1:p
            gridimg(i,j,k) = 255;
        end
        gridimg(i,j,2) = 0;
    end
end
for j=1:boxwidth:n
    for i=1:m
        for k=1:p
            gridimg(i,j,k) = 255;
        end
        gridimg(i,j,2) = 0;
    end
end
imshow(gridimg);

%%% Save image, `imgfile` must be a character array
% imwrite(gridimg, "plots/"+imgfile(5)+"-grid-"+num2str(boxwidth)+".png");
end