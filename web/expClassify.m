function classifierResults = expClassify(varargin)
% Compute classification experiment results for a particular camera design
%
%   classifierResults = expClassify(varargin)
%       eg: expClassify([imageFolder], [oi], [sensor], [ip])
%
% start with Googlenet, vgg, resnet, can use others.
% Note that they will error the first time, require an add-in to be
% downloaded. Link to the download appears in the script window,
% or can be found using the add-in explorer

%%
varargin = ieParamFormat(varargin);

p = inputParser;

p.addParameter('oi',oiCreate(),@(x)(equals(class(x), 'struct')));
p.addParameter('sensor',sensorCreate(),@(x)(equals(class(x), 'struct')));
p.addParameter('pipeline',ipCreate(),@(x)(equals(class(x), 'struct')));
p.addParameter('imageFolder',"",@ischar); % or string?
p.parse(varargin{:});

oi   = p.Results.oi;
sensor   = p.Results.sensor;
ip = p.Results.pipeline;
imageFolder = p.Results.imageFolder;

%%
net = resnet50; % vgg19; googlenet;

% user points us to the folder of previously downloaded images they want to
% test. They can get those using imgBrowser+Flickr+curating+save, or
% however ...

%%
if ~isfolder(imageFolder)
    inputFolder = uigetdir(fullfile(isetRootPath, "local", "images"), "Choose folder with the original images.");
else
    inputFolder = imageFolder;
end
    %inputFolder = fullfile(isetRootPath,'local','images','dogs');
inputFiles = dir(fullfile(inputFolder,'*.jpg'));

outputOIFolder = fullfile(inputFolder,'opticalimage');
if ~exist(outputOIFolder,'dir'), mkdir(outputOIFolder); end

%% Make the optical images
wave = 400:10:700;

fovData = [];

% our default sensor seems to be closer to 8 x 10 not 3 x 4,
desiredImageSize = [768 1024]; % a decent compromise that should work on average
for ii = 1:numel(inputFiles)
    
    sceneFileName = fullfile(inputFiles(ii).folder, inputFiles(ii).name);
    % what if our original image is portrait mode? It won't match our
    % camera sensor very well.
    initialImage = imread(sceneFileName);
    initialSize = size(initialImage);
    if initialSize(1) > initialSize(2)
        initialImage = imrotate(initialImage, -90);
    end
    initialImage = imresize(initialImage, desiredImageSize);
    ourScene = sceneFromFile(initialImage,'rgb',[],'reflectance-display',wave);
    
    [~,thisFileName,~] = fileparts(inputFiles(ii).name);
    ourScene = sceneSet(ourScene,'name',thisFileName);
    sceneFOV = sceneGet(ourScene,'fov');
    fovData(ii) = sceneFOV;
    % we pre-compute the optical image so it can be cached for future
    oi = oiCompute(oi, ourScene);
    
    % Cropping principles:
    %   oiSize = sceneSize * (1 + 1/4))
    %   sceneSize = oiGet(oi,'size')/(1.25);
    %   [sceneSize(1)/8 sceneSize(2)/8 sceneSize(1) sceneSize(2)]
    %   rect = [row col height width]
    
    sz     = sceneGet(ourScene,'size');
    rect   = round([sz(2)/8 sz(1)/8 sz(2) sz(1)]);
    oi = oiCrop(oi,rect);
    % oiWindow(oiTest);
    
    save(fullfile(outputOIFolder,[oiGet(oi,'name'),'.mat']),'oi');
end

%%  Set sensor and ip parameters and create sample images with those parameters
sensor = sensorSet(sensor, 'size', [desiredImageSize(1) desiredImageSize(2)]);
outputRGB = fullfile(inputFolder,'ip');
if ~exist(outputRGB,'dir'), mkdir(outputRGB); end


oiList = dir(fullfile(outputOIFolder,'*.mat'));

defDir = pwd;
chdir(outputOIFolder); % this is so stupid!
for ii=1:numel(oiList)
    % oiRGB = oiGet(ourOI,'rgb image');
    % ieNewGraphWin; imagescRGB(oiRGB)
    load(oiList(ii).name,'oi');
    oiSize = size(oi.data.photons); % I think this is a proxy for resolution
    
    sceneFOV = fovData(ii);
    sensor = sensorSetSizeToFOV(sensor,sceneFOV,ourScene,oi);
    
    sensor = sensorCompute(sensor,oi);
    % sensorWindow(sensor);
    
    ip  = ipCompute(ip,sensor);
    rgb = ipGet(ip,'result');
    
    [fPath, fName, fExt] = fileparts(sceneFileName);
    ourOutputFileName = fullfile(outputRGB, sprintf('%s.jpg',oiGet(oi,'name')));
    imwrite(rgb,ourOutputFileName);
end
chdir(defDir);

%%  Let's classify with the ResNet

ipFolder = fullfile(inputFolder,'ip');

inputSize = net.Layers(1).InputSize;

% We would want to run our classifier on the original folder
%  and the camera images and djinn up some comparison info, depending on
%  what we decide we want to use as a metric. Right now just runs on the
%  original image folder and prints out what it finds.

totalScore = 0;
for ii = 1:length(inputFiles)
    % Classify each of the original downloaded images
    ourGTFileName = fullfile(inputFiles(ii).folder, inputFiles(ii).name);
    ourGTImage = imread(ourGTFileName);
    ourGTImage = imresize(ourGTImage,inputSize(1:2));
    [label, scores] = classify(net,ourGTImage);
    disp(label)
    [~,idx] = sort(scores,'descend');
    idx = idx(1:5);
    classNamesGTTop = net.Layers(end).ClassNames(idx);
    scoresGTTop = scores(idx);
    
    % for now we just output the top classes for each image, but of
    % course would want to do something smart with them & scores
    disp(strcat("Classes for GT image: ", fullfile(inputFiles(ii).folder, inputFiles(ii).name)));
    disp(classNamesGTTop) % the top 5 possible classes
    
    % Classify using the simulated images, through the sensor
    ipFileName = fullfile(ipFolder, inputFiles(ii).name);
    
    ourTestImage = imread(ipFileName);
    ourTestImage = imresize(ourTestImage,inputSize(1:2));
    [label, scores] = classify(net,ourTestImage);
    disp(label)
    
    % The scores are worst to best when sorted this way?
    [~,idx] = sort(scores,'descend');
    idx = idx(1:5);
    classNamesTestTop = net.Layers(end).ClassNames(idx);
    scoresTestTop = scores(idx);
    
    % for now we just output the top classes for each image, but of
    % course would want to do something smart with them & scores
    disp(strcat("Classes for our Simulated Test image: ", ipFileName));
    disp(classNamesTestTop)% the top 5 possible classes
    
    imageScore = length(find(ismember(classNamesGTTop, classNamesTestTop)));
    totalScore = totalScore + imageScore;
    disp(strcat("Image Matching Score: ", string(imageScore)));
    
end

%%
disp(strcat("Total score for: ", string(length(inputFiles)), " images is: ", string(totalScore)));

end
%%