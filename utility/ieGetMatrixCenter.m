function mc = ieGetMatrixCenter(m,center,extent)
%Obsolete: Another routine to get the center of a matrix.
%
% Use getMiddleMatrix
%
%    mc = ieGetMatrixCenter(mat,center,extent)
%
% Extract data from the center of a matrix.
%
%   center = [rowCenter, colCenter]
%   extent = [rowLength, colLength]
%
% Example: (Doesn't work because of rounding.  Use getMiddleMatrix.
%   tmp = rand(5,5);
%   c = [3,3]; e = [2,1];
%   mc = ieGetMatrixCenter(tmp,c,e)
%
% Copyright ImagEval Consultants, LLC, 2003.



startC = center(1) - extent(1)/2 + 1;
endC   = center(1) + extent(1)/2;
startR = center(2) - extent(2)/2 + 1;
endR   = center(2) + extent(2)/2;

rows = startR:endR;   cols = startC:endC;
nRows = length(rows); nCols = length(cols);
nW = size(m,3);

mc = zeros(nRows,nCols,nW);
for ii=1:nW
    mc = m(rows,cols,ii);
end

return;