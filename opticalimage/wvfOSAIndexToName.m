function name = wvfOSAIndexToName(idx)
% Accepts OSA j indices and returns the aberration names (cell array)
%
%  name = wvfOSAIndexToName(idx)
%
% Input
%  idx:  Vector of OSA j indices
%
% Return
%  name: Cell array of aberration names
%
% We follow the naming convention provided in Figure 225 at:
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
% Example:
%   wvfOSAIndexToName([4 5 6])
%
% Copyright Imageval Consulting, LLC 2015

if ieNotDefined('idx'), doc('wvfOsaIndexToName'); end

name = cell(length(idx), 1);
for ii = 1:length(idx)
    switch idx(ii)
        case 1
            name{ii} = 'piston';
        case 2
            name{ii} = 'vertical_tilt';
        case 3
            name{ii} = 'horizontal_tilt';
        case 4
            name{ii} = 'defocus';
        case 5
            name{ii} = 'vertical_astigmatism';
        case 6
            name{ii} = 'vertical_trefoil';
        case 7
            name{ii} = 'vertical_coma';
        case 8
            name{ii} = 'horizontal_coma';
        case 9
            name{ii} = 'oblique_trefoil';
        case 10
            name{ii} = 'oblique_quadrafoil';
        case 11
            name{ii} = 'oblique_secondary_astigmatism';
        case 12
            name{ii} = 'spherical';
        case 13
            name{ii} = 'vertical_secondary_astigmatism';
        case 14
            name{ii} = 'vertical_quadrafoil';
        otherwise
            error('Unknown index %f\n', idx(ii));
    end
end

end
