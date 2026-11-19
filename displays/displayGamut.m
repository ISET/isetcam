function [uData, g] = displayGamut(d,varargin)
% Compute and render a display gamut in CIE xy or XYZ coordinates.
%
% Syntax:
%   [uData, g] = displayGamut(d,'space','xy')
%   [uData, g] = displayGamut(d,'space','xyz')
%
% Inputs:
%   d - Display structure. All primaries are included (up to 12).
%
% Optional key/value pairs:
%   space        - 'xy' (default) or 'xyz'.
%   subdivisions - Triangle subdivision steps for XYZ coloring (default 3,
%                  integer from 0 to 6). Geometry is exact at every level.
%   faceAlpha    - XYZ surface opacity, from 0 to 1 (default 1).
%   plot         - Render a figure (default true). False computes data only.
%
% Returns:
%   uData - Struct with space, primaryXYZ, and a closed xy boundary. In XYZ
%           mode also contains corners, vertices, triangular faces, and
%           vertex sRGB colors (rgb). XYZ is absolute; Y is in cd/m^2.
%   g     - Figure handle, or [] when plot is false. UserData holds uData.
%
% Description:
%   Assumes additive primaries with independent linear intensities in [0,1].
%   The xy boundary is the convex hull of nonzero primary chromaticities.
%   The XYZ boundary is the convex hull of all on/off primary combinations.
%   Gamma affects digital sampling, but not this continuous linear gamut.
%   Ambient/black radiance is excluded. Surface colors are approximate sRGB,
%   normalized to display white luminance and clipped to the sRGB gamut.
%
% Examples:
%   d = displayCreate('LCD-Apple');
%   displayGamut(d);
%   [data, fig] = displayGamut(d,'space','xyz','faceAlpha',0.8);
%   exportgraphics(fig,'display-gamut.png');
%
% See also: displayPlot, displayGet, chromaticityPlot, xyz2srgb

p = inputParser;
p.addRequired('d',@isstruct);
p.addParameter('space','xy',@(x) ischar(x) || (isstring(x) && isscalar(x)));
p.addParameter('subdivisions',3,@(x) isnumeric(x) && isscalar(x) && ...
    isfinite(x) && x >= 0 && x <= 6 && x == fix(x));
p.addParameter('faceAlpha',1,@(x) isnumeric(x) && isscalar(x) && ...
    isfinite(x) && x >= 0 && x <= 1);
p.addParameter('plot',true,@(x) islogical(x) && isscalar(x));
p.parse(d,varargin{:});
space = validatestring(p.Results.space,{'xy','xyz'});
g = [];

primaryXYZ = displayGet(d,'rgb2xyz');
if isempty(primaryXYZ) || any(~isfinite(primaryXYZ(:))) || ...
        any(primaryXYZ(:) < 0) || ~any(primaryXYZ(:) > 0)
    error('displayGamut:InvalidPrimaries','Primaries must have finite, nonnegative XYZ values and nonzero output.');
end
xy = unique(chromaticity(primaryXYZ(sum(primaryXYZ,2) > 0,:)),'rows');
if size(xy,1) >= 3 && rank(xy - xy(1,:)) == 2
    boundary = convhull(xy(:,1),xy(:,2));
else
    % A monochromatic or collinear display has a point or line gamut.
    boundary = [1; size(xy,1); 1];
end
uData.space = space;
uData.primaryXYZ = primaryXYZ;
uData.xy = xy(boundary,:);

if strcmp(space,'xyz')
    nPrimaries = size(primaryXYZ,1);
    if nPrimaries > 12
        error('displayGamut:TooManyPrimaries','XYZ gamut supports at most 12 independent primaries.');
    end
    if rank(primaryXYZ) < 3
        error('displayGamut:DegenerateGamut','Primaries do not span a three-dimensional XYZ gamut.');
    end
    levels = dec2bin(0:2^nPrimaries-1,nPrimaries) - '0';
    corners = unique(levels * primaryXYZ,'rows');
    faces = convhulln(corners);
    vertices = corners;
    % Refine planar triangles to color the boundary after sRGB conversion.
    for ii = 1:p.Results.subdivisions
        n = size(vertices,1);
        count = size(faces,1);
        a = vertices(faces(:,1),:);
        b = vertices(faces(:,2),:);
        c = vertices(faces(:,3),:);
        vertices = [vertices; (a+b)/2; (b+c)/2; (c+a)/2]; %#ok<AGROW>
        ab = n + (1:count)';
        bc = ab + count;
        ca = bc + count;
        faces = [faces(:,1), ab, ca; ab, faces(:,2), bc; ...
            ca, bc, faces(:,3); ab, bc, ca];
    end
    whiteY = sum(primaryXYZ(:,2));
    rgb = xyz2srgb(reshape(vertices/whiteY,[],1,3));
    uData.corners = corners;
    uData.vertices = vertices;
    uData.faces = faces;
    uData.rgb = reshape(rgb,[],3);
end

if ~p.Results.plot, return; end
switch space
    case 'xy'
        g = chromaticityPlot([], 'gray',256);
        line(uData.xy(:,1),uData.xy(:,2),'Color',[.2 .2 .2], ...
            'LineWidth',2,'Tag','gamutBoundary');
        title('Display gamut in CIE xy');
    case 'xyz'
        g = ieNewGraphWin;
        patch('Vertices',uData.vertices,'Faces',uData.faces, ...
            'FaceVertexCData',uData.rgb,'FaceColor','interp', ...
            'EdgeColor','none','FaceAlpha',p.Results.faceAlpha, ...
            'Tag','gamutPatch','Parent',gca);
        xlabel('X'); ylabel('Y (cd/m^2)'); zlabel('Z');
        title('Display gamut in CIE XYZ');
        axis equal; grid on; view(3);
end
set(g,'UserData',uData);
end
