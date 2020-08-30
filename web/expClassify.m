% playground for experimenting with classification
%
% start with Googlenet, vgg, resnet, can use others.
% Note that they will error the first time, require an add-in to be
% downloaded. Link to the download appears in the script window, 
% or can be found using the add-in explorer
%
net = resnet50; % vgg19; googlenet;

% user points us to the folder of previously downloaded images they want to
% test. They can get those using imgBrowser+Flickr+curating+save, or
% however ...
inputFolder = uigetdir(fullfile(isetRootPath, 'local', 'images'), "Get Test Folder");
outputSubFolder = "simulated";

dirList = dir(inputFolder);
fileList = [];

% all this code simply to get just a list of files:)
for i = 1:length(dirList)
    if isfile(fullfile(dirList(i).folder, dirList(i).name))
        % There HAS to be a better way to do this in Matlab!
        if length(fileList) == 0
            fileList = [dirList(i)];
        else
            fileList(end+1) = dirList(i);
        end
    end
end

% does this make one if none exists? Otherwise check & create
ourSensor = ieGetObject('isa');

% create a folder for our simulated outputs
mkdir(fullfile(inputFolder,outputSubFolder));

for i = 1:length(fileList)
    sceneFileName = fullfile(fileList(i).folder, fileList(i).name);
    ourScene = sceneFromFile(sceneFileName,'rgb');
    % Here is where I get confused!!
    ourOI = ieGetObject('OPTICALIMAGE'); %this doesn't seem right!
    computedOI = oiCompute(ourScene, ourOI);
    
    [fPath, fName, fExt] = fileparts(sceneFileName);
    ourOutputFileName = fullfile(fPath, outputSubFolder, strcat(fName, ".png"));
    oiSaveImage(computedOI,ourOutputFileName);

    % djc note: I think we should free up the computedOI here to save memory
    % but I'm not sure if I can set it to [] directly, or need to call a
    % vc* routine to make sure other stuff is also reset, or ??
    
% punt on sensor for now, see if we can just to optics!
%    ourImage = sensorCompute(ourSensor,computedOI);
    
%    [val,isa] = ieGetSelectedObject('ISA');
%    gam = str2double(get(handles.editGam,'String'));
%    scaleMax = get(handles.btnDisplayScale,'Value');
%    outputFileName = sensorSaveImage(isa,[],'volts',gam,scaleMax);
    % Need to write these files someplace!
end

inputSize = net.Layers(1).InputSize;

% We would want to run our classifier on the original folder
%  and the camera images and djinn up some comparison info, depending on
%  what we decide we want to use as a metric. Right now just runs on the
%  original image folder and prints out what it finds.

totalScore = 0;
for i = 1:length(fileList)
    try 
        ourGTFileName = fullfile(fileList(i).folder, fileList(i).name);
        ourGTImage = imread(ourGTFileName);
        ourGTImage = imresize(ourGTImage,inputSize(1:2));
        [label, scores] = classify(net,ourGTImage);
        [~,idx] = sort(scores,'descend');
        idx = idx(5:-1:1);
        classNamesGTTop = net.Layers(end).ClassNames(idx);
        scoresGTTop = scores(idx);
        
        % for now we just output the top classes for each image, but of
        % course would want to do something smart with them & scores
        disp(strcat("Classes for GT image: ", fullfile(fileList(i).folder, fileList(i).name)));
        classNamesGTTop % the top 5 possible classes

        % now calculate the same thing for the simulated image
        [fPath, fName, fExt] = fileparts(ourGTFileName);
        ourTestFileName = fullfile(fPath, outputSubFolder, strcat(fName, ".png"));

        ourTestImage = imread(ourTestFileName);
        ourTestImage = imresize(ourTestImage,inputSize(1:2));
        [label, scores] = classify(net,ourTestImage);
        [~,idx] = sort(scores,'descend');
        idx = idx(5:-1:1);
        classNamesTestTop = net.Layers(end).ClassNames(idx);
        scoresTestTop = scores(idx);
        
        % for now we just output the top classes for each image, but of
        % course would want to do something smart with them & scores
        disp(strcat("Classes for our Simulated Test image: ", ourTestFileName));
        classNamesTestTop % the top 5 possible classes
        
        imageScore = length(find(ismember(classNamesGTTop, classNamesTestTop)));
        totalScore = totalScore + imageScore;
        disp(strcat("Image Matching Score: ", string(imageScore)));
        
    catch
        warning("boring?");
    end
    
end 

disp(strcat("Total score for: ", string(length(fileList)), " images is: ", string(totalScore)));
