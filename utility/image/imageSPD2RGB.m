function RGB = imageSPD2RGB(SPD,wList,gam)
%Obsolete:  Convert SPD image to a visible range RGB image
%
%    rgbimg = imageSPD2RGB(SPD,wList,gam)
%
% Convert a spectral power distribution (SPD) in XW format with many
% wavelengths, into an XW format image with 3 dimensions.  If a gamma value
% is passed in, then it is applied to the entire RGB matrix.
%
% The data are summed across wavelength bands in order to form an RGB
% image. The wavelength summation is determined by a matrix built in the
% function colorBlockMatrix.  We suppress IR information in this rendering
% using only the visible parts of the spectrum.
%
% See imageSPD for the main use of this function
%
% Examples:
%
%
%
% Copyright ImagEval Consultants, LLC, 2003.
%

% Programming TODO:
%   Perhaps we should convert the signal to a 'scaled' XYZ and then use
%   xyz2srgb for the display.
%

error('No longer used.  Call imageSPD which also returns RGB.');


% This  matrix pools the data across wavelength.  This matrix is designed
% to make the colors look reasonable, but this is not accurate rendering.
% cMatrix = colorBlockMatrix(wList,0);
%
% if length(wList) > 1
%     RGB = SPD*cMatrix;
% else
%     [r,c] = size(SPD);
%     RGB = zeros(r,c,3);
%     for ii=1:3, RGB(:,:,ii) = SPD*cMatrix(ii);end
%     RGB = RGB2XWFormat(RGB);
% end
%
% RGB = ieClip(RGB,0,[]);
% s   = max(RGB(:));
%
% if s == 0
% else RGB = RGB/s;
% end
%
% if exist('gam','var') && gam ~= 1, RGB = RGB.^gam; end
%
% return;
%
