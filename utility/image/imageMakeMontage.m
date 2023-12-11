function  [img,coords] = imageMakeMontage(hc, sliceList, nCols, backVal)
% Create an image comprising a montage of the slices in the image stack hc
%
% Synopsis
%   img = imageMakeMontage(hc, [sliceList=all], [nCols], [backVal])
%
% Inputs:
%   hc:         x by y by sliceNum
%   sliceList:  slices to include. Defaults to all
%   nCols:      number of columns in the image montage
%   backVal:    Background color
%
% Returns:
%   img:   The image montage
%   coords:  Not sure yet
%
% Description
%    This was designed for a hypercube data set. The slice list determines
%    which wavelengths are used to create the montage.
%
%    The method can also be used for a collection of ordinary luminance
%    images that are stacked into a hypercube.  See the example below (to
%    be written).
%
% (c) Imageval, 2012
%
% See also
%   hcimage (utility/hypercube)

% Examples:
%{
scene = sceneCreate('sweep frequency'); wave = sceneGet(scene,'wave');
for ii=1:numel(wave)
    hc(:,:,ii) = sceneGet(scene,'photons',wave(ii));
end
[img,coords] = imageMakeMontage(hc);
ieNewGraphWin; imagesc(img);
colormap(gray(64)); axis equal; axis off;
%}

%%
if ieNotDefined('hc'), error('hypercube data required.'); end

[r,c,w] = size(hc);
if ieNotDefined('sliceList'), sliceList = 1:w; end
if ieNotDefined('nCols'), nCols = []; end
if ieNotDefined('backVal'), backVal = 0; end

% If the hc is too large, refuse to play.
if(any(size(hc)>10000))
    error('At least one dimension of input image is >10,000- refusing to continue...');
end

%% Make a best guess about the number of columns
nImages = length(sliceList);
if(isempty(nCols)), nCols = ceil(sqrt(nImages)*sqrt((r/c))); end
nRows = ceil(nImages/nCols);

% Allocate for the image.  Can we put the class(hc) in here?
img = ones(r*nRows,c*nCols,class(hc))*backVal;

count = 0;
nSlices = length(sliceList);
coords = zeros(nSlices,2);
for ii = 1:nSlices
    curSlice = sliceList(ii);
    count = count+1;
    x = rem(count-1, nCols)*c;
    y = floor((count-1)/ nCols)*r;
    img(y+1:y+r,x+1:x+c) = hc(:,:,curSlice);
    coords(ii,:) = [x+1,y+1];
end


return
















































































































