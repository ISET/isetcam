function eAnalysis = cameraVSNR(camera,lightLevels,exposureTime)
% Analyze vSNR for a camera module
%
%   eAnalysis = cameraVSNR(camera,lightLevels)
%
% Visible SNR calculation on a camera model.
% This interacts entirely with the light exposure time and light level.
% Let's figure out what we want to do.  Maybe do it for a standard exposure
% duration, say 10 ms?
%
% Example:
%
% See also:
%
% Copyright ImagEval Consultants, LLC, 2012

if ieNotDefined('camera'), error('Camera required.'); end
if ieNotDefined('lightLevels'), lightLevels = [1, 10, 100]; end
if ieNotDefined('exposureTime'), exposureTime = 0.01; end

vSNR = zeros(size(lightLevels));

% Save sensor exposure time to make sure we don't saturate
eTime = zeros(size(lightLevels));
dpi = 100; dist = 0.20;

for ii=1:length(lightLevels)
    
    scene  = sceneCreate('uniform d65');
    scene  = sceneSet(scene,'fov',5);
    scene  = sceneAdjustLuminance(scene,lightLevels(ii));
    camera = cameraSet(camera,'sensor exp time',exposureTime);
    
    c = cameraCompute(camera,scene);
    
%     oi     = oiCompute(camera.oi,scene);
%     
%     % Set exposure to about 0.8 saturation.  
%     % eTime(ii) = autoExposure(oi,camera.sensor,0.8);
%     sensor = sensorSet(camera.sensor,'exp time',exposureTime);  %
%     sensor = sensorCompute(sensor,oi);
%     % v = sensorGet(sensor,'volts',2);
%     % vcNewGraphWin; histogram(v(:),50);
%     
%     vci    = ipCompute(camera.vci,sensor);
%     result = ipGet(vci,'result');
    
    resultMax  = cameraGet(c,'ip result max');
    sensorMax = cameraGet(c,'ip max sensor');  % Changed this.  Is it right?
    
    % Scale the displayed data so the max value is the max of the display.
    %     resultMax  = ipGet(vci,'result max');
    %     displayMax = ipGet(vci,'rgb max');
    if (sensorMax - resultMax) < 10*eps
        % Meaningless because saturated
        fprintf('Saturated at light level %.2f\n',lightLevels(ii));
        vSNR(ii) = NaN;
        rect = [];
    else
        vci = cameraGet(c,'vci');
        result = ipGet(vci,'result');
        
        % Scale result to display max
        vci = ipSet(vci,'result',result*(sensorMax/resultMax));
        
        % Exclude edge regions (10 percent of each edge)
        % rect = [colmin,rowmin,width,height]
        if ii==1
            sz   = ipGet(vci,'size');
            border   = round(sz(1:2)*0.1);   % Border
            rect = [border(2), border(1), sz(2)-(2*border(2)), sz(1)-(2*border(1))];
        end
        
        % What are the units?  1 / Delta E, I think.
        vSNR(ii) = vcimageVSNR(vci,dpi,dist,rect);
    end
    
    vci = ipSet(vci,'name',sprintf('Level %.2f',lightLevels(ii))); 
    eAnalysis.vci(ii) = vci;
    
end

eAnalysis.vSNR = vSNR;
eAnalysis.lightLevels = lightLevels;
eAnalysis.oi = cameraGet(camera,'oi');
eAnalysis.sensor = cameraGet(camera,'sensor');
eAnalysis.eTime = eTime;
eAnalysis.rect = rect;

end