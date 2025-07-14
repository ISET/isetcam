function poly = nsidedpoly(n, varargin)
    % Octave-compatible replacement for nsidedpoly (regular polygon)
    % poly = nsidedpoly(n, 'Center', [cx, cy], 'Radius', r, 'Rotation', angle)
    
    p = inputParser;
    addParameter(p, 'Center', [0, 0]);
    addParameter(p, 'Radius', 1);
    addParameter(p, 'Rotation', 0);  % in degrees
    parse(p, varargin{:});
    
    center = p.Results.Center;
    radius = p.Results.Radius;
    rot = deg2rad(p.Results.Rotation);
    
    % Generate regular polygon vertices
    theta = (0:n-1)' * (2*pi/n) + rot;
    x = center(1) + radius * cos(theta);
    y = center(2) + radius * sin(theta);
    
    % Output struct similar to MATLAB's nsidedpoly result
    poly.Vertices = [x, y];
end
