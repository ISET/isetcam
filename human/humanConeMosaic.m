function [xy, coneType, densities, rSeed] = ...
    humanConeMosaic(sz, densities, umConeWidth, rSeed)
% Create an xy spatial representation of the human cone mosaic
%
% Syntax:
%   [xy, coneType, densities, rSeed] = humanConeMosaic(sz, densities, ...
%       umConeWidth, rSeed)
%
% Description:
%    Create an xy spatial representation of the human cone mosaic.
%
%    The order of the vector densities should K, L, M, S -> 1, 2, 3, 4, but
%    we patch up some cases when only (L, M, S) are sent in. Not preferred.
%
%    This function contains examples of usage inline. To access, type 'edit
%    humanConeMosaic.m' into the Command Window.
%
% Inputs:
%    sz          - Vector. 1x2 vector containing the grid size in the
%                  format of [row, col].
%    densities   - (Optional) Vector. 1x4 vector containing the sum of the
%                  densities. If sum < 1, some locations will have a 0,
%                  meaning the receptor at that location has zero
%                  spectralQE. However, it does respond with noise in the
%                  sensor image. Format is [Empty, L, M, S]. Default is
%                  [0.1 0.55 0.25 0.1]
%    umConeWidth - (Optional) Numeric. Cone width in microns. Default 2.
%    rSeed       - (Optional) Numeric. Set the random number seed (for
%                  repeatability). Default is to use rng to generate.
%
% Outputs:
%    xy          - Matrix. Format of sz(1) * sz(2) by 2. The matrix
%                  contains the positions in microns.
%    coneType    - Matrix. A matrix of sz(1) by sz(2) containing the
%                  integers 1:4, which represent K, L, M, S for the image.
%    densities   - Vector. 1x4 Vector containing the corrected densities
%                  for [Empty, L, M, S].
%    rSeed       - Struct. Random seed structure, returned for repeatbility
%
% Optional key/value pairs:
%    None.
%

% History:
%    xx/xx/05       Copyright ImagEval Consultants, LLC, 2005.
%    06/14/18  jnm  Formatting

% Examples:
%{
    % K, R, G, B image
    sz = [50 50];
    densities = [0.14 .5 .3 .06];
    [xy, coneType] = humanConeMosaic(sz, densities);
    conePlot(xy, coneType(:))
%}
%{
    % Solid R image
    sz = [50 50];
    densities = [1 0 0 ];
    [xy, coneType, densities] = humanConeMosaic(sz, densities);
    conePlot(xy, coneType(:))
%}
%{
    % K, B image
    sz = [50 50];
    densities = [1 0 0 1];
    [xy, coneType, densities] = humanConeMosaic(sz, densities);
    conePlot(xy, coneType(:))
%}
%{
    % R, G, B image
    sz = [50 50];
    densities = [1 1 1];
    [xy, coneType, densities] = humanConeMosaic(sz, densities);
    conePlot(xy, coneType(:))
%}

if notDefined('sz'), error('Array size must be defined'); end

% densities specifies the [Empty, L, M, S] cone ratios
if notDefined('densities'), densities = [0.1 0.55 0.25 0.1]; end
if notDefined('umConeWidth'), umConeWidth = 2; end

% Always initialize the modern random number generator.  If not, this
% causes an error.
rng('default');
if notDefined('rSeed'), rSeed = rng; else, rng(rSeed); end

nTypes = length(densities);

% densities should be 4D and sum to one. We patch up some cases here
s = sum(densities);
if nTypes == 4, densities = densities / sum(densities);
elseif nTypes == 3
    if s >= 1, densities = [0 densities / sum(densities)];
    else, densities = [1 - s, densities]; end
end

% There are always 4 types at this point
nTypes = 4;
nLocs = prod(sz);
nReceptors = zeros(1, nTypes);

% Figure out how many cones of each type
for ii = 1:nTypes, nReceptors(ii) = round(densities(ii) * nLocs); end

if sum(nReceptors) < nLocs
    % Add an extra one to the biggest pool.
    % This is the smallest percent difference ...
    [~, ii] = max(nReceptors);
    nReceptors(ii) = nReceptors(ii) + nLocs - sum(nReceptors);
end

% Assign nTypes to a regular arrangement and then randomly permute
tmp = zeros(nLocs, 1);
start = 1;
for ii = 1:nTypes
    tmp(start:(start + nReceptors(ii) - 1)) = ii;
    start = start + nReceptors(ii);
end
p = randperm(nLocs);
coneType = tmp(p);
coneType = reshape(coneType, sz(1), sz(2));

% Set up the spatial coordinates of the regular sampling grid
% Units are microns
r = sz(1);
c = sz(2);
x = (1:c) * umConeWidth;
x = x - mean(x);
y = (1:r) * umConeWidth;
y = y - mean(y);
[X, Y] = meshgrid(x, y);
xy = [X(:), Y(:)];

end