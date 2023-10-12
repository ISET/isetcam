function dof = opticsDoF(optics,oDist,cocDiam)
% Depth of field for a thin lens
%
% The depth of field formula from Wikipedia is
%
%    DOF = (2 f/# C U^2)/ FocalLength^2
%
% Here is the wikipedia article:  https://en.wikipedia.org/wiki/Depth_of_field
%
% The lengths are in meters
%
% The calculation is based on finding two points on either side of the in
% focus distance that have an equal circle of confusion.  See opticsCoC and
% s_opticsCoC.
% 
% We are checking that this DOF formula matches the calculation in
% opticsCOC. That will be tested in the scripts s_opticsDoF and s_opticsCoC
%
% See also
%  opticsCoC, s_opticsDoF, s_opticsCoc

% Examples:
%{
optics = opticsCreate;
optics = opticsSet(optics,'fnumber',2);
optics = opticsSet(optics,'focal length',0.070);  % meters
oDist = [0.5 1 2 4];
dof = zeros(size(oDist));
for ii=1:numel(oDist)
 dof(ii) = opticsDoF(optics,oDist(ii),20e-6);
end
ieNewGraphWin; plot(oDist,dof); grid on;
xlabel('Object distance'); ylabel('DOF (m)');
%}
%{
% Again, a 70 mm focal length lens and a range of common fnumbers.
% The object at 3 meters.  If pixels are 2 um, and we have a 2x2 Bayer
% pattern element, so 4 um.  We make a CoC criterion of 5 (pretty blurry)

optics = opticsCreate;
optics = opticsSet(optics,'focal length',0.070);  % meters
fnumber = [2, 4, 8, 16];
dof = zeros(size(fnumber));
oDist = 3;
for ii=1:numel(fnumber)
 optics = opticsSet(optics,'fnumber',fnumber(ii));
 dof(ii) = opticsDoF(optics, oDist, 20e-6);
end

ieNewGraphWin; plot(fnumber,dof); grid on;
xlabel('F/#'); ylabel('DOF (m)');
title(sprintf('Object at %.1f m',oDist));
%}

% Here is the formula from Wikipedia
if ieNotDefined('optics'), error('Optics must be defined'); end
if ieNotDefined('oDist'), error('Object distance in meters required.'); end  % Two microns by default.
if ieNotDefined('cocDiam'), cocDiam = 10e-6; end  % Ten microns by default.

% 01a Image Formation slides.
fN = opticsGet(optics,'fnumber');
fL = opticsGet(optics,'focal length','m');
dof = 2 * fN * cocDiam * oDist^2 / fL^2;

end


