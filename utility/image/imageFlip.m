function imT = imageFlip(im,flipType)
% Flip image data - updown or leftright 
%
%   imT = imageFlip(im,flipType)
%
% The image data, im, size(im) = (r,c,w) can have any value for w.
% imT contains the data from im, but each color plane is flipped
% 'updown' or 'leftright' 
%
% Example:
%   imT = imageFlip(im,'upDown');
%   imT = imageFlip(im,'leftRight');
%
% Copyright ImagEval Consultants, LLC, 2003.

if ndims(im)~=3, error('Input must be rgb image (row x col x w)'); end
if ieNotDefined('flipType'), flipType = 'l'; end

imT = zeros(size(im));
switch lower(flipType(1))
    case {'u','updown'}
        for ii=1:size(im,3)
            imT(:,:,ii) = flipud(im(:,:,ii));
        end
        
    case {'l','leftright'}
        for ii=1:size(im,3)
            imT(:,:,ii) = fliplr(im(:,:,ii));
        end
end

return;