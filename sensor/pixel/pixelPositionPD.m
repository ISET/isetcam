function PIXEL = pixelPositionPD(PIXEL,place)
%
%   PIXEL = pixelPositionPD(PIXEL,place)
%
% Author: ImagEval
% Purpose:
%    Place the photodetector with a given height and width at the center of
%    the pixel. This routine places the photodetector upper left corner
%    positions.
%
%     PIXEL = pixelPositionPD(PIXEL,'center')
%
% See also: pixelCenterFillPD.
%

% TODO:  Check that that the sensorCompute is based on
%    this position being the upper left corner, not the center of the
%    photodetector.)

if ~exist('place','var') || isempty(place), place = 'center'; end

switch lower(place)
    case 'center'
        PIXEL.pdXpos = (pixelGet(PIXEL,'width') - pixelGet(PIXEL,'pdWidth'))/2;
        PIXEL.pdYpos = (pixelGet(PIXEL,'height') - pixelGet(PIXEL,'pdHeight'))/2;
        if (PIXEL.pdXpos < 0) || (PIXEL.pdYpos < 0)
            error('Inconsistent photodetector and pixel sizes.');
        end
    % Add support for corner positioning ala Samsung Corner Pixel tech
    case 'corner'
        PIXEL.pdXpos = 0;
        PIXEL.pdYpos = 0;
    otherwise
        error('Unknown placement principle %s.',lower(place));
end

end