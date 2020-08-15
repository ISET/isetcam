function sceneSetEditsAndButtons(app)
% Fill scene window fields based on the current scene information
%
%    sceneSetEditsAndButtons(app)
%
% Fill the app fields with the current scene information
%
% Display of the RGB representation of the spectral radiance data is
% handled separately by sceneShowImage.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   imageSPD, sceneWindow_App


%% Always choose the current scene for display

% Debugging.  Can go away when done.
% global vcSESSION
% vcSESSION.SELECTED.SCENE

% We also display the currently selected scene.
[scene, val] = ieGetObject('SCENE'); 

if isempty(scene)
    % No scene selected, so set empty
    app.editDistance.Value  = '';
    app.editLuminance.Value = '';
    app.editHorFOV.Value    = '';
    
    % Select scene popup content of 'New Scene', which is always there.
    app.popupSelectScene.Value = app.popupSelectScene.Items{1};
    
else
    if ~isfield(scene,'depthMap')
        % Text boxes on right: we should reduce the fields in SCENE.
        app.editDistance.Visible = 'on';
        app.txtDist.Visible      = 'on';
        app.txtM.Visible         = 'on';
        app.editDistance.Value   = num2str(sceneGet(scene,'distance'));
    else
        % There is a depth map, so don't show the distance box.
        app.editDistance.Visible = 'off';
        app.txtDist.Visible      = 'off';
        app.txtM.Visible         = 'off';
    end
    
   % Adjust the scene popupSelectScene contents
    sceneNames = vcGetObjectNames('scene',true);
    
    % 'New Scene' is always first.  We are having a problem if there are
    % two scenes with the same name.
    Items = cellMerge({'New Scene'}, sceneNames);
    
    % The scenes plus 'New Scene' should be the items in the popup
    app.popupSelectScene.Items = Items;   
    app.popupSelectScene.Value = Items{1 + val};
    
    meanL = sceneGet(scene,'mean luminance');    
    app.editLuminance.Value= sprintf('%.1f',meanL);
    
    app.editHorFOV.Value = sprintf('%.2f',sceneGet(scene,'fov'));
    
end

%% Description box on upper right
app.txtSceneDescription.Text = sceneDescription(scene);

%% Get the gamma and displayFlag from the scene window.

% Make sure we are looking at the scene figure.
figNum = vcSelectFigure('SCENE');  figure(figNum);

% Get the integer that indicates which element of the displayFlag is
% selected.
displayFlag = find(contains(app.popupDisplay.Items,app.popupDisplay.Value));

% Get the display gamma value from the app UI
gam = str2double(app.editGamma.Value);

% Display the RGB image in the sceneAxis of the scene window
sceneShowImage(scene,displayFlag,gam);

% Refresh the font size
ieFontSizeSet(app,0);

end
