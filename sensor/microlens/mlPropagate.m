function [WOut,X,U] = mlPropagate(d,n,lambda,WIn,X,U,propagationType,type)
%Tranforms the Wigner PS diagram due to free-space propagation
%
%   [WOut,X,U] = mlPropagate(d,n,lambda,WIn,X,U,propagationType,type)
%
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Which type of calculation?
switch lower(type)
    case('angle')
        k = 1;
    case('frequency')
        k = 2*pi/lambda;
end

x = X(1,:); u = U(:,1);

%% Propagation corrected for the index of refraction in the propagation
% medium (both paraxial and non-paraxial)
switch lower(propagationType)
    case('paraxial')    % ABCD (paraxial)
        % WOut = griddata(X,U,WIn,X-d/(n*k)*U,U);
        z = [X(:)-d/(n*k)*U(:), U(:)]; f = WIn(:); 
        WOut = ffndgrid(z,f,-length(x),[min(x) max(x) min(u) max(u)],1);
    case('non-paraxial') % non-ABCD (non-paraxial)
        % WOut = griddata(X,U,WIn,X-d*tan(asin(U/(n*k))),U);
        z = [X(:) - d*tan(asin(U(:)/(n*k))), U(:)]; f = WIn(:); 
        WOut = ffndgrid(z,f,-length(x),[min(x) max(x) min(u) max(u)],1);
end

% Convert from sparse to full matrix (This could be done later if we need
% save more space and time
WOut = full(WOut);
% NaNs set to 0
WOut(isnan(WOut)) = 0;

return;