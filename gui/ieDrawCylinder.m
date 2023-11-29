function hdl = ieDrawCylinder(v, varargin)
% Draw a cylinder
%
% Inputs
%   v: Direction vector of main axis
%
% Key/val pairs
%   radius:     Radius of the cylinder
%   height:     Height of the cylinder
%   resolution: Number of sides for the cylinder (e.g., 20 for a smooth appearance)
%
% Outputs
%   hdl - Figure handle
%
% Status:  It draws a cylinder with some height and radius.  But the
% direction is not as expected.
%
% This should become part of ieDrawShape
%
% See also
%

% Example
%{
direction = [1, 0, 0]; % Replace with your desired direction vector
radius = 5.1;
height = 20;
resolution = 20;
hdl = ieDrawCylinder(direction);
line([0,10*direction(1)],[0,10*direction(2)],[0,10*direction(3)]);
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

%%

% Generate points for the base and top circles of the cylinder
theta = linspace(0, 2*pi, resolution);
x_base = radius * cos(theta);
y_base = radius * sin(theta);
x_top = x_base;
y_top = y_base;
z_base = zeros(size(x_base));
z_top = ones(size(x_top)) * height;

% Compute the rotation matrix to align the cylinder with the direction vector v
% [~, axis, angle] = vrrotvec([0, 0, 1], v);
% This is the wrong rotation matrix at this time.  The directions seem
% perpendicular.
R = rotationMatrix3d(v)';

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
