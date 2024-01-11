%% s_scielabHarmonicExperiments
%
% S-CIELAB experiments with sweep frequency targets
%
% Calculations to illustrate the chromatic-dependent spatial filtering
% used in S-CIELAB
%
% The first section uses sweep frequencies to illustrate the spatial
% filtering applied to the opponent-colors channels in S-CIELAB.
%
% The second section shows to of the images as they are being calculated,
% with an eye to illustrating the filtering and different color
% representations.
%
% See Also:  s_scielabExample
%
% Copyright ImagEval Consultants, LLC, 2010

%%
ieInit

%% Create a sweep frequency scene

sz = 512; maxF = sz/64;
scene = sceneCreate('Sweep Frequency',sz,maxF);

fov = 8; scene  = sceneSet(scene,'fov',fov);
% maximum frequency is maxF/fov

%% Prevent spatial aliasing at the sensor with a diffuser
oi     = oiCreate;
oi     = oiSet(oi,'Diffuser Method','blur');
oi     = oiSet(oi,'Diffuser blur',1.5e-6);
oi     = oiCompute(oi,scene);

%%
sensor = sensorCreate;

sensor = sensorSetSizeToFOV(sensor,fov*0.95,oi);
sensor = sensorCompute(sensor,oi);
vcReplaceAndSelectObject(sensor); sensorWindow;

%% Create the rendered image
vci    = ipCreate;
vci    = ipSet(vci,'correction method illuminant','gray world');
vci    = ipCompute(vci,sensor);

%% Versions with the same mean, but different color modulations
img = ipGet(vci,'result');
vcNewGraphWin; imagescRGB(img); title('Original'); truesize;

% This is the basic opponent image
imgOpp = imageLinearTransform(srgb2xyz(img), cmatrix('xyz2opp', 10));

mn = mean(RGB2XWFormat(imgOpp));
imgOpp2 = zeros(size(imgOpp));

%% Calculate the opponent color channel changes

% We alter the sweep frequency by scaling the three different opponent
% channels down.  The scale factors used to change the image are in the
% rows of this matrix, in order red-green, blue-yellow, luminance scale
% factors
sFactor = [
    1.0,  0.5, 1.0;
    1.0,  1.0, 0.5;
    0.75,  1.0, 1.0];

% We add a value in the corner to set the color bar, enforcing the same
% range for all of them.  If I knew what to set in colorbar, I would do
% that instead.
maxDE = 40;
cName ={'Red-green','blue-yellow','luminance'};

scP = scParams;
scP.sampPerDeg = 100;
whiteXYZ = srgb2xyz(ones(1,1,3));

%% Make the main images

for jj=1:3
    
    % This is the altered image
    for ii=1:3
        imgOpp2(:,:,ii) =  (imgOpp(:,:,ii) - mn(ii))*sFactor(jj,ii) + mn(ii);
    end
    img2 = xyz2srgb(imageLinearTransform(imgOpp2,cmatrix('opp2xyz',10)));
    
    
    %  Compute the S-CIELAB difference between the original and altered
    % We do this on padded images to avoid wrapping artifacts.  We should
    % probably clip the edges of the returned 'result'.
    result = ...
        scielab(padarray(img,[16 16 0]),padarray(img2,[16 16 0]),whiteXYZ,scP);
    result(end,end) = maxDE;  % Set a max to equate the colorbars.
    
    % Show the images
    vcNewGraphWin;
    imagescRGB(img2);
    title(sprintf('Channel %s altered',cName{jj}));
    
    vcNewGraphWin;
    imagesc(result); truesize;  axis off
    title(sprintf('Channel %s error',cName{jj}));
    
    % max(result(:))
    % If you change the parameters, you may need to know
    % the new max
end


%% End




