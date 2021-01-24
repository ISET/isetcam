function selectedObjs = imageMultiview(objType, selectedObjs, singlewindow)
% Display multiple images of selected GUI objects
%
% Syntax:
%   selectedObjs = imageMultiview(objType, [selectedObjs], [singlewindow])
%
% Description:
%    This routine lets the user compare the images side by side, rather
%    than flipping through them in the GUI window.
%
%    Examples are located within the code. To access the examples, type
%    'edit imageMultiview.m' into the Command Window.
%
% Inputs:
%    objType      - Which window (scene, oi, or vcimage)
%    selectedObjs - (Optional) List of the selected object numbers, e.g., 
%                   [1 3 5]. Default is all of the objects in ObjList.
%    singlewindow - (Optional) Whether or not to plot all of the images in
%                   the same figure in subplots (true), or in different
%                   figures (false.) Default is false.
%
% Outputs:
%    selectedObjs - The selected objects
%
% Optional key/value pairs:
%    None.
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
    if nObj > 3
        rWin = ceil(sqrt(length(selectedObjs)));
        cWin = rWin;
        fType = 'upper left';
    else
        rWin = nObj;
        cWin = 1;
        fType = 'tall';
    end
else
    rWin = [];
    fType = 'upper left';
end
gam = 1;  % Figure out a rationale for this.
subCount = 1;  % Which subplot are we in

%% This is the display loop
for ii = selectedObjs
    if (~singlewindow || subCount == 1)
        % If not a single window, always call.  Or if the first time
        % through, call
        thisFig = ieNewGraphWin([], fType); 
    end
    if singlewindow
        % If we are in a single window, pick the subplot.
        subplot(rWin, cWin, subCount);
        subCount = subCount + 1;
    end
    switch objType
        case 'SCENE'
            sceneShowImage(objList{ii}, true, gam, thisFig);
            t = sprintf('Scene %d - %s', ii, ...
                sceneGet(objList{ii}, 'name'));

        case 'OPTICALIMAGE'
            oiShowImage(objList{ii}, true, gam);
            t =sprintf('OI %d - %s', ii, oiGet(objList{ii}, 'name'));

        case 'VCIMAGE'
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