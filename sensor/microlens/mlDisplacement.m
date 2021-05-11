function [WOut, X, U] = mlDisplacement(d, WIn, X, U, propagationType)
% Tranforms the Wigner PS diagram by a lateral displacement d
%
%    [WOut,X,U] = mlDisplacement(d,WIn,X,U,propagationType)
%
% Copyright ImagEval Consultants, LLC, 2005.

%% Looks like type is no longer needed here
% switch lower(type)
%     case('angle')
%         k = 1;
%     case('frequency')
%         k = 2*pi/lambda;
% end

%%
x = X(1, :);
u = U(:, 1);

switch lower(propagationType)
    case ('paraxial') % ABCD (paraxial)
        % WOut = griddata(X,U,WIn,X+d,U);
        z = [X(:) + d, U(:)];
        f = WIn(:);
        WOut = ffndgrid(z, f, -length(x), [min(x), max(x), min(u), max(u)], 1);
    case ('non-paraxial') % non-ABCD (non-paraxial)
        % WOut = griddata(X,U,WIn,X+d,U);
        z = [X(:) + d, U(:)];
        f = WIn(:);
        WOut = ffndgrid(z, f, -length(x), [min(x), max(x), min(u), max(u)], 1);
end

% Convert from sparse to full matrix (This could be done later if we need
% save more space and time)
WOut = full(WOut);
% NaNs set to 0
WOut(isnan(WOut)) = 0;

return;