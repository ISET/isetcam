function [rho,tau] = ptReflectionAndTransmission(nIn,nOut,thetaIn,polarization)
%
%   [rho,tau] = ptReflectionAndTransmission(nIn,nOut,thetaIn,polarization)
%
% AUTHOR: 	Peter Catrysse
% DATE:		June,July, August 2000
% Added:    Dealing with complex nOut (10/02/2002)


%
thetaOut = asin(nIn*sin(thetaIn)./nOut);

switch lower(polarization)  
    case('s') % perpendicular
        
        rho = (nIn * cos(thetaIn) - nOut * cos(thetaOut))./...
            (nIn * cos(thetaIn) + nOut * cos(thetaOut));
        tau = (2 * nIn * cos(thetaIn))./...
            (nIn * cos(thetaIn) + nOut * cos(thetaOut));
        
    case('p') % parallel
        
        rho = (nOut * cos(thetaIn) - nIn * cos(thetaOut))./...
            (nOut * cos(thetaIn) + nIn * cos(thetaOut));
        tau = (2 * nIn * cos(thetaIn))./...
            (nOut * cos(thetaIn) + nIn * cos(thetaOut));
        
end

return
