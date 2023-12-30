%% Calculate PSF/OTF using wvf that matches the OI
% Interpolation in isetcam matches the resolution (um/sample) of the default 
% PSF/OTF with the OI resolution. However, this process introduces minor 
% artifacts in the PSF, such as horizontal and vertical spiky lines, 
% with intensity levels 1e4 to 1e5 times lower than the PSF's peak. 
% While generally not problematic, these artifacts could be noticeable in 
% HDR scenes, particularly in night settings.
%
% A potential solution is to generate a high-resolution OTF in real-time, 
% but this approach is computationally intensive for large scenes. 
% As a temporary workaround, we precalculate the OTF at the OI's resolution 
% and configure the OI accordingly. 
% This method allows oiCompute to bypass the interpolation step.


% Zhenyi, 2023

%%
ieInit;
clear all; close all
%%
s_size = 512;
flengthM = 4e-3;
fnumber = 4;


pupilMM = (flengthM*1e3)/fnumber;

scene = sceneCreate('point array',s_size,s_size/4);
scene = sceneSet(scene,'fov',20);
d = create_shapes(s_size);
wave = 400:10:700;
illPhotons = Energy2Quanta(wave,ones(31,1))*1e3;

data = bsxfun(@times, d, reshape(illPhotons, [1 1 31]));

scene = sceneSet(scene,'illuminantPhotons',illPhotons);

% Allocate space for the (compressed) photons
scene = sceneSet(scene,'photons',data);

scene = sceneAdjustLuminance(scene,'peak',100000);

oi = oiCreate('diffraction limited');

oi = oiSet(oi,'optics focallength',flengthM);

for fnumber = 2
    oi = oiSet(oi,'optics fnumber',fnumber);

    % oi needs information from scene to figure out the proper resolution.
    oi = oiCompute(oi, scene);
    oiWindow(oi);

    oi = oiSet(oi, 'name','icam');
    oi = oiSet(oi,'displaymode','hdr');
    ip = piRadiance2RGB(oi,'etime',0.1);
    ip = ipSet(ip, 'name','icam');
    ipWindow(ip);

    %% Match wvf with OI
    % nsides = 0; % circular aperture
    % 
    optics = oiGet(oi,'optics');
    wvf    = optics2wvf(optics);
    % 
    % [aperture, params] = wvfAperture(wvf,'nsides',nsides,...
    %     'dot mean',50, 'dot sd',20, 'dot opacity',0.5,'dot radius',100,...
    %     'line mean',50, 'line sd', 20, 'line opacity',0.5,'linewidth',80);
    aperture = [];
    wvf = wvfComputeFromOI(oi, aperture);

    oi_wvf = oiCompute(wvf,scene);
    oi_wvf = oiSet(oi_wvf, 'name','wvfHDR');

    oiWindow(oi_wvf);
    oi_wvf = oiSet(oi_wvf,'displaymode','hdr');
    ip_wvf = piRadiance2RGB(oi_wvf,'etime',0.1);
    ip_wvf = ipSet(ip_wvf, 'name','wvfHDR');
    ipWindow(ip_wvf);
    
    % assert((mean(ip_wvf.data.result(:)) - mean(ip.data.result(:)))< 1/4096); % smaller than 1 digit for 12 bit
end


function binary_mask = create_shapes(image_size)
    % Create a blank image
    binary_mask = zeros(image_size, image_size);

    % Draw a circle
    center = [rand(image_size/2)+image_size/3, image_size/3+rand(image_size/2)]; % center of the circle
    radius = image_size/50;
    [x, y] = meshgrid(1:image_size, 1:image_size);
    binary_mask((x - center(1)).^2 + (y - center(2)).^2 <= radius^2) = 1;

    % Draw a rectangle
    top_left = round([image_size/2, image_size/2]);
    width = round(image_size/10);
    height = round(image_size/10);
    binary_mask(top_left(1):(top_left(1)+height), top_left(2):(top_left(2)+width)) = 1;

    % % Draw a triangle
    % vertices = [200, 300; 250, 400; 150, 400];
    % binary_mask = insertShape(binary_mask, 'FilledPolygon', vertices(:)', 'Color', 'white', 'Opacity', 1);

    % Draw a hexagon
    center_hex = [round(image_size*2/3+rand(round(image_size/3))), round(image_size*2/3+rand(round(image_size/3)))];
    size_hex = round(image_size/20);
    angle = 0:pi/3:2*pi;
    hex_x = center_hex(1) + size_hex * cos(angle);
    hex_y = center_hex(2) + size_hex * sin(angle);
    hexagon = [hex_x; hex_y];
    binary_mask = insertShape(binary_mask, 'FilledPolygon', hexagon(:)', 'Color', 'white', 'Opacity', 1);

    % Convert to binary
    binary_mask = im2bw(binary_mask);

    % Display the image
    % imshow(binary_mask);
end
%{
% Check some numbers
fprintf('COMPLETED: Wavefront Size: %d, takes %.2f seconds. \n',nPixels, toc(t));

psf_ss = wvfGet(wvf, 'psf spatial samples', 'um', 550);

psf_sample_interval = psf_ss(2)-psf_ss(1);

oi_sample_interval = oiGet(oi,'sample spacing','um'); 

fprintf('PSF sample interval is %f.2 um; \n OI sample interval is %f.2 um \n', psf_sample_interval*scaleFactor, oi_sample_interval(1));

figure;imagesc(wvf.psf{1});clim([1e-20 1e-7]);

wvf_fx = wvfGet(wvf, 'otf support', 'mm', 550);

fprintf('Freqency Extent: WVF: %.4f, OI: %.4f \n', wvf_fx(end)/scaleFactor, fx(end));
%}