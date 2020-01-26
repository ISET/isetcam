function [rects,mLocs,pSize] = chartRectangles(cp,rPatch,cPatch,sFactor)
% Calculate patch midpoint locations and patch size
%
% Syntax:
%   [rects,mLocs,pSize] = chartRectangles(cp,rPatch,cPatch,sFactor)
%
% Inputs:
%   cp:       Cornerpoints of the chart (x,y) format
%   rPatch:   Number of patches in the rows
%   cPatch:   Number of patches in the columns
%   sFactor:  Scale factor for the rectangle size (default 0.8)
%
% Optional
%   N/A
%
% Outputs:
%   rects: Nx4 matrix of rects [cmin, rmin, width, height]
%   mLocs: Array (2,rPatch*cPatch) of patch midpoints (row;col)
%          The order is down the 1st (left) column, then down the 2nd column,
%          and so forth.
%   pSize: The patch size
%
% Copyright Imageval, LLC 2014
% 
% See also
%   sceneRadianceChart, chartRectsDraw, chartROI

% Example:
%{
  % Puts a mark in the center of each of the patches
  wave = 400:10:700;  radiance = rand(length(wave),50)*10^16;
  scene = sceneRadianceChart(wave, radiance,'patch size',20);
  sceneWindow(scene);
  sceneGet(scene,'chart parameters')
  chartP = sceneGet(scene,'chart parameters');
  mLocs = chartRectangles(chartP.cornerPoints,chartP.rowcol(1),chartP.rowcol(2));
  
  % Draw
  a = get(sceneWindow,'CurrentAxes'); 
  hold(a,'on'); 
  plot(mLocs(2,:),mLocs(1,:),'o');
  hold(a,'off');
%}

%% Set up parameters

if ieNotDefined('cp'), error('Corner points required'); end
if ieNotDefined('rPatch'), error('Number of row patches required'); end
if ieNotDefined('cPatch'), error('Number of col patches required'); end
if ieNotDefined('sFactor'), sFactor = 0.8; end

% X and Y dimensions (in pixels) of the chart
chartX = cp(2,1) - cp(1,1);
chartY = cp(1,2) - cp(4,2);

% The extra 1 has to do with the rect definitions in chartCornerpoints
% These min values center the squares.
minX = cp(1,1)-1; minY = cp(4,2)-1;

% Patch sizes
pSize = round([chartY/rPatch,chartX/cPatch]);

% Midpoint of a single patch
mid = round(pSize/2);

%% Midpoint locations for each patch

% These are still in row,col format.
mLocs = zeros(2,rPatch*cPatch);
ii = 1;
for cc=1:cPatch
    for rr=1:rPatch
        mLocs(:,ii) = mid + [pSize(1)*(rr-1),pSize(2)*(cc-1)] + [minY, minX];
        ii = ii + 1;
    end
end

%% The rectangles

% You can use ieRect2Locs to return the locations within the rects
nPatches = size(mLocs,2);
rects = zeros(nPatches,4);
for ii=1:nPatches
    [~,rects(ii,:)] = chartROI(mLocs(:,ii),pSize(1)*sFactor);
end

end
