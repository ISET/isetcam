function image = CalFormatToImage(calFormat,nX,nY)
% image = CalFormatToImage(calFormat,nX,nY)
% 
% Convert a calibration format image back to a real
% image.
%
% Note that the order nX,nY makes sense for thinking about images
% in terms of x and y coordinates, but that the order is backwards
% from the MATLAB convention of row dim then column dim.
%
% See also ImageToCalFormat
%
% 8/04/04  dhb  Wrote it.
% 9/1/09   dhb  Update help.
% 10/2/09  dhb  Try again on making help clear.

k = size(calFormat,1);
image = reshape(calFormat',nY,nX,k);
