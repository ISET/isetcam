function sceneSetEditsAndButtons(handles)
% Fill scene window fields based on the current scene information
%
%    sceneSetEditsAndButtons(handles)
%
% Fill the fields  the current scene information, including editdistance,
% editluminance, FOV, etc.  
%
% Display of the image data is handled separately by sceneShowImage.
%
% Copyright ImagEval Consultants, LLC, 2003.


%% Use scene data to set boxes in window
scene = ieGetObject('SCENE');

if isempty(scene)
    % No scene, so set empty
    str = [];
    set(handles.editDistance,'String',str);
    set(handles.editLuminance,'String',str);
    set(handles.editHorFOV,'String',str);
    
    % Select scene popup contents
    set(handles.popupSelectScene,...
        'String','No Scenes',...
        'Value',1);
else
    if ~isfield(scene,'depthMap')
        % Text boxes on right: we should reduce the fields in SCENE.
        set(handles.editDistance,'Visible','on');
        set(handles.txtDist,'Visible','on');
        set(handles.txtM,'Visible','on');
        set(handles.editDistance,'String',num2str(sceneGet(scene,'distance')));
    else
        % There is a depth map, so don't show the distance box.
        set(handles.editDistance,'Visible','off');
        set(handles.txtDist,'Visible','off');
        set(handles.txtM,'Visible','off');
    end
    
    meanL = sceneGet(scene,'mean luminance');
   
    set(handles.editLuminance,'String',sprintf('%.1f',meanL));
    set(handles.editHorFOV,'String',sprintf('%.2f',sceneGet(scene,'fov')));
    
    % Select scene popup contents
    set(handles.popupSelectScene,...
        'String',vcGetObjectNames('SCENE'),...
        'Value',vcGetSelectedObject('SCENE'));    
end

%% Description box on upper right
set(handles.txtSceneDescription,'String',sceneDescription(scene));

%% Set the gamma and displayFlag from the scene window.
figNum = vcSelectFigure('SCENE'); 
figure(figNum);
displayFlag = get(handles.popupDisplay,'Value');
gam = str2double(get(handles.editGamma,'String'));
sceneShowImage(scene,displayFlag,gam);

%% Refresh the font size in case that was changed
fig = ieSessionGet('scene window');
ieFontSizeSet(fig,0);

return
