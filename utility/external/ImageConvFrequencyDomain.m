function [ mO ] = ImageConvFrequencyDomain( mI, mH, convShape )
% ----------------------------------------------------------------------------------------------- %
% [ mO ] = ImageConvFrequencyDomain( mI, mH, convShape )
% Applies Image Convolution in the Frequency Domain.
% Input:
%   - mI                -   Input Image.
%                           Structure: Matrix (numRows x numCols).
%                           Type: 'Single' / 'Double'.
%                           Range: (-inf, inf).
%   - mH                -   Filtering Kernel.
%                           Structure: Matrix.
%                           Type: 'Single' / 'Double'.
%                           Range: (-inf, inf).
%   - convShape         -   Convolution Shape.
%                           Sets the convolution shape.
%                           Structure: Scalar.
%                           Type: 'Single' / 'Double'.
%                           Range: {1, 2, 3}.
% Output:
%   - mI                -   Output Image.
%                           Structure: Matrix.
%                           Type: 'Single' / 'Double'.
%                           Range: (-inf, inf).
% References:
%   1.  MATLAB's 'conv2()' - https://www.mathworks.com/help/matlab/ref/conv2.html.
% Remarks:
%   1.  For the transformation the (0, 0) of the image and the kernel is
%       the top left corner of teh matrix (i = 1, j = 1). Hence it can be
%       thought that a shifting is needed (To center the kernel).
%   1.  The function supports single channel image only.
% TODO:
%   1.  
%   Release Notes:
%   -   1.0.000     29/04/2021  Royi Avital     RoyiAvital@yahoo.com
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

CONV_SHAPE_FULL     = 1;
CONV_SHAPE_SAME     = 2;
CONV_SHAPE_VALID    = 3;

numRows     = size(mI, 1);
numCols     = size(mI, 2);

numRowsKernel = size(mH, 1);
numColsKernel = size(mH, 2);

switch(convShape)
    case(CONV_SHAPE_FULL)
        numRowsFft  = numRows + numRowsKernel - 1;
        numColsFft  = numCols + numColsKernel - 1;
        firstRowIdx = 1;
        firstColIdx = 1;
        lastRowIdx  = numRowsFft;
        lastColdIdx = numColsFft;
    case(CONV_SHAPE_SAME)
        numRowsFft  = numRows + numRowsKernel;
        numColsFft  = numCols + numColsKernel;
        firstRowIdx = ceil((numRowsKernel + 1) / 2);
        firstColIdx = ceil((numColsKernel + 1) / 2);
        lastRowIdx  = firstRowIdx + numRows - 1;
        lastColdIdx = firstColIdx + numCols - 1;
    case(CONV_SHAPE_VALID)
        numRowsFft = numRows;
        numColsFft = numCols;
        firstRowIdx = numRowsKernel;
        firstColIdx = numColsKernel;
        lastRowIdx  = numRowsFft;
        lastColdIdx = numColsFft;
end

mO = ifft2(fft2(mI, numRowsFft, numColsFft) .* fft2(mH, numRowsFft, numColsFft), 'symmetric');
mO = mO(firstRowIdx:lastRowIdx, firstColIdx:lastColdIdx);


end
