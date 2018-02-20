function img = sensorShowCFAWeights(wgts,sensor,cPos,varargin)
% Create an image of the weights (normalized) on a small CFA region
%
%    img = sensorShowCFAWeights(wgts,sensor,cPos,varargin)
%
% Show the weights (e.g. and L3 kernel) with the color of the sensor CFA.
% The cPos is the center position used from the CFA.  For example, if the
% super pixel array is a 2x2 then cPos could be (2,2) or (1,2) ...
%
% Inputs (required)
%  wgts:  The weights in a patchSize array
%  sensor: The sensor
%  cPos:   The center position of the sensor pattern
%
% Inputs (optional, parameter value pairs)
%  imgSize: Scale final image size to be imgSize*size(wgts) 
%
% Return:
%   img = RGB image of the weights times the CFA colors
%
% Example:
%  sensor = sensorCreate;
%  wgts = rand(5,5);
%  img = sensorShowCFAWeights(wgts,sensor,[1,1],'imgScale',16);
%  vcNewGraphWin; imagesc(img); 
%
%  img = sensorShowCFAWeights(wgts,sensor,[2,1],'imgScale',16);
%  vcNewGraphWin; imagesc(img); 
%
%  img = sensorShowCFAWeights(ones(5,5),sensor,[1,2],'imgScale',32);
%  vcNewGraphWin; imagesc(img); 
%
%  sensor = sensorCreate('cmy');
%  wgts = rand(5,5);
%  img = sensorShowCFAWeights(wgts,sensor,[2,1],'imgScale',16);
%  vcNewGraphWin; imagesc(img); 
%
% See also:
%
% Copyright Imageval Consulting, LLC 2016

%% Set up key variables

p = inputParser;
p.addRequired('wgts',@isnumeric);
p.addRequired('sensor');

patchSize = size(wgts);
p.addOptional('cPos',ceil(patchSize/2),@isnumeric);
p.addOptional('imgScale',32,@isnumeric);

p.parse(wgts,sensor,cPos,varargin{:});
imgScale = p.Results.imgScale;

%% Build the color mosaic image

% This is an index image of the whole cfa
[cfaImage,mp] = sensorImageColorArray(sensorDetermineCFA(sensor));

% Clip a CFA section from the middle of the image, centered on cPos
pattern = sensorGet(sensor,'pattern');
offset = pattern*10 + 1;
h = (patchSize - 1)/2;
cfaImage = cfaImage(offset(1) + cPos(1) + (-h:h),offset(2) + cPos(2) + (-h:h));

cfaImage = ind2rgb(cfaImage,mp);
% vcNewGraphWin; imagesc(cfaImage);

if max(wgts(:)) == min(wgts(:))
    wgts = ones(size(wgts));
else
    wgts = ieScale(wgts,0,1);
end

% Make the image
wgts = repmat(wgts,1,1,3);
img  = wgts .* cfaImage;
img = imageIncreaseImageRGBSize(img,imgScale);

end
