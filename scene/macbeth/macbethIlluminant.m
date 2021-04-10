function illPhotons = macbethIlluminant(scene)
% Estimate the spectral radiance of the scene illuminant from the MCC (photons) 
%
% Synopsis
%   illPhotons = macbethIlluminant(scene)
%
% Brief description
%   Uses the MCC to estimate the spectral power distribution of the
%   illuminant.  If the scene has corner points, the process is automated.
%   If not, then it calls macbethSelect to have the user identify the MCC
%   corner points
%
% Inputs
%   scene - Uses the corner points if selected, otherwise forces the user
%           to select the MCC corner points
% Returns
%   illPhotons - Estimated illuminant SPD (photons)
%
% Description
%   The spectral radiance from the 24 patches of the MCC are extracted from
%   the scene.  The corresponding reflectance functions of the patches are
%   read from the ISETCam data.  These are both in XW format (24 x 31).
%
%   Then the illuminant photons are estimated by a simple calculation. The
%   basic equation is 
%
%      spd = reflectance * diag(ill)  % (24 x 31, 24 x 31, 31 x 31)
%
%   We can solve for the diagonals because each column is an independent
%   equation. Suppose we pick out a column vector for the reflectance and
%   the spectral radiance for a particular wavelength.  The illuminant
%   photons estimate is
%
% illPhotons = (1/(reflectance(:)'*reflectance(:)))*(reflectance(:)'*spd(:))
%
% See also:
%   macbethSelect
%

%% Check input
assert(isequal(scene.type,'scene'))

%% Get data
wave = sceneGet(scene,'wave');
mccReflectance = ieReadSpectra('macbethChart',wave);
mccReflectance = mccReflectance';   % XW format

% Spectral radiance from the macbeth patchs
mccSPD = macbethSelect(scene);

%% Compute
nWave = numel(wave);
illPhotons = zeros(nWave,1);
for ii=1:nWave
    x = mccReflectance(:,ii);
    y = mccSPD(:,ii);

    % y = x*ill
    % x'*y = x'*x*ill
    % (x'*x)^-1*x'*y = ill
    % illPhotons(ii) = (1/dot(x,x))*x'*y;
    % Or,
    illPhotons(ii) = pinv(x)*y;
    
end

ieNewGraphWin;
plot(wave,illPhotons);

end
