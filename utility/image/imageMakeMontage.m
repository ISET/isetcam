function  [img,coords] = imageMakeMontage(hc, sliceList, nCols, backVal)
% Create an image comprising a montage of the slices in hc
%
% img = imageMakeMontage(hc, [sliceList=all], [nCols], [backVal])
%
% hc:         x by y by sliceNum
% sliceList:   slices to include. Defaults to all 
% nCols:      number of columns in the image montage
% backVal:    Background color
%
% Examples:
% [img,coords] = imageMakeMontage(hc);
%  vcNewGraphWin; imagesc(img); colormap(gray); axis equal; axis off;
%
% (c) Imageval, 2012

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
















































































































