function [vectorIndex,jIndex] = wvfOSAIndexToVectorIndex(jIndex)
% Convert a list of OSA j values (may be strings) to WVF toolbox indices
%
%   [vectorIndex,jIndex] = wvfOSAIndexToVectorIndex(jIndex)
%
% Convert a list of OSA j values to the index we need to get the right
% entry out of the WVF stored vector.  Since j values start at 0, this
% consists of adding 1 to the indexed location.
%
% This routine accepts a cell array of string names and can convert these
% to the index as well.  We follow the naming convention provided in Figure
% 225 at:
%
%   http://www.telescope-optics.net/monochromatic_eye_aberrations.htm
%
%    Table of names
%=================================
%     j   name
%
%     0  'piston'
%     1  'vertical_tilt'
%     2  'horizontal_tilt'
%     3  'oblique_astigmatism'
%     4  'defocus'
%     5  'vertical_astigmatism'
%     6  'vertical_trefoil'
%     7  'vertical_coma'
%     8  'horizontal_coma'
%     9  'oblique_trefoil'
%     10 'oblique_quadrafoil'
%     11 'oblique_secondary_astigmatism'
%     12 'primary_spherical', 'spherical'
%     13 'vertical_secondary_astigmatism'
%     14 'vertical_quadrafoil'
%
% See also: wvfOSAIndexToZernikeNM, wvfZernikeNMToOSAIndex, zernfun
%
% I would add 'tip' as a synonym for one of the two tilts below, if I
% knew which one it was.
%
% Validation code
%   [vectorIndex] = wvfOSAIndexToVectorIndex([0 1 2 3 4 5])
%   [vectorIndex,jIndex] = wvfOSAIndexToVectorIndex({'piston', 'defocus' 'vertical_astigmatism', 'primary_spherical'})
%
% (DB, BW) (c) Wavefront Toolbox Team, 2012

% If a single string, that's OK.  We put it to a singleton cell.
if ischar(jIndex), jIndex = {jIndex}; end

if (iscell(jIndex))
    for i = 1:length(jIndex)
        switch (jIndex{i})
            case 'piston'
                n(i) = 0; m(i) = 0;
            case {'vertical_tilt'}
                n(i) = 1; m(i) = -1;
            case 'horizontal_tilt'
                n(i) = 1; m(i) = 1;
            case 'oblique_astigmatism'
                n(i) = 2; m(i) = -2;
            case 'defocus'
                n(i) = 2; m(i) = 0;
            case 'vertical_astigmatism'
                n(i) = 2; m(i) = 2;
            case 'vertical_trefoil'
                n(i) = 3; m(i) = -3;
            case 'vertical_coma'
                n(i) = 3; m(i) = -1;
            case 'horizontal_coma'
                n(i) = 3; m(i) = 1;
            case 'oblique_trefoil'
                n(i) = 3; m(i) = 3;
            case 'oblique_quadrafoil'
                n(i) = 4; m(i) = -4;
            case 'oblique_secondary_astigmatism'
                n(i) = 4; m(i) = -2;
            case {'primary_spherical','spherical'}
                n(i) = 4; m(i) = 0;
            case 'vertical_secondary_astigmatism'
                n(i) = 4; m(i) = 2;
            case 'vertical_quadrafoil'
                n(i) = 4; m(i) = 4;
            otherwise
                error('Unknown aberration string specified');
        end
    end
    jIndex = wvfZernikeNMToOSAIndex(n,m);
end

vectorIndex = jIndex + 1;

end
