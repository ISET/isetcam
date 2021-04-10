function [scoreStats, scoreTable] = expClassify(varargin)
% Compute classification experiment results for a particular camera design
%
%   classifierResults = expClassify(varargin)
%       eg: expClassify([imageFolder], [oi], [sensor], [ip])
%
% Will run a classifier on a folder of images, as well as on a version
% of those images that have been processed using optics, sensor, and ip
%
% Initial implementation offers googlenet, vgg19, resnet50, could add
% squeezenet easily. There is also an option to run a user-supplied
% classifier (called customnet).
%
% Note that loading a classifier will error the first time, requiring
% the pre-trained network add-in (a supporting package for the Deep Learning toolbox) to be
% downloaded. Link to the download appears in the script window,
% or can be found using the add-in explorer
% 
% Because they are expensive to calculate, we cache optical images and
% re-use them if the image name and the optics are the same.
%
% Processed images go into a sub-folder called "ip" and OIs into "optical
% image"
%
% If a folder is not supplied, the user is asked to supply one
%
% If elements of the camera are not specified, the current defaults are
% used.
% 

%%
varargin = ieParamFormat(varargin);

p = inputParser;

p.addParameter('optics',[],@(x)(isequal(class(x), 'struct')));
p.addParameter('sensor',sensorCreate(),@(x)(isequal(class(x), 'struct')));
p.addParameter('oi',oiCreate(),@(x)(isequal(class(x), 'struct')));
p.addParameter('ip',ipCreate(),@(x)(isequal(class(x), 'struct')));
p.addParameter('scoreClasses', 5);
p.addParameter('imageFolder',""); % or string
p.addParameter('classifier','resnet50'); % none means don't bother
p.addParameter('progDialog', "");
p.addParameter('ipOutputFolder', ''); % optionally force a different folder
p.addParameter('maxImages', 10000); % optionally limit how many images we'll process
p.parse(varargin{:});

optics   = p.Results.optics;
oi = p.Results.oi;
sensor   = p.Results.sensor;
ip = p.Results.ip;
imageFolder = p.Results.imageFolder;
scoreClasses = p.Results.scoreClasses;
progDialog = p.Results.progDialog;
ipFolder = p.Results.ipOutputFolder; 
maxImages = p.Results.maxImages;

%%
if ~isempty(p.Results.classifier)
    switch p.Results.classifier
        case 'squeezenet'
            net = squeezenet;
        case 'resnet50'
            net = resnet50;
        case 'googlenet'
            net = googlenet;
        case 'vgg19'
            net = vgg19;
            % if the user has their own network, they can name it customnet
            % select it from the classifier menu, and we'll use it
        case 'customnet'
            net = customnet;
        otherwise
            net = resnet50;
    end
else
    net = []; % assume if we get none, we don't want to classify resnet50; % vgg19; googlenet;
end

%% user points us to the folder of previously downloaded images they want to
% test. They can get those using imgBrowser+Flickr+curating+save, or
% however ...

if ~isfolder(imageFolder)
    inputFolder = uigetdir(fullfile(isetRootPath, "local", "images"), "Choose folder with the original images.");
else
    inputFolder = imageFolder;
end
    %inputFolder = fullfile(isetRootPath,'local','images','dogs');
if ~isempty(inputFolder) && ~isequal(inputFolder,0) && isfolder(inputFolder)
    inputFiles = dir(fullfile(inputFolder,'*.jpg'));
else
    msgbox("No images specified. Exiting.");
    scoreStats = [];
    scoreTable = [];
    return
end

outputOIFolder = fullfile(inputFolder,'opticalimage');
if ~exist(outputOIFolder,'dir'), mkdir(outputOIFolder); end

%% Make the optical images
wave = 400:10:700;

% our default sensor seems to be closer to 8 x 10 not 3 x 4,
desiredImageSize = [768 1024]; % a decent compromise that should work on average

% use optics if we are passed them, otherwise get from oi
if isempty(optics)
    optics = oi.optics;
end

cachedOpticsFlag = false; % default
if isfile(fullfile(outputOIFolder,'cachedOptics.mat'))
    load(fullfile(outputOIFolder,'cachedOptics.mat'),'cachedOptics');
    if isequal(cachedOptics, optics)
        cachedOpticsFlag = true;
    else
        % Save the new optics so that we can check to see if we can re-use the OI cache
        % in future
        cachedOptics = optics;
        save(fullfile(outputOIFolder,'cachedOptics'),'cachedOptics');        
    end
else
    % Save current optics so that we can check to see if we can re-use the OI cache
    cachedOptics = optics;
    save(fullfile(outputOIFolder,'cachedOptics'),'cachedOptics');
    
end

fovData = containers.Map('KeyType','char','ValueType','any');
%fovData = zeros(numel(inputFiles), 2);
maxImages = min(maxImages, numel(inputFiles));
for ii = 1:maxImages
    
    sceneFileName = fullfile(inputFiles(ii).folder, inputFiles(ii).name);

    initialImage = imread(sceneFileName);
    initialSize = size(initialImage);
    
    % Problem: We need to rotate something (sensor or image)
    % so that we get a fair capture. BUT: NNs are sensitive to orientation
    % so we either need to store to rotate back after re-reading, OR rotate
    % the OI back before we store it? OR ??
    imageRotation = 0; % the default
    if initialSize(1) > initialSize(2)
        imageRotation = -90;
        initialImage = imrotate(initialImage, -90);
    end
    
    % let's try not forcing the image size, since it may already be smaller
    %initialImage = imresize(initialImage, desiredImageSize);
    ourScene = sceneFromFile(initialImage,'rgb',[],'reflectance-display',wave);
    
    [~,thisFileName,~] = fileparts(inputFiles(ii).name);
    ourScene = sceneSet(ourScene,'name',thisFileName);
    sceneFOV = [sceneGet(ourScene,'fovhorizontal') sceneGet(ourScene,'fovvertical')];
    tmpFOV = containers.Map({thisFileName}, {sceneFOV});
    fovData = [fovData ; tmpFOV];
    % we pre-compute the optical image so it can be cached for future
    
    if isfile(fullfile(outputOIFolder,[thisFileName+".mat"]))
        cachedFile = true; % we have a file with the same name
    else
        cachedFile = false; % cheat for now
    end
    if cachedOpticsFlag == false || cachedFile == false
        if ~isequal(progDialog, '')
            progDialog.Indeterminate = 'off';
            progDialog.Message = "Generating Optical Images";
            progDialog.Value = ii/numel(inputFiles);
        end
        
        % HOW DO WE GET AN OI -- DO WE NEED IT PASSED OR CAN WE INVENT IT
        oi = oiCompute(oi, ourScene);
        oi.metadata.rotated = imageRotation;
        % Cropping principles:
        %   oiSize = sceneSize * (1 + 1/4))
        %   sceneSize = oiGet(oi,'size')/(1.25);
        %   [sceneSize(1)/8 sceneSize(2)/8 sceneSize(1) sceneSize(2)]
        %   rect = [row col height width]
        
        sz     = sceneGet(ourScene,'size');
        rect   = round([sz(2)/8 sz(1)/8 sz(2) sz(1)]);
        % I think maybe Brian changed things so we don't need this??
        %oi = oiCrop(oi,rect);
        % oiWindow(oiTest);
        
        save(fullfile(outputOIFolder,[oiGet(oi,'name'),'.mat']),'oi');
        
    end
end

%%  Set sensor and ip parameters and create sample images with those parameters
% Corrects for aspect ratio
sensor = sensorSet(sensor, 'size', [desiredImageSize(1) desiredImageSize(2)]);

if isempty(ipFolder)
    ipFolder = fullfile(inputFolder,'ip');
end

if ~exist(ipFolder,'dir'), mkdir(ipFolder); end


oiList = dir(fullfile(outputOIFolder,'*.mat'));

defDir = pwd;
chdir(outputOIFolder); % this is so stupid!
for ii=1:numel(oiList)
    % oiRGB = oiGet(ourOI,'rgb image');
    % ieNewGraphWin; imagescRGB(oiRGB)
    
    % don't load our cache file!
    if ~isequal(oiList(ii).name, 'cachedOptics.mat')
        load(oiList(ii).name,'oi');
        oiSize = size(oi.data.photons); % I think this is a proxy for resolution
        
        try
            fName = split(oiList(ii).name,'.');
            sceneFOV = fovData(fName{1});
        catch
            sceneFOV = [45 30]; % arbitrary default, but should never get here
        end
        sensor = sensorSetSizeToFOV(sensor,sceneFOV,oi);

        if ~isequal(progDialog, '')
            progDialog.Indeterminate = 'off';
            progDialog.Message = "Generating images captured by your Sensor & IP";
            progDialog.Value = ii/numel(oiList);
        end

        sensor = sensorCompute(sensor,oi);
        % sensorWindow(sensor);
        
        ip  = ipCompute(ip,sensor);
        rgb = ipGet(ip,'result');
        
        [fPath, fName, fExt] = fileparts(sceneFileName);
        ourOutputFileName = fullfile(ipFolder, sprintf('%s.jpg',oiGet(oi,'name')));
        if isfield(oi.metadata, 'rotated') && oi.metadata.rotated ~= 0
            rgb = imrotate(rgb, -1 * oi.metadata.rotated);
        end
        imwrite(rgb,ourOutputFileName);
    end
end
chdir(defDir);

%% If no classifier, we stop here
if isempty(net)
    return
end

%%  Let's classify with the chosen network (probably Resnet-50)

try
    inputSize = net.Layers(1).InputSize;
catch
    msgbox("Unable to load specified network.");
end
% We would want to run our classifier on the original folder
%  and the camera images and djinn up some comparison info, depending on
%  what we decide we want to use as a metric. Right now just runs on the
%  original image folder and prints out what it finds.

totalScore = 0;
ourScoreArray = [];
for ii = 1:maxImages
    
        if ~isequal(progDialog, '')
            progDialog.Indeterminate = 'off';
            progDialog.Message = "Classifying Images";
            progDialog.Value = ii/numel(inputFiles);
        end

    % Classify each of the original downloaded images
    ourGTFileName = fullfile(inputFiles(ii).folder, inputFiles(ii).name);
    ourGTImage = imread(ourGTFileName);
    
    %classifiers can only work with 3-channel images
    if ismatrix(ourGTImage)
        % probably grayscale and image control needs
        % 'color'
        ourGTImage = cat(3, ourGTImage, ourGTImage, ourGTImage);
    end

    % in theory we could first resize to our "desiredImageSize" to match
    % the processing of the IP version, but I'm not sure it matters?
    %ourGTImage = imresize(ourGTImage, desiredImageSize(1:2));

    % downsize to match the input layer of the NN
    ourGTImage = imresize(ourGTImage,inputSize(1:2));
    [label, scores] = classify(net,ourGTImage);
    disp(label)
    [~,idx] = sort(scores,'descend');
    idx = idx(1:scoreClasses);
    classNamesGTTop = net.Layers(end).ClassNames(idx);
    scoresGTTop = scores(idx);
    
    % for now we just output the top classes for each image, but of
    % course would want to do something smart with them & scores
    disp(strcat("Classes for GT image: ", fullfile(inputFiles(ii).folder, inputFiles(ii).name)));
    disp(classNamesGTTop) % the top scoreClasses possible classes
    
    % Classify using the simulated images, through the sensor
    ipFileName = fullfile(ipFolder, inputFiles(ii).name);
    
    ourTestImage = imread(ipFileName);
    
    % downsize to match the input layer of the NN
    ourTestImage = imresize(ourTestImage,inputSize(1:2));
    [label, scores] = classify(net,ourTestImage);
    disp(label)
    
    % The scores are worst to best when sorted this way?
    [~,idx] = sort(scores,'descend');
    idx = idx(1:scoreClasses);
    classNamesTestTop = net.Layers(end).ClassNames(idx);
    scoresTestTop = scores(idx);

    % for now we just output the top classes for each image, but of
    % course would want to do something smart with them & scores
    disp(strcat("Classes for our Simulated Test image: ", ipFileName));
    disp(classNamesTestTop)% the top scoreClasses possible classes
    
    imageScore = length(find(ismember(classNamesGTTop, classNamesTestTop)));
    totalScore = totalScore + imageScore;
    
    padCells = cell(scoreClasses,1);
    padCells(:) = {''};

    % need to make sure each row we add has the same number of elements
    ourScoreArray = [ourScoreArray ; ["Image Name:" inputFiles(ii).name ourGTFileName ipFileName]];
    ourScoreArray = [ourScoreArray ; [classNamesGTTop classNamesTestTop padCells padCells]];
    ourScoreArray = [ourScoreArray ; ["-----------" strcat("Score: ", string(imageScore)) "..." "..."]];

    disp(strcat("Image Matching Score: ", string(imageScore)));
    
end

%%
disp(strcat("Total score for: ", string(length(inputFiles)), " images is: ", string(totalScore)));
scoreStats = [totalScore length(inputFiles)*scoreClasses length(inputFiles)];
scoreTable = ourScoreArray; % pass back Cell Array for now instead of a true table
end
%%