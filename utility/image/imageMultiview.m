function selectedObjs = imageMultiview(objType, selectedObjs, singlewindow)
% Display multiple images of selected GUI objects
%
%  selectedObjs = imageMultiview(objType, selectedObjs, singlewindow)
%
% This routine lets the user compare the images side by side, rather than
% flipping through them in the GUI window.
%
% objType:       Which window (scene, oi, sensor, or vcimage)
% selectedObjs:  List of the selected object numbers, e.g., [1 3 5]
% singlewindow:  Put the images in subplots of a single figure (true) or in
%                different figures (default = false);
%
% See also: imageMontage
%
% Example:
%  objType = 'scene';
%  imageMultiview(objType);
%
%  selectedObjs = [1 6];
%  imageMultiview(objType,whichObj);
%
%  objType = 'vcimage';
%  selectedObjs = [2 3 5];
%  imageMultiview(objType,whichObj, true);
%
% Copyright Imageval Consultants, LLC, 2013

%%
if ieNotDefined('objType'), error('Object type required.'); end
if ieNotDefined('singlewindow'), singlewindow = false; end

% Allows some aliases to be used
objType = vcEquivalentObjtype(objType);

% Get the objects
[objList, nObj] = vcGetObjects(objType);
if  isempty(objList)
    fprintf('No objects of type %s\n',objType);
    return;
end

% Show a subset or all
if ieNotDefined('selectedObjs')
    lst = cell(1,nObj);
    for ii=1:nObj, lst{ii} = objList{ii}.name; end
    selectedObjs = listdlg('ListString',lst);
end

% Adjust for the selected objects only
nObj = length(selectedObjs);

% Set up the subplots or multiple window conditions
if singlewindow
    if nObj > 3
        rWin = ceil(sqrt(nObj));
        cWin = ceil(nObj/rWin); fType = 'upper left';
    else
        rWin = nObj; cWin = 1; fType = 'tall';
    end
else,  rWin = []; fType = 'upper left';
end
subCount = 1; % Which subplot are we in

%% This is the display loop
for ii=1:numel(selectedObjs)
    if (~singlewindow || subCount == 1), ieNewGraphWin([],fType); end
    if singlewindow
        subplot(rWin,cWin,subCount); subCount = subCount+1; 
    end
    switch objType
        case 'SCENE'
            gam = sceneGet(objList{ii},'gamma');      % gamma in the window!
            % Use the same display method, but do not show in the scene
            % window.  The -1 makes that happen
            displayFlag = -1*abs(sceneGet(objList{ii},'render flag index')); % RGB, HDR, Gray
            if isempty(displayFlag), displayFlag = -1; end
            rgb = sceneShowImage(objList{ii},displayFlag,gam);
            imshow(rgb); 
            t = sprintf('Scene %d - %s',ii,sceneGet(objList{ii},'name'));
            
        case 'OPTICALIMAGE'
            gam = oiGet(objList{ii},'gamma');
            displayFlag = -1*abs(oiGet(objList{ii},'render flag index')); % RGB, HDR, Gray
            if isempty(displayFlag), displayFlag = -1; end
            rgb = oiShowImage(objList{ii},displayFlag,gam);
            imshow(rgb);
            t =sprintf('OI %d - %s',ii,oiGet(objList{ii},'name'));
            
        case 'ISA'
            gam = ieSessionGet('sensor gamma');      % gamma in the window!
            scaleMax = true; showFig = false;
            img = sensorShowImage(objList{ii},gam,scaleMax,showFig);
            imshow(img); 
            t = sprintf('Sensor %d - %s',ii,sensorGet(objList{ii},'name'));
            
        case 'VCIMAGE'
            ip = objList{ii};
            gam = ipGet(ip,'gamma');      % gamma in the window!
            trueSizeFlag = []; showFig = false;
            img = imageShowImage(objList{ii},gam,trueSizeFlag,showFig);
            imshow(img);
            t = sprintf('VCI %d - %s',ii,ipGet(ip,'name'));
            
        otherwise
            error('Unsupported object type %s\n', objType);
    end
    
    % Label the image or window
    if singlewindow,      title(t)
    else,                 set(gcf,'name',t);
    end
    
end


end


