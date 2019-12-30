function hdl = plotRadiance(wavelength,radiance)
% Utility to plot and label radiance data
%
% Syntax
%   hdl = plotRadiance(wavelength,radiance)
%
% Inputs
%    wavelength  - Wavelength samples (nm)
%    radiance    - Columns of radiances
%
% Optional key/value pairs
%    None
%
% Returns;
%   hdl
%
% See also
%   ieNewGraphWin, plotX
%

% More options to come.  Such as a title.
% 

hdl = ieNewGraphWin;
wavelength = wavelength(:);

nWave = length(wavelength);
if nWave == size(radiance,1)
    plot(wavelength(:),radiance);
elseif length(wavelength) == size(radiance,2)
    plot(wavelength(:),radiance');    
end

xlabel('Wavelength (nm)');
ylabel('Radiance (watts/sr/nm/m^2)');
grid on; 
title('Spectral radiance');

end
