function eAnalysis = cameraVSNR(camera)
% Analyze vSNR for a camera module
%
%   eAnalysis = cameraVSNR(camera)
%
% Visible SNR calculation on a camera model.
%
% Example:
%
% See also:
%
% Copyright ImagEval Consultants, LLC, 2012

if ieNotDefined('camera'), error('Camera required.'); end

meanLuminances = [3, 6, 12, 25, 50, 100, 200, 400];
% Generally saturation starts around meanLuminance of 200.  It depends some
% on the scene though.  We should expect some non-negligible saturation for
% mean luminance values over 200.


vSNR = zeros(size(meanLuminances));

dpi = 100; dist = 0.20;

oi     = cameraGet(camera,'oi');
sensor = cameraGet(camera,'sensor');
sDist  = 1000;       % distance of imager from scene (m)
fov    = sensorGet(sensor,'fov',sDist,oi);

scene  = sceneCreate('uniform d65');
scene  = sceneSet(scene,'fov',fov);
for ii=1:length(meanLuminances)
    
    scene  = sceneAdjustLuminance(scene,meanLuminances(ii));
    
    % The result is an lRGB image, like an sRGB but without the gamma curve
    [camera, result] = cameraCompute(camera, scene);
    % vcNewGraphWin; imagescRGB(result);
    
    % TODO: Check for saturation of one or more channels
    rgbMeans = mean(RGB2XWFormat(result));
    if max(rgbMeans) > 0.99,     warning('High channel means %.3f',rgbMeans);
    elseif min(rgbMeans) < 0.01, warning('Low channel means %.3f',rgbMeans);
    end
    
    % Rendering algorithm:
    % Scale so the mean of a constant image is at the half way point of
    % linear RGB.
    result = result/mean(result(:))*.5;
    
    % Clip
    % result = ieClip(result, 0, 1);
    
    % Store the newly transformed lRGB image into the vci.  The one 
    vci = cameraGet(camera, 'vci');
    vci = ipSet(vci, 'result', result);
    
    % Set the rect for computing vSNR: Exclude edge regions (10 percent of each edge)
    % rect = [colmin,rowmin,width,height]
    if ii==1
        sz   = size(result);
        border   = round(sz(1:2)*0.1);   % Border
        rect = [border(2), border(1), sz(2)-(2*border(2)), sz(1)-(2*border(1))];
    end

    % What are the units?  1 / Delta E, I think.
    vSNR(ii) = vcimageVSNR(vci,dpi,dist,rect);        
end

eAnalysis.vSNR = vSNR;
eAnalysis.meanLuminances = meanLuminances;

end