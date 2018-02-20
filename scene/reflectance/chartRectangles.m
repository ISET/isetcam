function [mLocs,pSize] = chartRectangles(cp,rPatch,cPatch)
% Calculate patch midpoint locations and patch size
%
% cp:       Cornerpoints of the chart (x,y) format
% rPatch:   Number of patches in the rows
% cPatch:   Number of patches in the columns
%
% mLocs: Array (2,rPatch*cPatch) of chart patch midpoints (row;col)
%        The order is down the 1st (left) column, then down the 2nd column,
%        and so forth.
%
% Copyright Imageval, LLC 2014

if ieNotDefined('cp'), error('Corner points required'); end
if ieNotDefined('rPatch'), error('Number of row patches required'); end
if ieNotDefined('cPatch'), error('Number of col patches required'); end

% X and Y dimensions (in pixels) of the chart
chartX = cp(2,1) - cp(1,1);
chartY = cp(1,2) - cp(4,2);

% Patch sizes
pSize = round([chartY/rPatch,chartX/cPatch]);

% Midpoint of a single patch
mid = round(pSize/2);

% Midpoint locations for each path
mLocs = zeros(2,rPatch*cPatch);
ii = 1;
for cc=1:cPatch
    for rr=1:rPatch
        mLocs(:,ii) = mid + [pSize(1)*(rr-1),pSize(2)*(cc-1)];
        ii = ii + 1;
    end
end

end
