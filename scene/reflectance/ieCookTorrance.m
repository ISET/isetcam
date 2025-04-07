function fr = ieCookTorrance(surfaceNormal, viewDirection, lightDirection, baseReflectance, roughness)
% ieCookTorrance Compute Cook-Torrance reflectance value
%
% Synopsis
%
% Inputs
%
%   N: surface normal (3x1)
%   V: view direction (3x1)
%   L: light direction (3x1)
%   F0: base reflectivity at normal incidence (scalar or 3x1 RGB)
%   roughness: surface roughness (0 to 1)
%
% Optional key/val
%
% Output
%  fr - Reflectance value
%
%

% Example:
%{
N = [0; 0; 1];
V = [0; 0; 1];           % Camera looking straight on
L = normalize([0.3; 0.3; 1]); % Light from above/side
F0 = 0.04;              % Dielectric material like plastic
roughness = 0.5;
brdf_val = ieCookTorrance(N, V, L, F0, roughness);
disp(['BRDF value: ', num2str(brdf_val)]);
%}
%{
N = [0; 0; 1];
V = [0; 0; 1];           % Camera looking straight on
L = normalize([0.3; 0.3; 1]); % Light from above/side
F0 = 0.04;              % Dielectric material like plastic
roughness = .3;
nTheta = 200;
nPhi = 200;
theta = linspace(0, pi/2, nTheta);
phi = linspace(0, 2*pi, nPhi);

% Plot in polar coordinates
% Wrap phi and brdf_vals
phi_wrapped = [phi, 2*pi];  % add a column at 2pi
theta_wrapped = theta;
nPhi = 201;

[PHI, THETA] = meshgrid(phi_wrapped, theta_wrapped);
% [PHI, THETA] = meshgrid(phi, theta);

x = sin(THETA) .* cos(PHI);
y = sin(THETA) .* sin(PHI);
z = cos(THETA);
V = cat(3, x, y, z);  % View directions

% Compute BRDF for each viewing direction
brdf_vals = zeros(size(THETA));
for i = 1:nTheta
    for j = 1:nPhi
        Vdir = squeeze(V(i, j, :));
        brdf_vals(i, j) = ieCookTorrance(N, Vdir, L, F0, roughness);
    end
end

brdf_vals_wrapped = [brdf_vals, brdf_vals(:,1)];  % wrap data at phi=0

% Convert to Cartesian
figure;
[X, Y] = pol2cart(PHI, THETA);  % convert to x, y

% Plot as image in polar coordinates
% mesh(X,Y,brdf_vals); set(gca,'zscale','log')

p = pcolor(X, Y, brdf_vals);  % transpose for orientation
shading interp;
axis equal tight;
colormap(parula);  % or use 'plasma' if you have it
colorbar;

title('Cook-Torrance BRDF over Viewing Hemisphere');
%}

% Normalize vectors
surfaceNormal = surfaceNormal / norm(surfaceNormal);
viewDirection = viewDirection / norm(viewDirection);
lightDirection = lightDirection / norm(lightDirection);
H = (viewDirection + lightDirection) / norm(viewDirection + lightDirection);  % Half-vector

NdotV = max(dot(surfaceNormal, viewDirection), 1e-5);
NdotL = max(dot(surfaceNormal, lightDirection), 1e-5);
NdotH = max(dot(surfaceNormal, H), 1e-5);
VdotH = max(dot(viewDirection, H), 1e-5);

% GGX / Trowbridge-Reitz normal distribution function
alpha = roughness^2;
denom = (NdotH^2 * (alpha^2 - 1) + 1)^2;
D = alpha^2 / (pi * denom);

% Schlick Fresnel approximation
F = baseReflectance + (1 - baseReflectance) * (1 - VdotH)^5;

% Smith geometry term (using GGX approximation)
G1 = @(w) 2 * dot(surfaceNormal, w) ./ (dot(surfaceNormal, w) + sqrt(alpha^2 + (1 - alpha^2) * dot(surfaceNormal, w)^2));
G = G1(viewDirection) .* G1(lightDirection);

% Cook-Torrance BRDF
fr = (D .* F .* G) ./ (4 * NdotL * NdotV);
end
