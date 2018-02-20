function fullmatrix = upperQuad2FullMatrix(upperRight,nRows,nCols)
% Duplicates the upper right quad of a matrix in the other quads
%
%   fullmatrix = upperQuad2FullMatrix(upperRight,nRows,nCols)
%
%   For a full matrix (nRows x nCols), suppose upperRight is the upper
%   right quadrant of a matrix.   
%
%   This routine duplicates the upper right quad in the other quads,
%   mirroring the data. 
%
%   If there is an odd number of output cols, the middle data are always
%   attached to the quadrants on the right side of the data.   If there is
%   an odd number of rows, the middle data are always attached to the upper
%   quadrants. 
%
%Example:
%   upperRight = [1,2,3;4,5,6;7,8,9];
%   nRows = 5;
%   nCols = 6;
%   fullmatrix = upperQuad2FullMatrix(upperRight,nRows,nCols)
%
% Copyright ImagEval Consultants, LLC, 2005.


[r,c] = size(upperRight);
if isodd(nCols),  upperLeft = fliplr(upperRight(:,2:c));
else              upperLeft = fliplr(upperRight);
end

if isodd(nRows),  lowerRight =  flipud(upperRight(1:(r-1),:));
else              lowerRight =  flipud(upperRight);
end

if isodd(nRows),  lowerLeft = flipud(upperLeft(1:(r-1),:));
else              lowerLeft = flipud(upperLeft);
end

fullmatrix = [upperLeft, upperRight; lowerLeft, lowerRight];

return;

