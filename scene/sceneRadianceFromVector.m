function radiance = sceneRadianceFromVector(radiance,row,col)
% Convert a vector of radiance to a 3D matrix of scene radiance
%
% Syntax
%   radiance = sceneRadianceFromVector(vRadiance,row,col)
%
% Input
%  radiance:   A vector defining the scene radiance that will be copied
%  row:        Scene row size
%  col         Scene col size
%
% Optional key/val pairs
%   N/A
%
% Returns
%   radiance:  A 3D matrix of the correct size
%
% Description
%
% See also
%  sceneSet(scene,'photons',data)
%  sceneSet(scene,'energy',data)

%% Just a reminder about how to expand 1D into the right 3D format

radiance = repmat(radiance(:),1,row,col);
radiance = permute(radiance,[2 3 1]);

end