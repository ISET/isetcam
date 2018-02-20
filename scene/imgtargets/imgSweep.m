function img  = imgSweep(imSize,maxFreq)
% Create a sweep frequency image as a test pattern.
%
%     img  = imgSweep(imSize,maxFreq)
%
% The frequency increases across the columns; the contrast is high at the
% top row and decreases down the rows. Used by sceneWindow. 
%  
%Example:
%  img  = imgSweep(256,16);  imagesc(img); colormap(gray); axis image
%  img =  imgSweep;  imagesc(img); colormap(gray); axis image
%  
% Copyright ImagEval Consultants, LLC, 2005.

% Programming Note:
% We should be able to pass in the local frequency as a function of image
% size, as well as the yContrast as a function of image size.  So, perhaps
% the function should be img = imgSweep(imSize,[xFreq],[yContrast]), where
% length(xFreq) = length(yContrast) = imSize.

if ~exist('imSize','var'), imSize = 128; end
if ~exist('maxFreq','var'), maxFreq = imSize/16; end

% X positions in the image.
x = [1:imSize]/imSize;

% The change in frequency is slow at first, and then reaches a maximum
% frequency of one quarter the image size.
freq = (x.^2)*maxFreq;
xImage = sin(2*pi*(freq.*x));
yContrast = [imSize:-1:1]/imSize;

img = yContrast'*xImage + 0.5;
img =  ieScale(img,1,256);

return;
