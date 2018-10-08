function cones = EnergyToCones(wl,energy,S_cones,T_cones)
% cones = EnergyToCones(wl,energy,S_cones,T_cones)
%
% Convert energy of a monochromatic light to cone excitations.
%
% 8/16/96  dhb, abp  Wrote it.

% Force wavelength specification to wavelength format.
wls_cones = MakeItWls(S_cones);

% Convert
n_cones = size(T_cones,1);
index = find(wl == wls_cones);
if (isempty(index))
	error('Passed wavelength not subset of cone wavelengths');
end
cones = T_cones(:,index)*energy;


