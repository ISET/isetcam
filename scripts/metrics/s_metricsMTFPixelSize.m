%% Show how pixel size influences the modulation transfer function
%
% This script also illustrates how to
%
% # Define a scene
% # Create an optical image from the scene
% # Define a sensor
% # Evaluate the sensor MTF over a range of possible sensor
% parameters (pixel size)  
%
% We measure the system MTF properties using a simple slanted bar
% target along with the *ISO 12233* standard methods.
%
% This script is an example of a complicated (but useful)
% calculation.  We suggest that you begin programming scripts
% using other, simpler routines.  We include this script because
% it shows many features of the scripting language and the
% ability to interact with the GUI from scripts.
%
% Copyright ImagEval Consultants, LLC, 2005.

%% 
ieInit

%% Initialize parameters

% List of parameters we will set
fNumber = 4;
dyeSizeMicrons = 512;            % Microns

clear psSize;
pSize = [2 3 5 9];                % Microns

%% SCENE: Create a slanted bar image.  Make the slope some uneven value
scene = sceneCreate('slantedBar',512,7/3);

% Now we will set the parameters of these various objects.
% First, let's set the scene field of view.
scene = sceneAdjustLuminance(scene,100);    % Candelas/m2
scene = sceneSet(scene,'distance',1);       % meters
scene = sceneSet(scene,'fov',5);            % Field of view in degrees
% ieAddObject(scene); sceneWindow;

%% Create an optical image with some default optics.
oi = oiCreate;
oi = oiSet(oi,'optics fnumber',fNumber);

% Now, compute the optical image from this scene and the current optical
% image properties
oi = oiCompute(scene,oi);
% ieAddObject(oi); oiWindow;

%%  Create a default monochrome image sensor array

sensor = sensorCreate('monochrome');                %Initialize
sensor = sensorSet(sensor,'autoExposure',1);

% We are now ready to set sensor and pixel parameters to produce a variety
% of captured images.  
% Set the rendering properties for the monochrome imager. The default does
% not color convert or color balance, so it is appropriate. 
ip = ipCreate;

% To see the scene, optical image, sensor or virtual camera image in the
% GUI, use these commands
%    vcReplaceObject(scene); sceneWindow;
%    vcReplaceObject(oi); oiWindow;
%    vcReplaceObject(sensor); sensorImageWindow;
%    vcReplaceObject(vci); ipWindow;

% To determine the masterRect size, run this code and use the
% measured values of masterRect.
% Historical values:
%    masterRect = [183   202   100   130];
%    pS = 1;
%    pixel = pixelSet(pixel,'size',[pS,pS]*1e-6);
%    sensor = sensorSet(sensor,'pixel',pixel);
%    sensor = sensorSet(sensor,'rows',round(dyeSizeMicrons/pS));
%    sensor = sensorSet(sensor,'cols',round(dyeSizeMicrons/pS));
%    sensor = sensorCompute(sensor,oi); 
%    vcReplaceObject(sensor); sensorWindow;
%    vci = ipCompute(vci,sensor);
%    vcReplaceObject(vci); ipWindow;
%    [roiLocs,masterRect] = vcROISelect(vci);
masterRect = [ 199   168   101   167];   % March 12, 2007

%% Compute MTF across pixel sizes

mtfData = cell(1,length(pSize));
for ii=1:length(pSize)
    
    % Adjust the pixel size (meters)
    sensor = sensorSet(sensor,'pixel size constant fill factor',[pSize(ii) pSize(ii)]*1e-6);

    %Adjust the sensor row and column size so that the sensor has a constant
    %field of view.
    sensor = sensorSet(sensor,'rows',round(dyeSizeMicrons/pSize(ii)));
    sensor = sensorSet(sensor,'cols',round(dyeSizeMicrons/pSize(ii)));

    sensor = sensorCompute(sensor,oi);
    vcReplaceObject(sensor); 
     
    ip = ipCompute(ip,sensor);
    vcReplaceObject(ip); 
    % ipWindow;
    
    rect = round(masterRect/pSize(ii));
    roiLocs = ieRect2Locs(rect);
       
    barImage = vcGetROIData(ip,roiLocs,'results');
    c = rect(3)+1;
    r = rect(4)+1;
    barImage = reshape(barImage,r,c,3);
    % figure; imagesc(barImage(:,:,1)); axis image; colormap(gray);
    % pause;
    
    dx = sensorGet(sensor,'pixel width','mm');
    
    % Run the ISO 12233 code.  The results are stored in the window.
    % ISO12233(barImage);
    weight = [];
    mtfData{ii} = ISO12233(barImage, dx, weight, 'none');
    
end

% The mtfData cell array contains all the information plotted in this
% figure.  We graph the results, comparing the different pixel size MTFs. 
vcNewGraphWin;
c = {'r','g','b','c','m','y','k'};
for ii=1:length(mtfData)
    h = plot(mtfData{ii}.freq,mtfData{ii}.mtf,['-',c{ii}]);
    hold on
    newText = sprintf('%.0f um\n',pSize(ii));
    nfreq = mtfData{ii}.nyquistf;
    l = line([nfreq ,nfreq],[0.1,0],'color',c{ii});
    text((nfreq-10),0.12,newText,'color',c{ii});
end

xlabel('lines/mm');
ylabel('Relative amplitude');
title('MTF for different pixel sizes (fixed die size)');
hold off; grid on

%%