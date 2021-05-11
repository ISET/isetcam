function factorPoynting = ptPoyntingFactor(n, thetaIn)
%
%  factorPoynting = ptPoyntingFactor(n,thetaIn)
%
% Author:  PC
% 10-07-2002
%

theta = ptSnellsLaw(n, thetaIn);

% See Klein and Furtak p.80 for real(nOut)
% See Klein and Furtak p.98 for thetaT and nT

if isreal(n(length(n)))

    factorPoynting = (n(length(n)) .* cos(theta(1, length(n), :))) ./ ...
        (n(1) .* cos(theta(1, 1, :)));
    %disp('Using the Poyting factor for real n')

else

    eta = abs(n(length(n)).*cos(theta(1, length(n), :)));
    beta = angle(n(length(n)).*cos(theta(1, length(n), :)));
    nT = sqrt(n(1)^2.*sin(theta(1, 1, :)).^2+eta.^2.*cos(beta).^2);
    cos_thetaT = sqrt(1-(n(1) * sin(theta(1, 1, :)) ./ nT).^2);

    factorPoynting = (real(n(length(n))) .* real(cos(theta(1, length(n), :)))) ./ ...
        (n(1) .* cos(theta(1, 1, :)));

    %factorPoynting = (real(n(length(n))).*cos_thetaT)./ ...
    %    (n(1).*cos(theta(1,1,:)));
    %disp('Using the Poyting factor for complex n')

end

return;
