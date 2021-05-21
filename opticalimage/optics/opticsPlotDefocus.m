function otf = opticsPlotDefocus(Defocus,sampleSf,wave)
%Plot the OTF as a function of defocus
%
%   otf = opticsPlotDefocus(Defocus,sampleSf,wave)
%
% This function is not currently used.  It plots the 1D OTF (for a
% diffraction-limited system) as a function of defocus. Hence, the output
% graph has spatial frequency on one axis and defocus on the other.  The
% height shows the relative amplitude of the transmitted pattern.
%
% The user specifies the spatial frequency range and wavelength.
%
% Example:
%  Defocus = [-1:.1:1]; sampleSf = [0:64]; wave = 500;
%  figure; opticsPlotDefocus(Defocus,sampleSf,wave);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('sampleSf'), sampleSf = 0:64;	    end    % Spatial frequencies used
if ieNotDefined('Defocus'),   Defocus = [-1:.05:1];	end    % Defocus range
if ieNotDefined('wave'),      wave = 550;	        end    % Measurement wavelength

[val,OI] = vcGetSelectedObject('OPTICALIMAGE');
[val,ISA] = vcGetSelectedObject('ISA');
optics = oiGet(OI,'optics');

c = oiGet(OI,'fov')/sensorGet(ISA,'width');      % degrees per meter for eye
p = opticsGet(optics,'diameter')/2;                 % pupil radius in m
D0 = 1/opticsGet(optics,'focallength');             % dioptric power of unaccomodated eye

for ii=1:length(Defocus)
    w20 = p^2/2*(D0.*Defocus(ii))./(D0+Defocus(ii));
    s = c.*(wave*1e-9).*sampleSf./(D0.*p);
    alpha = 4*pi./(wave*1e-9).*w20.*s;
    otf(ii,:) = opticsDefocusedMTF(s,abs(alpha));
end

OTF = ones(size(otf));
OTF(isfinite(otf)) = otf(isfinite(otf));

% The otf can be complex, mostly due to rounding error I think.
mesh(sampleSf,Defocus,abs(otf));
xlabel('Spatial frequency'); ylabel('Defocus');  zlabel('Transmission')

return;

