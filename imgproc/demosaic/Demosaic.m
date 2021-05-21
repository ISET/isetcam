function demosaicedImage = Demosaic(ip,sensor)
%Color demosaicking interface routine
%
%    demosaicedImage = Demosaic(ip,sensor)
%
% This routine calls functions for demosaicking a typical CFA sensor.
%
% But, first we detect whether sensor is an array that needs no
% demosaicking. In that case, we simply copy the data from each of the
% sensors in the array and return that as demosaicedImage.
%
% If sensor is a single sensor with a mosaic, the sensor data were copied
% into the vci 'input' slot prior to getting here, as part of the
% ipCompute routine. The input data are stored in a planar image
% (r,c). The sensor structure is passed in because it contains a
% few parameters we need.
%
% The selected demosaic algorithm in the vci converts the planar (mosaic)
% sensor data to an (r,c,3) using the information about the sensor in the
% sensor structure and the routine plane2rgb().
%
% If the data come in as (r,c,3) format (i.e., RGB), then plane2rgb() is
% skipped.  This can happen if there is a routine inserted between
% sensorCompute() and ipCompute().  When they are in that format
% however, we still expect that demosaicking is needed (i.e., many of the
% values in the RGB format are zero.
%
% The returned demosaicedImage is a (r,c,w) image. For RGB data w is 3.
%
% The available demosaic methods will grow over time. For now they are
%
%    {'ieBilinear'}
%    {'laplacian'}
%    {'adaptive laplacian'}
%    {'pocs'}  - Projection onto convex sets
%    {'nearest neighbor'}
%    {'multichannel'}  - linear initerpolation for multichannel sensor
%    {'analog rccc'}   - Special case of Red/Clear... sensor
%
% ieExamplesPrint('Demosaic');
%
% See also:
%   plane2rgb(), demosaicMultichannel(), t_ipDemosaic
%

% Examples:
% Conventional call
%{
 scene = sceneCreate; camera = cameraCreate;
 camera = cameraCompute(camera,scene);
 sensor = cameraGet(camera,'sensor'); ip = cameraGet(camera,'ip');
 d = Demosaic(ip,sensor);
 ieNewGraphWin; imagescRGB(d)
%}
%{
 scene = sceneCreate; camera = cameraCreate;
 sensor = sensorCreate('MT9V024',[],'rccc');
 camera = cameraSet(camera,'sensor',sensor);
 camera = cameraSet(camera,'ip demosaic method','analog rccc');
 camera = cameraCompute(camera,scene);
 % cameraWindow(camera,'sensor');
 % cameraWindow(camera,'ip')
%}
%{
% For monochrome, Demosaic does nothing.
 scene = sceneCreate; camera = cameraCreate; oi = cameraGet(camera,'oi');
 sensor = sensorCreate('monochrome'); ip = cameraGet(camera,'ip');
 oi = oiCompute(oi,scene); sensor = sensorCompute(sensor,oi);
 ip = ipSet(ip,'demosaic method','bilinear');
 d = Demosaic(ip,sensor);
 ieNewGraphWin; imagesc(d); colormap(gray(64));
%}
%{
% For more than 3 (multichannel) data this works
  sensor = ieGetObject('sensor'); ip = ieGetObject('ip');
  ip = ipSet(ip,'demosaic method','multichannel');
  d = Demosaic(ip,sensor); imtool(d)
%}


%% Check for a sensor array
if length(sensor) > 1
    % Sensor array.  Copy the data from each of the sensors in the array
    % into demosaicedImage. In this case there is no demosaicking, the
    % multiple sensors each capture the full set of color samples.
    %
    % This is used for 'ideal' sensor calculations and certain types of
    % imagers such as prismatic sensors, Foveon style sensors, and who
    % knows what else will come our way.
    N = length(sensor);                % How many different sensors
    sz = sensorGet(sensor(1),'size');  % The spatial row/col of the sensors
    demosaicedImage = zeros(sz(1),sz(2),N);
    for ii=1:N
        % We should test to see if the sensors are monochrome.
        demosaicedImage(:,:,ii) = sensorGet(sensor(ii),'dv or volts');
    end
    return;  % No real demosaicking happens.
end

%% A typical mosaic case -  get the image input data

% Normally, these are just a copy of the sensor output data, the sensor
% image matrix (planar format)
% ip  = ipSet(ip,'input',double(sensorGet(sensor,'volts')));
img = ipGet(ip,'input');

% If the data are in planar format, put them into RGB format.  Otherwise
% if they are already in RGB format (i.e. multiplanar) copy them and move
% on.
if ismatrix(img),  imgRGB = plane2rgb(img,sensor,0);
else,              imgRGB = img;
end

% The planes are in the order of the filterNames. So, if the first filter
% name is bXXX then the first plane are the blue data
% figure(1); ii = 2; imagesc(imgRGB(1:6,1:6,ii))
% figure(2); sensorShowCFA(sensor);

% Translator for the demosaic method.  This should get used to clarify the
% multichannel options below.
m = ipGet(ip,'demosaicmethod');
m = ieParamFormat(m);
switch lower(m)
    case {'iebilinear','bilinear'}
        method = 'ieBilinear';
    case {'multichannel'}
        method = 'multichannel';
    case {'adaptivelaplacian'}
        method = 'adaptivelaplacian';
    case {'laplacian'}
        method = 'laplacian';
    case {'lcc1'}
        method = 'lcc1';
    case {'nearestneighbor'}
        method = 'nearestneighbor';
    case {'pocs','proj conv sets (pocs)'}
        method = 'pocs';
    case {'analogrccc'}
        % Analog systems RCCC implementation from Zhenyi
        % method = 'analogrccc';
        method = 'analogrccc';
    otherwise
        error('Unknown demosaic method %s\n',m);
end

% The data are now in RGB format.    Could be 2D or 3D.

% Some of the case statements need to know the Bayer pattern.  So we
% compute it in case we need it.
cLetters = sensorGet(sensor,'filter Color Letters');
pattern  = sensorGet(sensor,'pattern');
bPattern = cLetters(pattern);
bPattern = bPattern';
bPattern = bPattern(:)';

method = ieParamFormat(method);
switch lower(method)
    case {'bilinear','iebilinear'}
        if size(imgRGB,3) == 3 && isequal(size(pattern) ,[2 2])
            % ieBilinear is designed for Bayer 2x2 case.  Otherwise, just use
            % linear interpolation in the next else case.
            demosaicedImage = ieBilinear(imgRGB,sensorGet(sensor,'pattern'));
        else
            demosaicedImage = demosaicMultichannel(imgRGB,sensor,'interpolate');
        end
        
    case 'adaptivelaplacian'
        clipToRange = 0;
        if (strcmp(bPattern,'grbg') || ...
                strcmp(bPattern,'rggb') || ...
                strcmp(bPattern,'bggr'))
            demosaicedImage = AdaptiveLaplacian(imgRGB, bPattern, clipToRange);
        else
            hdl = ieSessionGet('vcimagehandles');
            str = 'Sensor color format must be rggb or bggr for Laplacian. Using ieBilinear.';
            ieInWindowMessage(str,hdl)
            demosaicedImage = ieBilinear(imgRGB,sensorGet(sensor,'pattern'));
        end
        
    case 'laplacian'
        clipToRange = 0;
        demosaicedImage = Laplacian(imgRGB,bPattern,clipToRange);
        
        % case 'lcc1'
        % Not properly implemented yet.
        % demosaicedImage = lcc1(imgRGB);
        
    case 'nearestneighbor'
        % Should work on CMY, too, no?
        demosaicedImage = ieNearestNeighbor(imgRGB,bPattern);
        
    case 'pocs'
        % Projection on convex sets
        % Function should be renamed to iePocs
        if (strcmp(bPattern,'grbg') || ...
                strcmp(bPattern,'rggb') || ...
                strcmp(bPattern,'bggr') ||...
                strcmp(bPattern,'gbrg'))
            demosaicedImage = Pocs(imgRGB,bPattern);
        else
            hdl = ieSessionGet('vcimagehandles');
            str = 'Sensor color format incompatible with POCS. Using ieBilinear.';
            ieInWindowMessage(str,hdl)
            demosaicedImage = ieBilinear(imgRGB,sensorGet(sensor,'pattern'));
        end
        
    case {'multichannel','interpolate'}
        % There is one multichannel routine, but it can be called in
        % different ways. This is a little ugly - deefault multichannel
        % means linearly interpolate with griddata, while the other ways
        % may do different demosaicking.
        demosaicedImage = demosaicMultichannel(imgRGB,sensor,'interpolate');
        
    case 'usewideband'
        % Needs comments - MP
        demosaicedImage = demosaic_wideband(imgRGB,sensor);
        
    case 'analogrccc'
        % Needs testing
        demosaicedImage = demosaicRCCC(imgRGB);
        
    otherwise
        % This may be a custom method added by the user.  If we find an
        % executable by this name, then we will try running it.
        error('Demosaic method (%s) not found.',method);
end

end

