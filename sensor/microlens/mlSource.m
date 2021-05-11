function W = mlSource(x1, x2, u1, u2, X, U)
% Creates a Wigner PS diagram for an optical source
%
%    W = mlSource(x1,x2,u1,u2,X,U)
%
% Assigns a 1 to everything inside the box [x1,u2], [x2,u2] where x and u
% are the position and angles.  This creates a phase space representation
% of every position in (x,angle) over which the source extends.
%
% x1,x2,u1,u2 are the bounds in phase space.
% X:
% U:
%
% Returns
%  W:  Phase space (x,angle) representation of the source
%  X:  Unchanged
%  U:  Unchanged
%
% Copyright ImagEval Consultants, LLC, 2005.

nPoints1 = size(X, 1);
nPoints2 = size(X, 2);
x = X(1, :); % Positions of source rays
dx = mean(diff(x)) / 2; % Sample spacing in x
u = U(:, 1); % Angles of source rays
du = mean(diff(u)) / 2; % Sample spacing in u
W = zeros(nPoints1, nPoints2);

if (x1 == x2) & (u1 == u2)
    W(find(abs(u - u1) < du), find(abs(x - x1) < dx)) = 1;
elseif (u1 == u2)
    W(find(abs(u - u1) < du), find((x > x1) & (x < x2))) = 1;
elseif (x1 == x2)
    W(find((u > u1) & (u < u2)), find(abs(x - x1) < dx)) = 1;
else
    W(find((u > u1) & (u < u2)), find((x > x1) & (x < x2))) = 1;
end

return