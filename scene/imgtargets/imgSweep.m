function img  = imgSweep(imSize,maxFreq,yContrast)
% Create a sweep frequency image as a test pattern.
%
%     img  = imgSweep(imSize,maxFreq,yContrast)
%
% The frequency increases across the columns; the contrast is high at the
% top row and decreases down the rows. Used by sceneWindow.
%
% Inputs:
%    imSize:  (row,col)
%    maxFreq: Number of cycles per image  (default:  imSize(2)/16)
%
%Example:
%  img  = imgSweep(256,16);  imagesc(img); colormap(gray(64)); axis image
%  img =  imgSweep([128,512],16);  imagesc(img); colormap(gray(64)); axis image
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Set default values for inputs
if ieNotDefined('imSize'), imSize = [128,128]; end
if ieNotDefined('maxFreq'), maxFreq = imSize(2)/16; end
if ieNotDefined('yContrast'), yContrast = []; end

% Ensure imSize is a 2-element vector
if isscalar(imSize), imSize = repmat(imSize, 1, 2); end

%% X positions in the image
x = (1:imSize(2)) / imSize(2);

% Calculate frequency and generate the image
freq = (x.^2) * maxFreq;
xImage = sin(2 * pi * (freq .* x));

if isempty(yContrast)
    yContrast = linspace(1, 0, imSize(1)); % Create contrast vector
end

% Combine contrast and frequency to create the final image
img = yContrast' * xImage + 0.5;
img = ieScale(img, 1, 256); % Scale the image

end
