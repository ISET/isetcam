function rects = chartRects(corners,rcSize)
% Deprecated:  Compute rectangle ROIs for a chart 
%
% Syntax:
%   rects = chartRects(corners,rcSize)
%
% Inputs
%   corners: The corner points defining the chart
%   rcSize:  Row and column patches
%
% Outputs
%   rects:   Matrix of prod(rcSize) rows and 4 columns of rect positions
% 
% (c) Imageval Consulting, LLC, 2012
%
% See also
%   mcc<TAB>, chart<Tab>
%

% We have the patch size (pSize).  We want the mid points of each patch.
% First figure out where the corners are so we know where to start and end.
upperLeft  = corners.ul;
upperRight = corners.ur;
lowerLeft  = corners.ll;

% We have to figure out the patch separation.  
% We know the rcSize of the chart from above.  We know the corner points in
% the sensor.  So, we can figure out the patch size in the sensor image by
% dividing
chartSize(1) = lowerLeft(1)  - upperLeft(1);
chartSize(2) = upperRight(2) - upperLeft(2);
spSize = round(chartSize ./ rcSize);   % sensor patch size

% The row and column positions start at the edge and step through by pSize
% values.
rowPos = (upperLeft(1) + floor(spSize(1)/2) - 1):spSize(1):lowerLeft(1);
colPos = (upperLeft(2) + floor(spSize(2)/2) - 1):spSize(2):upperRight(2);

% Assign them to mLoc, the middle location.
mLoc = zeros(prod(length(rowPos)*length(colPos)),2);
ii = 1;
for cc = 1:length(colPos)
    for rr = 1:length(rowPos)
        mLoc(ii,:) = [rowPos(rr),colPos(cc)];
        ii = ii+1;
    end
end
% vcNewGraphWin; plot(mLoc(:,1),mLoc(:,2),'.')

% All the locations around a point, say mLoc(1,:) can be found using the
% code in macbethROIs.  We probably want to return the rects and store
% them.
% patchLocs = cell(size(mLoc,1),1);
rects = zeros(size(mLoc,1),4);
delta = round(min(spSize)/2);
for ii=1:size(mLoc,1)
    rect(1) = mLoc(ii,2) - round(delta/2);
    rect(2) = mLoc(ii,1) - round(delta/2);
    rect(3) = delta;
    rect(4) = delta;
    rects(ii,:) = rect;
end

end
