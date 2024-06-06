function selectedObjs = imageMultiview(objType, selectedObjs, singlewindow, app)
% Display multiple images of selected GUI objects
%
% Syntax:
%   selectedObjs = imageMultiview(objType, [selectedObjs], [singlewindow], [app])
%
% Description:
%    Compares rendered images side by side, rather than flipping
%    through them in the GUI window.
%
% Inputs:
%    objType      - Which window (scene, opticalimage, or vcimage).
%                   Sensor is not supported.
%
% Optional
%    selectedObjs - Indices of the selected objects, e.g.,
%                   [1 3 5]. Default is all of the objects in ObjList.
%    singlewindow - Plot all of the images in the same window in subplots
%                   (true), or in different windows (false). Default is
%                   false.
%
% Outputs:
%    selectedObjs - The selected objects
%
% Optional key/value pairs:
%    None.
%
% ieExamplesPrint('imageMultiview');
%
% See Also:
%    imageMontage
%

% History:
%    xx/xx/13       Copyright Imageval Consultants, LLC, 2013
%    12/07/17  jnm  Formatting
%    12/26/17   BW  Removed vcimage/imageGet. Fixed examples.
%    01/26/18  jnm  Formatting update to match Wiki.
%
% Examples:
%{
    scene = sceneCreate; ieAddObject(scene);
    scene = sceneCreate('macbeth tungsten');
    ieAddObject(scene);
    objType = 'scene';
    imageMultiview(objType,[1 2],true);
    imageMultiview(objType,[1 2]);
%}

if notDefined('objType'), error('Object type required.'); end
if notDefined('singlewindow'), singlewindow = false; end

% Allows some aliases to be used
objType = vcEquivalentObjtype(objType);

% Get the objects
[objList, nObj] = vcGetObjects(objType);
if  isempty(objList)
    fprintf('No objects of type %s\n', objType);
    return;
end

% Show a subset or all
if notDefined('selectedObjs')
    lst = cell(1, nObj);
    for ii = 1:nObj, lst{ii} = objList{ii}.name; end
    selectedObjs = listdlg('ListString', lst);
end

% Set up the subplots or multiple window conditions
if singlewindow
    if numel(selectedObjs) > 3
        rWin = ceil(sqrt(numel(selectedObjs)));
        cWin = rWin;
        fType = 'upper left';
    else
        rWin = numel(selectedObjs);
        cWin = 1;
        fType = 'tall';
    end
else
    rWin = [];
    fType = 'upper left';
end

% Maybe we will have other rendering options in the future
if notDefined('app'), gam = 1;
else,                 gam = str2double(app.editGamma.Value);
end

subCount = 1;  % Which subplot are we in

%% This is the display loop
for ii = selectedObjs
    
    if (~singlewindow || (subCount == 1 && singlewindow))
        % If not a single window, or if the first time through and
        % single window, open a window;
        thisFig = ieNewGraphWin([], fType);
    end
    
    if singlewindow
        % If we are in a single window, set the subplot.
        subplot(rWin, cWin, subCount);
        subCount = subCount + 1;
    end

    switch objType
        case 'SCENE'
            renderFlag = sceneGet(objList{ii},'render flag index');
            sceneShowImage(objList{ii}, renderFlag, gam, thisFig);
            t = sprintf('Scene %d - %s', ii, ...
                sceneGet(objList{ii}, 'name'));
            
        case 'OPTICALIMAGE'
            oiW.figure1 = thisFig;  % Not sure why this is here.
            renderFlag = sceneGet(objList{ii},'render flag index');
            oiShowImage(objList{ii}, renderFlag, gam,oiW);
            t =sprintf('OI %d - %s', ii, oiGet(objList{ii}, 'name'));
            
            % No sensor case?

        case 'VCIMAGE'
            %  IP case doesn't have the same rendering, right?
            img = imageShowImage(objList{ii},gam,true,0);
            t =sprintf('IP %d - %s', ii, ipGet(objList{ii}, 'name'));
            image(img); axis image; axis off;
            
        otherwise
            error('Unsupported object type %s\n', objType);
    end
    
    % Label the image or window
    if singlewindow, title(t); else, set(gcf, 'name', t); end
    
end

end