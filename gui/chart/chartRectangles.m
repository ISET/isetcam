function [rects,mLocs,pSize] = chartRectangles(cp,nRows,nCols,sFactor)
% Calculate patch midpoint locations and patch size
%
% Syntax:
%   [rects,mLocs,pSize] = chartRectangles(cp,nRows,nCols,sFactor)
%
% Inputs:
%   cp:       Cornerpoints of the chart (x,y) format (chartCornerpoints),
%             but flipped up down so that (1,1) is the upper left
%   nRows:    Number of patches in the rows
%   nCols:    Number of patches in the columns
%   sFactor:  Scale factor for the rectangle size (default 0.8)
%
% Optional
%   N/A
%
% Outputs:
%   rects: Nx4 matrix of rects [cmin, rmin, width, height]
%   mLocs: Array (2,nRows*nCols) of patch midpoints (row;col)
%          The order is down the 1st (left) column, then down the 2nd column,
%          and so forth.
%   pSize: The patch size
%
% Description
%   The cornerpoint coordinate frame is the Matlab image coordinates in
%   which (1,1) is at the upper left.  
%
%   The four cornerpoints that are selected start with the lower left of
%   the chart and then the lower right, upper right, and upper left.  This
%   is determined by the function chartCornerpoints
%
% ieExamplesPrint('chartRectangles')
% 
% See also
%   chartCornerpoints, chartRectsDraw, chartROI, sceneRadianceChart

% Examples:
%{
  % Puts a rect in the center of each of the patches
  wave = 400:10:700;  radiance = rand(length(wave),50)*10^16;
  scene = sceneRadianceChart(wave, radiance,'patch size',20,'rowcol',[15,15]);
  sceneWindow(scene);
  sceneGet(scene,'chart parameters')
  chartP = sceneGet(scene,'chart parameters');
  [rects,mLocs,pSize] = chartRectangles(chartP.cornerPoints,chartP.rowcol(1),chartP.rowcol(2));
  chartRectsDraw(scene,rects);
%}
%{
 scene = sceneCreate; sceneWindow(scene);
 cp = chartCornerpoints(scene);
 [rects,mLocs,pSize] = chartRectangles(cp,4,6,0.9);
 chartRectsDraw(scene,rects);
%}
%{
 scene = sceneCreate;
 sceneW = sceneWindow(scene);
 sz = sceneGet(scene,'size');
 cp = chartCornerpoints(scene,true);
 [rects,mLocs,pSize] = chartRectangles(cp,4,6,.5);
 chartRectsDraw(scene,rects);
%}

%% Set up parameters

if ieNotDefined('cp'), error('Corner points required'); end
if ieNotDefined('nRows'), error('Number of row patches required'); end
if ieNotDefined('nCols'), error('Number of col patches required'); end
if ieNotDefined('sFactor'), sFactor = 0.8; end

% Verify that the slopes on the two edges are similar
dy = cp(2,2) - cp(1,2); dx = cp(2,1) - cp(1,1);
slopeBottom = dy/dx;
dy = cp(3,2) - cp(4,2); dx = cp(3,1) - cp(4,1);
slopeTop = dy/dx;

% Not sure what a reasonable match might be.
if abs(slopeTop - slopeBottom) > 0.5, warning('Top bottom edges are not parallel'); end

dy = cp(1,2) - cp(4,2); dx = cp(4,1) - cp(1,1);
slopeLeft = dy/dx;
dy = cp(2,2) - cp(3,2); dx = cp(3,1) - cp(2,1);
slopeRight = dy/dx;

% Not sure what a reasonable match might be.
if abs(slopeLeft - slopeRight) > 0.5, warning('Left right edges may not be parallel'); end

%% We use the top line and the left line for definition

% How long is the horizontal dimension of the chart (left to right)
chartX   = sqrt((cp(4,1) - cp(3,1))^2  + (cp(4,2) - cp(3,2))^2);

% How long is the vertical dimension of the chart (top to bottom)
chartY = sqrt((cp(4,1) - cp(1,1))^2  + (cp(4,2) - cp(1,2))^2);

% Patch sizes
pSize = round([chartY/nRows,chartX/nCols]);

%% Midpoint locations for each patch

% Each point is some amount down the line at the left edge plus some amount
% down the line across the top.

mLocs = zeros(2,nRows*nCols);  % Columns with row/col ???
ii = 1;
for cc = 1:nCols
    % The extra 1 helps center because there are nCols but we are squeezing
    % them as if there are nCols + 1.
    colFrac = (cc-1)/nCols;
    thisCol = [cp(4,1), cp(4,2)]*(1-colFrac) + [cp(3,1),cp(3,2)]*colFrac;  % (x,y)
    thisCol(1) = thisCol(1) + pSize(1)/2;
    for rr = 1:nRows
        % See comment above about need to add 1 to nRows
        rowFrac = (rr-1)/nRows;
        thisRow = [cp(4,1),cp(4,2)]*(1-rowFrac) + [cp(1,1),cp(1,2)]*rowFrac; % (x,y)
        thisRow(2) = thisRow(2) + pSize(2)/2;
        
        thisPoint = round(thisCol + thisRow - cp(4,:));  % (x,y)
        % drawpoint(ax,'Position',thisPoint,'color','k');  

        % Annoyingly, the mLocs are not in (x,y) format
        mLocs(:,ii) = fliplr(thisPoint);   % (y,x) format, row,col

        ii = ii+1;
    end
end

%% Adjust if there are black borders around the patches
%
%  If there is a black border, the center of the color part is down and to
%  the left compared to what we selected.  About 20% of the total patch
%  size.  So we subtract 10% of the pSize from the x values and add 20% of
%  the pSize to the y values.
%
%{
blackEdge = false;
if blackEdge
 delta = round(pSize/10);
 for ii = 1:(nRows*nCols)
     mLocs(1,ii) = mLocs(1,ii) + delta(1);
     mLocs(2,ii) = mLocs(2,ii) - delta(2);
end
%}

%% Create the rectangles

% You can use ieRect2Locs to return the locations within the rects
nPatches = size(mLocs,2);
rects = zeros(nPatches,4);
for ii=1:nPatches
    [~,rects(ii,:)] = chartROI(mLocs(:,ii),pSize(1)*sFactor);
end

end
