function thetaOut = ptSnellsLaw(n,thetaIn)
%
% AUTHOR: 	Peter Catrysse
% DATE:		June, July, August 2000
%
%   Calculates the angle out of the optics given refractive index and angle
%   in, at a planar interface.  Snell's Law.

%n = [1];
%thetaIn = [0]*pi;

thetaOut(1,1,:) = thetaIn;
for ii = 2:length(n)
    thetaOut(1,ii,:) = asin(n(ii-1) * sin(thetaOut(1,ii-1,:) )/n(ii) );
end

reducedTheta = n(1) * sin(thetaIn);
for ii = 1:length(n)
    thetaOut(1,ii,:) = asin(reducedTheta/n(ii));
end

reducedTheta = n(1) * sin(thetaIn);
[reducedThetaGrid,nGrid] = meshgrid(reducedTheta,n);
thetaOut(1,:,:) = asin(reducedThetaGrid./nGrid);

return;
