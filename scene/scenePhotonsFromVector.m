function photons = scenePhotonsFromVector(photons,row,col)
% Convert a vector of photons to a 3D matrix of scene photons
%
% Syntax
%   imgPhotons = scenePhotonsFromVector(vPhotons,row,col)
%
% Input
%
% Optional key/val pairs
%
% Returns
%
% Description
%
% See also
%

%% Just a reminder about how to expand 1D into the right 3D format

photons = repmat(photons(:),1,row,col);
photons = permute(photons,[2 3 1]);

end