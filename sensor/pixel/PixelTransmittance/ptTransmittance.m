function tunnel = ptTransmittance(n,d,lambda,theta)
%
%   function tunnel = ptTransmittance(n,d,lambda,theta)
%
% This file calculates the optical transmission of a pixel
% with buried photodetector.
%
% AUTHOR: 	Peter Catrysse
% DATE:		June,July, August 2000

% n = [1 2 1.5 3.5];
% d = [0.7 8.3];
%
%  theta = [0 1/4 1/3]*pi;
%  lambda enters in nanometers.  We convert it to meters here.

lambda = lambda*10^-9;

for kk = 1:length(lambda)
    
    S_s = ptScatteringMatrix(n,d,theta,lambda(kk),'s');
    S_p = ptScatteringMatrix(n,d,theta,lambda(kk),'p');
    T(1,kk,:) = (abs(1./S_s(1,1,:)).^2+abs(1./S_p(1,1,:)).^2)/2.*...
        ptPoyntingFactor(n,theta);
    
end

% Average transmission (averaged over wavelength)
wavelengthAverageT = squeeze(mean(T,2))
% Average transmission (averaged over incidence angle)
angleAverageT = squeeze(mean(T,3))

tunnel.transmission.average = wavelengthAverageT;
figure; plot(theta,tunnel.transmission.average); grid

tunnel.transmission.spectral = angleAverageT;
figure; plot(lambda,tunnel.transmission.spectral); grid

return;
