function metric = cameraFullReference(camera)

% metric = cameraFullReference(camera)
%
% Calculates the quality of a few rendered scenes by appying a full
% reference metric and comparing to the ideal image.  Scenes are chosen
% below and are arbitrarly chosen natural scenes.
%
% Output is a structure containing all results.

sceneNames = {'StuffedAnimals_tungsten-hdrs'};
% sceneNames = {'zone plate'};
meanLuminances = [3, 6, 12, 25, 50, 100, 200, 400];
% Generally saturation starts around meanLuminance of 200.  It depends some
% on the scene though.  We should expect some non-negligible saturation for
% mean luminance values over 200.


metric.scielab = zeros(length(sceneNames), length(meanLuminances));
metric.ssim = zeros(length(sceneNames), length(meanLuminances));
for sceneNum = 1:length(sceneNames)
    sceneName = sceneNames{sceneNum};
    
    scene = sceneFromFile(sceneName, 'multispectral');
    %     tmp = load(sceneName,'scene');
    %     scene = tmp.scene;
    
    %     scene = sceneCreate('zone plate',[1000,1000]);
    
    % Change illuminant to D65
    scene = sceneAdjustIlluminant(scene,'D65.mat');
    
    % Adjust scene field of view to be proportional to camera's
    oi     = cameraGet(camera,'oi');
    sensor = cameraGet(camera,'sensor');
    sDist  = sceneGet(scene,'distance');
    fov    = sensorGet(sensor,'fov',sDist,oi);
    %     scene = sceneSet(scene,'fov',fov);
    scene = sceneSet(scene,'fov',1.26*fov);
    % 26% increase is to account for difference in aspect ratio
    
    for meanLuminanceNum = 1:length(meanLuminances)
        % Adjust scene's mean luminance
        meanLuminance = meanLuminances(meanLuminanceNum);
        scene = sceneAdjustLuminance(scene,meanLuminance);
        
        % Calculate ideal XYZ image
        [camera,xyzIdeal] = cameraCompute(camera,scene,'idealxyz');
        xyzIdeal  = xyzIdeal / max(xyzIdeal(:));
        [srgbIdeal, lrgbIdeal] = xyz2srgb(xyzIdeal);
        
        % Calculate camera result
        [camera, lrgbResult] = cameraCompute(camera,'oi',lrgbIdeal);   % OI is already calculated
        
        % Crop border of image to remove any errors around the edge of the
        % image       (this is similar to L3imcrop but with a fixed width)
        xyzIdeal   = xyzIdeal(11:end-10, 11:end-10, :);
        srgbIdeal  = srgbIdeal(11:end-10, 11:end-10, :);
        lrgbResult = lrgbResult(11:end-10, 11:end-10, :);
        
        % Convert result image to sRGB and XYZ
        srgbResult = lrgb2srgb(ieClip(lrgbResult,0,1));
        xyzResult  = srgb2xyz(srgbResult);
        
        %% S-CIELAB
        whitept = sceneGet(scene,'illuminant xyz');
        whitept = whitept/max(whitept);
        
        scielabim = scielab(xyzIdeal,xyzResult,whitept);
        metric.scielab(sceneNum,meanLuminanceNum) = mean(scielabim(:));
        
        %% SSIM
        grayIdeal  = rgb2gray(srgbIdeal);
        grayResult = rgb2gray(srgbResult);
        
        max_grayIdeal = max(grayIdeal(:));
        
        % Following scales images by their max value.  I don't think we
        % want to scale them since that was done previously.  Instead the
        % scaling to 255 and conversion to uint8 is still performed.
        %         grayIdeal_uint8 = uint8((grayIdeal/max_grayIdeal)*255);
        %         grayResult_uint8 = uint8((grayResult/max_grayIdeal)*255);
        grayIdeal_uint8 = uint8(grayIdeal*255);
        grayResult_uint8 = uint8(grayResult*255);
        
        K = [0.01 0.03]; % constants in the SSIM index formula
        window = fspecial('gaussian', 11, 1.5); % local window for statistics
        L = 255; % L: dynamic range of the images
        mssim = ssim_index(grayIdeal_uint8, grayResult_uint8, K, window, L);
        metric.ssim(sceneNum,meanLuminanceNum) = mssim;
        
        % To see an image use ssim_map from following call:
        %         [mssim, ssim_map] = ssim_index(grayIdeal_image, grayL3_image, K, window, L);
        
    end
end
