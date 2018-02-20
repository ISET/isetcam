function S = ptScatteringMatrix(n,d,thetaIn,lambda,polarization)
%
%   S = ptScatteringMatrix(n,d,thetaIn,lambda,polarization)
%
% AUTHOR: 	Peter Catrysse
% DATE:		June, July, August 2000
%
%       1       2       M-1     M
%       |       |       |       |
%   0   |   1   | ..... |  N-1  |   N 
%       |       |       |       |
%

theta = ptSnellsLaw(n,thetaIn);

% Assume M interfaces between N+1 media
M = length(n)-1; I = cell(1,M);
for ii = 2:(M+1)
    [rho(1,ii,:),tau(1,ii,:)] = ...
        ptReflectionAndTransmission(n(ii-1),n(ii),theta(1,ii-1,:),polarization);
    I{ii-1} = ptInterfaceMatrix(rho(1,ii,:),tau(1,ii,:));
end

% Assume N media and an input medium (d = 0 for input medium)
N = length(d); L = cell(1,N);
for ii = 2:(N+1)
    L{ii-1} = ptPropagationMatrix(n(ii),d(ii-1),theta(1,ii,:),lambda);
end

% Creating the scattering matrix
for ii = 1:length(theta(1,1,:))
    % M interfaces and N-1 media
    S(:,:,ii) = I{1}(:,:,ii)*L{1}(:,:,ii)*I{2}(:,:,ii);
    for jj = 2:(M-1)
        S(:,:,ii) = S(:,:,ii)*L{jj}(:,:,ii)*I{jj+1}(:,:,ii);
    end
    % If d > 0 for N-th medium there is propagation beyond the interface
    if N == M
        S(:,:,ii) = S(:,:,ii)*L{N}(:,:,ii);
    else
        S(:,:,ii) = S(:,:,ii);
    end
end

return
