function [x,y,z] = iePlaneFromVectors(A,varargin)
% Return points on a plane from the two column vectors of A
%
% Synopsis
%   [x,y,z] = iePlaneFromVectors(A,[xylimits],[npoints])
%
% Inputs
%   A - Matrix 3x2
%
% Return
%   x,y,z - Points on the plane
%
% See also
%

%% Need to set up params checking and allow the x,y range to differ
p = inputParser;
p.addRequired('A',@(x)(ismatrix(x) && size(x,1)==3 && size(x,2) == 2));
p.addParameter('xylimits',[-1 1],@(x)(isvector(x) && numel(x)==2));
p.addParameter('npoints',10,@isnumeric);

p.parse(A,varargin{:});
xylimits = p.Results.xylimits;
npoints = p.Results.npoints;

%%
point1 = A(:,1); % [A(1,1), A(2,1), A(3,1)];
point2 = A(:,2); % [A(1,2), A(2,2), A(3,2)];

% Calculate the normal vector
normal_vector = cross(point1, point2);

% Extract the components of the normal vector
a = normal_vector(1);
b = normal_vector(2);
c = normal_vector(3);

% Create the equation of the plane
% syms x y z;  % Define symbolic variables
% plane_equation = A*x + B*y + C*z;

[x, y] = meshgrid(linspace(xylimits(1), xylimits(2), 10), linspace(xylimits(1), xylimits(2), npoints));

z = -1*(a*x + b*y)/c;

end
