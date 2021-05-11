function energy = sceneEnergyFromVector(energy, row, col)
% Convert a vector of Energy to a 3D matrix of scene photons
%
% Syntax
%   imgEnergy = sceneEnergyFromVector(vPhotons,row,col)
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

energy = repmat(energy(:), 1, row, col);
energy = permute(energy, [2, 3, 1]);

end