function [x,y] = imageCentroid(img)
% Calculate the image centroid in pixels
%
% Input
%  psf
%
% Optional key/val
%  N/A
%
% Return
% [x,y] - the estimated centroids along the x and y axes
%
% See also
%  t_wvfIBIOJaekenArtal2o12

ySum = sum(img); ySum = ySum/sum(ySum);  % Sum down the y axis
xSum = sum(img,2); xSum = xSum/sum(xSum); % Sum across the x-axis
xPos = (1:size(img,2))';  % Index across x
yPos = (1:size(img,1))';  % Index across y
x = round(ySum  * xPos);  % Weighted sum of x positions
y = round(xSum' * yPos);  % Weighted sum of y positions

end
