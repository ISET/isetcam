function [radiance, radianceS] =...
	LumToRadiance(relativeSpectrum, relativeSpectrumS, luminance, photopic)
% [radiance, radianceS] =...
%  	LumToRadiance(relativeSpectrum, relativeSpectrumS, luminance, [photopic])
%
% Convert luminance in photopic cd/m2 to radiance, given relative spectrum
% of the source.
%
% Variable photopic can take on values:
%		'Photopic' (Default)
%   'JuddVos'
%   'Scotopic'
%
% 7/29/03   dhb  Wrote it.

% Default
if (nargin < 4 || isempty(photopic))
	photopic = 'Photopic';
end
S = [380 1 401];

% Load appropriate V_lambda for phot/scot
switch (photopic)
	case 'Photopic'
		load T_xyz1931;
		T_vLambda = SplineCmf(S_xyz1931,T_xyz1931(2,:),S);
		clear T_xyz1931 S_xyz1931
		magicFactor = 683;
	case 'JuddVos'
		load T_xyzJuddVos;
		T_vLambda = SplineCmf(S_JuddVos,T_JuddVos(2,:),S);
		clear T_JuddVos S_JuddVos
		magicFactor = 683;
	case 'Scotopic'
		load T_rods;
		T_vLambda = SplineCmf(S_rods,T_rods,S);
		magicFactor = 1700;
end
 
% Spline to common wavelength representation for computations
relativeSpectrum = SplineSpd(relativeSpectrumS,relativeSpectrum,S);

% Solve for putting our spectrum into watts/m2-sr-wlinterval.
scaleFactor = luminance / ( magicFactor*T_vLambda*relativeSpectrum );

% Set returned wavelength sampling to match input.
radiance = SplineSpd(S,scaleFactor*relativeSpectrum,relativeSpectrumS);
radianceS = relativeSpectrumS;



