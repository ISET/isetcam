function hdl = ieDrawCylinder(v, varargin)
% Draw a cylinder with a main axis in the v-direction
%
% Inputs
%   v: Direction vector of the cylinder's main axis
%
% Key/val pairs (pixels)
%   radius:     Radius of the cylinder
%   height:     Height of the cylinder
%   resolution: Number of sides for the cylinder (e.g., 20 for a smooth appearance)
%
% Outputs
%   hdl - Figure handle
%
% This should become part of ieDrawShape
%
% See also
%  ieDrawShape

% Example
%{
direction = [1, 0.5, 1]; % The desired direction vector
radius = 5;
height = 20;
resolution = 20;
hdl = ieDrawCylinder(direction/norm(direction));
line([0,direction(1)]*height,[0,direction(2)]*height,[0,direction(3)]*height);
%}

%% Parse
p = inputParser;
p.addRequired('v',@isvector);
p.addParameter('radius',5,@isnumeric);
p.addParameter('height',20,@isnumeric)
p.addParameter('resolution',20,@isnumeric)

p.parse(v,varargin{:});

radius = p.Results.radius;
height = p.Results.height;
resolution = p.Results.resolution;

%% Initialize with a cylinder along the z-axis

% Generate points for the base and top circles of the cylinder.  This
% cylinder is aligned with the z-axis.  The angular samples
theta = linspace(0, 2*pi, resolution);
% The circular base in the x,y plane
x_base = radius * cos(theta);
y_base = radius * sin(theta);
x_top = x_base;
y_top = y_base;
z_base = zeros(size(x_base));
z_top = ones(size(x_top)) * height;

% Compute the rotation matrix to align the z-axis cylinder with the
% direction vector v 
% [~, axis, angle] = vrrotvec([0, 0, 1], v);
%
% We aren't doing that.  So we have the wrong rotation matrix at this
% time.  With this calculation, the direction vector is perpendicular
% to the z-axis.  I checked that by not rotating at all, and the
% cylinder runs up and down the z-axis.  So the vrrotvec call above
% makes sense.  I tried to implement it a different way below.
%
R = rotateVector([0,0,1],v);
%
% R = rotationMatrix3d(v)';
% R = eye(3);

% Rotate the base and top circles
base_points = R * [x_base; y_base; z_base];
top_points  = R * [x_top; y_top; z_top];

% Create the side surface of the cylinder
x_side = [base_points(1, :); top_points(1, :)];
y_side = [base_points(2, :); top_points(2, :)];
z_side = [base_points(3, :); top_points(3, :)];

% Plot the cylinder
hdl = ieNewGraphWin;
surf(x_side, y_side, z_side, 'FaceColor', 'b', 'EdgeColor', 'none');
axis equal; rotate3d; view(3);

end

%%
function R = rotateVector(a, b)
% Examples:
%{
a = [0 0 1]; b = [1 1 1];
R = rotateVector(a,b);
bPrime = R*b;
%}

if isequal(a,b)
    R = eye(3);
    return;
end

% Check if vectors are unit length
if norm(a) ~= 1 || norm(b) ~= 1
    a = a/norm(a);
    b = b/norm(b);
end

% ChatGPT code worked.  (Bard did not).

% Calculate the rotation axis using the cross product
tmp = cross(a, b);
tmp = tmp / norm(tmp);

% Calculate the rotation angle between vectors a and b
angle = acos(dot(a, b));

% Create the rotation matrix using the axis-angle representation
K = [0, -tmp(3), tmp(2); tmp(3), 0, -tmp(1); -tmp(2), tmp(1), 0];
R = eye(3) + sin(angle) * K + (1 - cos(angle)) * (K * K);

end

