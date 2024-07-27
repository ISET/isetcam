% Given wavelengths and image heights
ieInit;
%% Load data
load('zernike_doubleGauss.mat','data');
wavelengths = data.wavelengths;
image_heights = data.image_heights;
zCoeffs = data.zernikeCoefficients;
%% Utilities
 
function nearest_two = find_nearest_two(array, number)
    % Calculate the absolute differences between each element in the array and the given number
    differences = abs(array - number);
    
    % Find the indices of the two smallest differences
    [~, sorted_indices] = sort(differences);
    
    % Get the nearest two numbers using the indices
    nearest_two = array(sorted_indices(1:2));
end

function mask = createCircleMask(radius, imgSize)
    % Create a binary mask of a circle
    % radius - the radius of the circle
    % imgSize - size of the image [rows, cols]

    % Ensure imgSize is a two-element vector
    assert(length(imgSize) == 2, 'imgSize must be a two-element vector [rows, cols]');
    
    % Create a grid of coordinates
    [X, Y] = meshgrid(1:imgSize(2), 1:imgSize(1));
    
    % Calculate the center of the image
    centerX = imgSize(2) / 2;
    centerY = imgSize(1) / 2;
    
    % Calculate the distance of each point from the center
    distFromCenter = sqrt((X - centerX).^2 + (Y - centerY).^2);
    
    % Create the binary mask
    mask = distFromCenter <= radius;
end
%
% Function to generate the PSF
function [psf,wavefront] = generate_psf(zernike_coeffs, zernike_type)
    % Define the PSF grid
    gridSize = 512;
    [x, y] = meshgrid(linspace(-1, 1, gridSize));
    rho = sqrt(x.^2 + y.^2);
    theta = atan2(y, x);
    
    % Initialize the PSF
    psf = zeros(gridSize, gridSize);
    
    % Select Zernike polynomial terms based on the specified type
    switch zernike_type
        case 'fringe'
            % https://wp.optics.arizona.edu/visualopticslab/wp-content/uploads/sites/52/2021/10/Zernike-Fit.pdf
            zernike_terms = {@(rho, theta) 1, ...
                             @(rho, theta) rho.*cos(theta), ...
                             @(rho, theta) rho.*sin(theta), ...
                             @(rho, theta) -1 + 2*rho.^2, ...
                             @(rho, theta) rho.^2.*cos(2*theta), ...
                             @(rho, theta) rho.^2.*sin(2*theta), ...
                             @(rho, theta) (-2*rho + 3*rho.^3).*cos(theta), ...
                             @(rho, theta) (-2*rho + 3*rho.^3).*sin(theta), ...
                             @(rho, theta) 1 - 6*rho.^2 + 6*rho.^4, ...
                             @(rho, theta) rho.^3.*cos(3*theta), ...
                             @(rho, theta) rho.^3.*sin(3*theta), ...
                             @(rho, theta) (-3*rho.^2 + 4*rho.^4).*cos(2*theta), ...
                             @(rho, theta) (-3*rho.^2 + 4*rho.^4).*sin(2*theta), ...
                             @(rho, theta) (3*rho - 12*rho.^3 + 10*rho.^5).*cos(theta), ...
                             @(rho, theta) (3*rho - 12*rho.^3 + 10*rho.^5).*sin(theta)};
                case 'standard' % this is wrong
                zernike_terms = {@(rho, theta) 1, ...
                                 @(rho, theta) rho.*cos(theta), ...
                                 @(rho, theta) rho.*sin(theta), ...
                                 @(rho, theta) 2*rho.^2 - 1, ...
                                 @(rho, theta) rho.^2.*cos(2*theta), ...
                                 @(rho, theta) rho.^2.*sin(2*theta), ...
                                 @(rho, theta) (3*rho.^3 - 2*rho).*cos(theta), ...
                                 @(rho, theta) (3*rho.^3 - 2*rho).*sin(theta), ...
                                 @(rho, theta) rho.^3.*cos(3*theta), ...
                                 @(rho, theta) rho.^3.*sin(3*theta), ...
                                 @(rho, theta) (6*rho.^4 - 6*rho.^2 + 1), ...
                                 @(rho, theta) (4*rho.^4 - 3*rho.^2).*cos(2*theta), ...
                                 @(rho, theta) (4*rho.^4 - 3*rho.^2).*sin(2*theta), ...
                                 @(rho, theta) rho.^4.*cos(4*theta), ...
                                 @(rho, theta) rho.^4.*sin(4*theta)};
        otherwise
            error('Invalid Zernike type. Choose either ''fringe'' or ''standard''.');
    end
                 
    % Calculate the wavefront
    wavefront = zeros(size(rho));
    for i = 1:length(zernike_coeffs)
        wavefront = wavefront + zernike_coeffs(i) * zernike_terms{i}(rho, theta);
    end

    imgSize = [gridSize, gridSize]; % Size of the image [rows, cols]
    apertureMask = createCircleMask(round(gridSize/2), imgSize);
    pupilfuncphase = exp(-1i * 2 * pi * wavefront);
    amp = fftshift(fft2(ifftshift(pupilfuncphase .* apertureMask)));

    % We convert to intensity because the PSF is an intensity (real)
    % valued function. That is how Fourier optics works.
    inten = (amp .* conj(amp));

    % Given the way we computed intensity, should not need to take the
    % real part, but this way we avoid any very small imaginary bits
    % that arise because of numerical roundoff.
    psf = real(inten);    

end

%% 
% image heights used for interpolation.
image_heights_indices = 1:4:21;

thisWave_index = 3; 
wavelength = wavelengths(thisWave_index);

image_heights_test = image_heights(image_heights_indices);
nn=1;
zernike_coeffs_list = cell(1,numel(image_heights_indices));
for j = image_heights_indices
    image_height = image_heights(j);
    coeff_key = sprintf('wave_%d_field_%d', thisWave_index, j);
    if isfield(zCoeffs, coeff_key)
        zernike_coeffs_list{nn} = zCoeffs.(coeff_key);nn=nn+1;
    end
end

%
test_index = 6; % image height
nearest_two = find_nearest_two(image_heights_indices, test_index);

zernike_GT = zCoeffs.(sprintf('wave_%d_field_%d', thisWave_index, test_index));
% Interpolation function for fields
interp_func = @(x) interp1(image_heights_test, [zernike_coeffs_list{:}]', x, 'linear');

% New field 2 values from interpolation
zernike_interpolated = interp_func(image_heights(test_index));

% Validate the interpolation by comparing with the actual field 2 values
validation = zernike_interpolated - zernike_GT;

% Plotting the results for visual validation
figure;

plot(zernike_GT, 'DisplayName', 'Ground Truth');
hold on;
plot(zernike_interpolated, '--', 'DisplayName', 'Interpolation using Zernike');
title(sprintf('Actual vs Interpolated at %02f nm and %02f degrees',wavelength,image_heights(test_index)));
legend;
hold off;

[psf_interpolated,~] = generate_psf(zernike_interpolated, 'fringe');

[psf_GT,~] = generate_psf(zernike_GT, 'fringe');

figure('Position', [200, 300, 1500, 400]);

subplot(1, 3, 1);
imagesc(psf_interpolated);title('Interpolated');
xlim([156,356]);ylim([156,356]);

subplot(1, 3, 2);
imagesc(psf_GT);title('Actual');

xlim([156,356]);ylim([156,356]);

% subplot(3, 1, 3);
% imagesc(psf_interpolated - psf_GT);title('Difference');
% xlim([156,356]);ylim([156,356]);

subplot(1, 3, 3);
% Interpolate in space
[psf_1,~] = generate_psf(zCoeffs.(sprintf('wave_%d_field_%d', thisWave_index, nearest_two(1))), 'fringe');
[psf_2,~] = generate_psf(zCoeffs.(sprintf('wave_%d_field_%d', thisWave_index, nearest_two(2))), 'fringe');



psf_interpSpace = psf_1*(image_heights(test_index)-image_heights(nearest_two(1)))/(nearest_two(2)-nearest_two(1))+...
    psf_2*(nearest_two(2)-image_heights(test_index))/(nearest_two(2)-nearest_two(1));

imagesc(psf_interpSpace);title('Interpolation in Space');

xlim([156,356]);ylim([156,356]);


%%
%{
% Loop through wavelengths and image heights
index = 1;

figure('Position', [200, 300, 2000, 1000]);
for i = 5%:length(wavelengths)
    wavelength = wavelengths(i);
    for j = 1:21%:length(image_heights)
        image_height = image_heights(j);
        coeff_key = sprintf('wave_%d_field_%d', i, j);
        
        if isfield(zCoeffs, coeff_key)
            zernike_coeffs = zCoeffs.(coeff_key);
            [psf,wavefront] = generate_psf(zernike_coeffs, 'fringe');
            
            % Display the PSF
            % figure('Position', [200, 300, 1800, 600]);
            % subplot(1, 2, 1);
            % mesh(psf); 
            subplot(3,7,index);
            imagesc(psf);
            % imagesc(wavefront);
            wavefront_list{j} = wavefront;
            axis image;
            % colormap hot;
            colorbar;
            % clim([-50 30]);
            title(sprintf('PSF at %.2f nm, Image Height: %.2f', wavelength, image_height));
            index=index+1;
            xlim([156,356]);ylim([156,356]);
        end
    end
end
%}