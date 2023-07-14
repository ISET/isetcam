function [xy,coneType,densities,rSeed] = humanConeMosaic(sz,densities,umConeWidth,rSeed)
%Create an xy spatial representation of the human cone mosaic
%
%  [xy,coneType,densities,rSeed] = humanConeMosaic(sz,densities,umConeWidth,rSeed)
%
% Inputs
% sz:         The grid size (row,col)
% densities:  The sum of the densities. If sum < 1, some locations will
%   have a 0, meaning the receptor at that location has zero spectralQE
%   However, it does respond with noise in the sensor image.
% umConeWidth: Cone width in microns (pixelGet(pixel,'width','um'))
% rSeed:      Set the random number seed (for repeatability)
%
% Returns
%  xy:  Positions in microns
%  coneType: 1:4, K,L,M,S
%  densities:  Corrected densities
%  rSeed:  Returned for repeatbility
%
% The order of the vector densities should K,L,M,S -> 1,2,3,4, but we patch
% up some cases when only (L,M,S) are sent in.  Not preferred.
%
% See also: sensorCreateConeMosaic
%
% Examples
%   sz        = [50,50];
%   densities = [0.14 .5 .3 .06];
%   [xy, coneType] = humanConeMosaic(sz,densities);
%   figure(1); ieConePlot(xy,coneType(:))
%
%   densities = [1 0 0 ];
%   [xy, coneType, densities] = humanConeMosaic(sz,densities);
%   figure(1); ieConePlot(xy,coneType(:))
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sz'), error('Array size must be defined'); end
if ieNotDefined('densities')
    densities = [0.1 0.55 0.25 0.1];  % Empty, L,M,S cone ratios
end
if ieNotDefined('umConeWidth'), umConeWidth = 2; end
if ieNotDefined('rSeed')
    try  rSeed = rng;
    catch err
        rSeed = randn('seed');
    end
else
    try rng(rSeed)
    catch err
        randn('seed',rSeed);
    end
end

nTypes = length(densities);

% densities should be 4D and sum to one.  We patch up some cases here
s = sum(densities);
if nTypes == 4, densities = densities/sum(densities);
elseif nTypes == 3
    if s >= 1 , densities = [0 densities/sum(densities)];
    else        densities = [1 - s, densities];
    end
end

% There are always 4 types at this point
nTypes = 4;
nLocs = prod(sz);
nReceptors = zeros(1,nTypes);

% Figure out how many cones of each type
for ii=1:nTypes
    nReceptors(ii) = round(densities(ii)*nLocs);
end

if sum(nReceptors) < nLocs
    % Add an extra one to the biggest pool.
    % This is the smallest percent difference ...
    [tmp,ii] = max(nReceptors);
    nReceptors(ii) = nReceptors(ii) + nLocs - sum(nReceptors);
end

% Assign nTypes to a regular arrangement and then randomly permute
tmp = zeros(nLocs,1);
start = 1;
for ii=1:nTypes
    tmp(start:(start + nReceptors(ii)- 1)) = ii;
    start = start + nReceptors(ii);
end
p = randperm(nLocs);
coneType = tmp(p);
coneType = reshape(coneType,sz(1),sz(2));

% Set up the spatial coordinates of the regular sampling grid
% Units are microns
r = sz(1); c = sz(2);
x = (1:c)*umConeWidth; x = x - mean(x);
y = (1:r)*umConeWidth; y = y - mean(y);
[X,Y] = meshgrid(x,y);
xy = [X(:),Y(:)];

return
