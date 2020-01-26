function [cMTF, camera] = cameraMTF(camera)
%Compute the MTF of a camera using ISO 12233 methods
%
%   [cMTF, camera] =  cameraMTF(camera)
%
% Input:
%   camera: A camera model
%
% Runs vcimageISOMTF on the camera structure.  
% Returns 
%  cMTF: a data structure with the camera MTF (cMTF) parameters
%  camera: A camera structure with the computed data (camera).
%
% See also: s_metricsCamera
%
% Copyright Imageval LLC, 2013

%% TODO
% We should consider implementing ISO12233(camera)

%% Check parameters
if ieNotDefined('camera'), error('Camera structure required.'); end

%% Compute the slanted edge scene
ip = vcimageISOMTF(camera);

% Clip result in case there are negative values - why would there be?
result = ipGet(ip,'result');
result(result<0) = 0;
ip = ipSet(ip,'result',result);

%% Analyze the slanted edge

% Find a rect data from the bar image in the image processor (ip).
rect = ISOFindSlantedBar(ip);
if isempty(rect)
    cMTF = [];
    return;
end

% a = get(ipWindow,'CurrentAxes');
% hold(a,'on');
% h    = ieDrawRect(a,rect,[1 0 1],3);
% delete(h)

roiLocs = ieRect2Locs(rect);
barImage = vcGetROIData(ip,roiLocs,'results');
c = rect(3)+1;
r = rect(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Get the pixel size so we can have real units
% sensor = camera.sensor;
% pixel = sensorGet(sensor,'pixel');
% dx = pixelGet(pixel,'width','mm');  % Pixel width in mm
dx = cameraGet(camera,'pixel width','mm');

% Run the ISO 12233 code.  The results are stored in the camera MTF
% structure (cMTF) and the window. 
cMTF      = ISO12233(barImage,dx);
cMTF.rect = rect;
cMTF.vci  = ip;

if nargout > 1
    % Save the result in the camera
    camera = cameraSet(camera,'ip',ip);
end

end

%%