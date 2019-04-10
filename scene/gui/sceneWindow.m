function varargout = sceneWindow(varargin)
% Graphical user interface to manage the ISET SCENE properties.
%
%     varargout = sceneWindow(varargin)
%
%      SCENEWINDOW, by itself, creates a new SCENEWINDOW or raises the existing
%      singleton.
%
%      H = SCENEWINDOW returns the handle to a new SCENEWINDOW or the handle to
%      the existing singleton*.
%
%      H = SCENEWINDOW(scene) adds the scene to the database and then opens
%      the window.  Equivalent to ieAddObject(scene); sceneWindow;
%
%      SCENEWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCENEWINDOW.M with the given input arguments.
%
%      SCENEWINDOW('Property','Value',...) creates a new SCENEWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sceneWindow_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sceneWindow_OpeningFcn via varargin.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Last Modified by GUIDE v2.5 16-Nov-2016 21:15:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @sceneWindow_OpeningFcn, ...
    'gui_OutputFcn',  @sceneWindow_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before sceneWindow is made visible.
function sceneWindow_OpeningFcn(hObject, eventdata, handles, varargin)

% Permits calling as sceneWindow(scene);
if ~isempty(varargin) ...
        && isstruct(varargin{1}) ...
        && strcmp(varargin{1}.type,'scene')
    ieAddObject(varargin{1});
end

sceneOpen(hObject,eventdata,handles) 
sceneRefresh(hObject, eventdata, handles);

ISETprefs = getpref('ISET');
if isfield(ISETprefs,'wPos')
    wPos = ISETprefs.wPos;
    if ~isempty(wPos{2}), set(hObject,'Position',wPos{2}); end
end

return

% --- Outputs from this function are returned to the command line.
function varargout = sceneWindow_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

return

% --- Executes during object creation, after setting all properties.
function editDistance_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return

% --------------------------------------------------------------------
function editDistance_Callback(hObject, eventdata, handles)

% Should be set(SCENE,'editDistance',value);
[scene,val] = vcGetObject('SCENE');
if ~isempty(scene)
    scene.distance = str2double(get(hObject,'String'));
    scene.consistency = 0;
    vcReplaceObject(scene,val);
end
sceneRefresh(hObject, eventdata, handles);
return;

% --- Executes during object creation, after setting all properties.
function editLuminance_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% --------------------------------------------------------------------
function editLuminance_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');
if ~isempty(scene)
    meanL = str2double(get(hObject,'String'));
    scene = sceneAdjustLuminance(scene,meanL);
    vcReplaceObject(scene,val);
end
sceneRefresh(hObject, eventdata, handles);

return;


% --- Executes during object creation, after setting all properties.
function editHorFOV_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
function editHorFOV_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');
if ~isempty(scene)
    scene = sceneSet(scene,'fov',str2double(get(hObject,'String')));
    vcReplaceObject(scene,val);
end
sceneRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function popupSelectScene_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popupSelectScene.
function popupSelectScene_Callback(hObject, eventdata, handles)

contents = get(hObject,'String');
if strcmp(contents,'No Scene')
    return;
else
    val = get(hObject,'Value');
    vcSetSelectedObject('SCENE',val);
end
sceneRefresh(hObject, eventdata, handles);

return;

% --- Executes on button press in btnPrev.
function btnPrev_Callback(hObject, eventdata, handles)
% Push button with the - on the left of the selection popup
s  = ieSessionGet('selected','scene');
nS = ieSessionGet('nobjects','scene');
s = min(s - 1,nS);
s = max(s,1);
vcSetSelectedObject('scene',s);
sceneRefresh(hObject, eventdata, handles);
return;

% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% Push button with the + on the right of the selection popup
s  = ieSessionGet('selected','scene');
nS = ieSessionGet('nobjects','scene');
s = min(s + 1,nS);
s = max(s,1);
vcSetSelectedObject('scene',s);
sceneRefresh(hObject, eventdata, handles);
return;



% --- Executes during object creation, after setting all properties.
function editRow_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
function editRow_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');
scene.nRows = str2double(get(hObject,'String'));
vcReplaceObject(scene,val);

return;


% --- Executes during object creation, after setting all properties.
function editCol_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;


% --------------------------------------------------------------------
function editGamma_Callback(hObject, eventdata, handles)

% We store the display gamma value in the window without ever putting it
% into the scene structure.  We could ... but we don't.  Maybe we should.
sceneRefresh(hObject,eventdata,handles);


return;

% --------------------------------------------------------------------
function menuEditScaleSize_Callback(hObject, eventdata, handles)
% hObject    handle to menuEditScaleSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

scene = vcGetObject('scene');

% Call GUI to set neﬂw row and col dimensions.
sFactor = ieReadNumber('Spatial scale',2,'%.0f');
if isempty(sFactor), disp('User canceled'); return; end

% rc = sceneSetRowCol;
figure(gcbf);  % Return control to this figure.
scene = sceneInterpolate(scene,sFactor);
vcReplaceObject(scene);
sceneRefresh(hObject, eventdata, handles);

return

% --- Executes on button press in btnInterpolate.
function btnInterpolate_Callback(hObject, eventdata, handles)
% btnInterp - eliminate 
% 
% Read the data in the row and col edit fields.  Re-sample the current data
% in the photons field so that it has the desired number of rows and
% columns.
% 
%
[val,scene] = vcGetSelectedObject('SCENE');
sz = sceneGet(scene,'size');
r0 = sz(1); c0 = sz(2);

% Call GUI to set new row and col dimensions.
rc = sceneSetRowCol;
figure(gcbf);  % Return control to this figure.
newRow = rc(1); newCol = rc(2);
% These are the desired values determined by sceneSetRowCol

% Find the appropriate scale factor.
sFactor = [newRow/r0, newCol/c0];
scene = sceneInterpolate(scene,sFactor);
vcReplaceObject(scene,val);
sceneRefresh(hObject, eventdata, handles);

return;


%%%%%%%%%%%%%%%%%%%% Menus are controlled below here %%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
return

% --------------------------------------------------------------------
function EditMenu_Callback(hObject, eventdata, handles)
return

% --------------------------------------------------------------------
function PlotMenu_Callback(hObject, eventdata, handles)
return

% --------------------------------------------------------------------
function PlotLuminance_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');

% Check that the luminance field has been calculated
if ~checkfields(scene,'data','luminance')
    [lum, meanL] = sceneCalculateLuminance(scene);
    scene = sceneSet(scene,'luminance',lum);
    scene = sceneSet(scene,'meanLuminance',meanL);
    vcReplaceAndSelectObject(scene,val);
end

% Plots log10 or linear luminance
% Should be replaced by scenePlot call
scenePlot(scene,'luminance mesh log');

return;

% --------------------------------------------------------------------
function menPlotLumLin_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');

if ~checkfields(scene,'data','luminance')
    [scene.data.luminance, scene.data.meanL] = sceneCalculateLuminance(scene);
    vcReplaceAndSelectObject(scene,val);
end

% Plots log10 or linear luminance as a mesh.
% Should be replaced by scenePlot call
scenePlot(scene,'luminance mesh linear');

return;

% --------------------------------------------------------------------
function editGamma_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --------------------------------------------------------------------
function popupDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
% This is what Matlab does
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% I changed it to be like the others.  Not sure what's right.  Check on
% Ubuntu some day.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return

% --------------------------------------------------------------------
function popupDisplay_Callback(hObject, eventdata, handles)
% hObject    handle to popupDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupDisplay

% We read the state of this popup inside of sceneSetEditsAndButtons.  The
% value it has (contents{get(hObject,'Value')}) determines the displayFlag
% value.  1 means Standard RGB (the default) and we will be adding other
% display modes for NIR/SWIR and so forth over time.
sceneRefresh(hObject, eventdata, handles);
return


% --------------------------------------------------------------------
function plotRadiance_Callback(hObject, eventdata, handles)
% Plot | Radiance (Quanta)
scenePlot(vcGetObject('scene'),'radiance photons roi');
return

% --------------------------------------------------------------------
function menuPlotRadianceE_Callback(hObject, eventdata, handles)
% Plot | Radiance (Energy)
scenePlot(vcGetObject('scene'),'radiance energy roi');
return

% --------------------------------------------------------------------
function menuPlotReflectance_Callback(hObject, eventdata, handles)
% Plot | Reflectance
scenePlot(vcGetObject('scene'),'reflectance');
return

% --------------------------------------------------------------------
function menuPlotIlluminant_Callback(hObject, eventdata, handles)
% Plot | Illuminant (energy)
scenePlot(vcGetObject('scene'),'illuminant energy roi');
return

% --------------------------------------------------------------------
function menuPlotIllumPhotons_Callback(hObject, eventdata, handles)
% Plot | Illuminant (photons)
scenePlot(vcGetObject('scene'),'illuminant photons roi');
return

% --------------------------------------------------------------------
function menuPlotIlluminantImage_Callback(hObject, eventdata, handles)
%  Plot | Illuminant image
scenePlot(vcGetObject('scene'),'illuminant image');
return

% --------------------------------------------------------------------
function menuPlotIlluminantComment_Callback(hObject, eventdata, handles)
% Deprecated - Plot | Illuminant comment
scene = vcGetObject('SCENE');
disp(sceneGet(scene,'illuminantComment'));
return

% --------------------------------------------------------------------
function menuPlotRadImGrid_Callback(hObject, eventdata, handles)
% Plot | Radiance image (grid)
scenePlot(vcGetObject('SCENE'), 'radianceimagewithgrid');
return

% --------------------------------------------------------------------
function menuPlotWavebandImage_Callback(hObject, eventdata, handles)
% Plot | Waveband image
scenePlot(vcGetObject('SCENE'), 'radiance waveband image');
return

% --------------------------------------------------------------------
function menuPlotImTrueSize_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% Plot | Image (RGB)
% Shows the image in the window in a separate window, with just the image
% at true size. The spatial scale is 1 to 1 with the data (true size). 

% Get the necessary display data
scene = vcGetObject('scene');
displayFlag = get(handles.popupDisplay,'Value');
gam = str2double(get(handles.editGamma,'String'));

% Call same routine as shows the image in the GUI, but put the image in a
% new graph window.  The image displays at true size.  To change the size,
% you can call truesize(gcf,[row,col])
vcNewGraphWin;
sceneShowImage(scene,displayFlag,gam);

return

% --------------------------------------------------------------------
function menuPlotMultipleRGB_Callback(hObject, eventdata, handles)
%Plot | Multiple image (RGB)
% Multiple figures with images of the session scene data
imageMultiview('scene');
return;

% --------------------------------------------------------------------
function menuPlotNewGraphWindow_Callback(hObject, eventdata, handles)
% Plot | New Graph Window
vcNewGraphWin;
return

% --------------------------------------------------------------------
function menuFileSave_Callback(hObject, eventdata, handles)
[val,scene] = vcGetSelectedObject('SCENE');
vcSaveObject(scene);
return

% --------------------------------------------------------------------
function menuFileLoad_Callback(hObject, eventdata, handles)
vcImportObject('SCENE');
sceneRefresh(hObject, eventdata, handles);
return

% --------------------------------------------------------------------
function menuSaveImage_Callback(hObject, eventdata, handles)
% File | Save (.png)
gam = str2double(get(handles.editGamma,'String'));
[val, scene] = vcGetSelectedObject('SCENE');
sceneSaveImage(scene,[],gam);
return;

% --------------------------------------------------------------------
function menuFileClose_Callback(hObject, eventdata, handles)
sceneClose;
return;

% --------------------------------------------------------------------
function menuCopyScene_Callback(hObject, eventdata, handles)
[val,scene] = vcGetSelectedObject('scene');

newName = ieReadString('New scene name','new-scene');
if isempty(newName),  return;
else                  scene = sceneSet(scene,'name',newName);
end

ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);  
return;

% --------------------------------------------------------------------
function menuAn_Callback(hObject, eventdata, handles)
% Menu->Analyze callback
return;

% --------------------------------------------------------------------
function menuAnalyzeLine_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnalyzeLineH_Callback(hObject, eventdata, handles)
scenePlot(vcGetObject('SCENE'),'luminance hline');
return;

% --------------------------------------------------------------------
function menuAnalyzeLineV_Callback(hObject, eventdata, handles)
scenePlot(vcGetObject('SCENE'),'luminance vline');
return;

% --------------------------------------------------------------------
function menuAnalyzeLFFTv_Callback(hObject, eventdata, handles)
scenePlot(vcGetObject('SCENE'),'luminance fft vline');
return;

% --------------------------------------------------------------------
function menuAnalyzeLFFTH_Callback(hObject, eventdata, handles)
scenePlot(vcGetObject('SCENE'),'luminance fft hline');
return;

% --------------------------------------------------------------------
function menuAnalyzeLineWave_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnalyzeLWH_Callback(hObject, eventdata, handles)
scene = vcGetObject('SCENE'); 
scenePlot(scene,'radiance hline');
return;

% --------------------------------------------------------------------
function menuAnalyzeLWV_Callback(hObject, eventdata, handles)
scene = vcGetObject('SCENE'); 
scenePlot(scene,'radiance vline');
return;

% --------------------------------------------------------------------
function menuAnalyzeROI_Callback(hObject, eventdata, handles)
% Analyze | ROI
return;

% --------------------------------------------------------------------
function menuLuminance_Callback(hObject, eventdata, handles)
% Analyze | ROI Summary | Luminance
scene = vcGetObject('scene');
scenePlot(scene,'luminance roi');
return;


% --------------------------------------------------------------------
function menuAnIlluminantCCT_Callback(hObject, eventdata, handles)
% Analyze | Illuminant CCT

scene = vcGetObject('scene');
wave = sceneGet(scene,'wave');
spd = sceneGet(scene,'illuminant energy');

% This size makes the title visible
str = sprintf('       ---------  Correlated color temp %.0f  ---------',spd2cct(wave,spd));
msgbox(str,'Illuminant');

return

% --------------------------------------------------------------------
function menuAnalyzeChromaticity_Callback(hObject, eventdata, handles)
scene = vcGetObject('SCENE');
scenePlot(scene,'chromaticity roi');
return

% --------------------------------------------------------------------
function menuPlotDepth_Callback(hObject, eventdata, handles)
% Plot | Depth Map

scene = vcGetObject('scene');

if isempty(sceneGet(scene,'depth map'))
    handles = ieSessionGet('sceneimagehandle');
    ieInWindowMessage('No depth map data.',handles,3);
else
    scenePlot(scene,'depth map');
end
return

% --------------------------------------------------------------------
function menuPlotDepthContour_Callback(hObject, eventdata, handles)
% Plot | Depth Contour

scene = vcGetObject('scene');
if isempty(oiGet(scene,'depth map'))
    handles = ieSessionGet('scene handle');
    ieInWindowMessage('No depth data.',handles,3);
else
    scenePlot(scene,'depth map contour');
end

return

% --- Executes during object creation, after setting all properties.
function popupImScale_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popupImScale.
function popupImScale_Callback(hObject, eventdata, handles)
% Rescale the scene data spatially.  To be eliminated 

contents = get(hObject,'String');
str = contents{get(hObject,'Value')};
switch lower(str)
    case 'x 1'
        return;
    case 'x 2'
        sFactor = 2;
    case 'x 4'
        sFactor = 4;
    case 'x 1/2'
        sFactor = 1/2;
    case 'x 1/4'
        sFactor = 1/4;
    otherwise
        error('Unknown scale factor');
end
[val,scene] = vcGetSelectedObject('SCENE');
scene = sceneInterpolate(scene,sFactor);
vcReplaceObject(scene,val);
sceneRefresh(hObject, eventdata, handles);

return;


% --------------------------------------------------------------------
function menuFileRef_Callback(hObject, eventdata, handles)
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function sceneRefresh(hObject, eventdata, handles)
% Refresh callback.
sceneSetEditsAndButtons(handles)
return;

% --------------------------------------------------------------------
function menuScene_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSceneMacbeth_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSceneMacbethC_Callback(hObject, eventdata, handles)
% val = vcNewObjectValue('SCENE');
scene =  sceneCreate('macbethC');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneMacbethTungsten_Callback(hObject, eventdata, handles)

% val = vcNewObjectValue('SCENE');
scene =  sceneCreate('macbethTungsten');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSceneMacbethD50_Callback(hObject, eventdata, handles)

% val = vcNewObjectValue('SCENE');
scene =  sceneCreate('macbethD50');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSceneMacbethFluorescent_Callback(hObject, eventdata, handles)

% val = vcNewObjectValue('SCENE');
scene =  sceneCreate('macbethFluorescent');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSceneMacbethD65_Callback(hObject, eventdata, handles)

% val = vcNewObjectValue('SCENE');
scene =  sceneCreate('macbethD65');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSceneMacbethVisIR_Callback(hObject, eventdata, handles)
% Scene | Macbeth Charts | Visible-InfraRed

wave = ieReadNumber('Enter waves','380:4:1068','%.0f');
scene =  sceneCreate('macbethEE_IR',[],wave);
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSceneLstar_Callback(hObject, eventdata, handles)
% Create vertical bars with equal L* steps

scene =  sceneCreate('lstar');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return

% --------------------------------------------------------------------
function menuSceneFile_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSceneMultiSpec_Callback(hObject, eventdata, handles)
% Scene | Choose | Multispectral 
%
scene = sceneFromFile([],'multispectral');
if isempty(scene), return; end
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneChooseRGB_Callback(hObject, eventdata, handles)
% Scene | Choose | RGB
%
scene = sceneFromFile([],'rgb');
if isempty(scene), return; end
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;


% --------------------------------------------------------------------
function menuFileChooseFileMono_Callback(hObject, eventdata, handles)
% Scene | Choose | Monochrome
%
scene = sceneFromFile([],'monochrome');
if isempty(scene), return; end
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;


% --------------------------------------------------------------------
function menuScenesTest_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSceneMackay_Callback(hObject, eventdata, handles)

val = vcNewObjectValue('SCENE');
scene = sceneCreate('mackay');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuScenesSweep_Callback(hObject, eventdata, handles)
val = vcNewObjectValue('SCENE');
scene = sceneCreate('sweep');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneSlantedBar_Callback(hObject, eventdata, handles)
scene = sceneCreate('slantedBar');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

function menuSceneZonePlate_Callback(hObject, eventdata, handles)
scene = sceneCreate('zonePlate');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneFreqOrient_Callback(hObject, eventdata, handles)
scene = sceneCreate('freqorientpattern');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneCheckerboard_Callback(hObject, eventdata, handles)
scene = sceneCreate('checkerBoard');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuScenePointArray_Callback(hObject, eventdata, handles)
% Scene | Patterns | PointArray (D65)

scene = sceneCreate('pointarray',[],[],'d65');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;


% --------------------------------------------------------------------
function menuSceneGridLines_Callback(hObject, eventdata, handles)
% Scene | Patterns | PointArray (D65)

scene = sceneCreate('GridLines',[],[],'d65');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

function menuSceneRadialLines_Callback(hObject, eventdata, handles)
scene = sceneCreate('radialLines');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneNoise_Callback(hObject, eventdata, handles)

val = vcNewObjectValue('SCENE');
scene = sceneCreate('noise');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuHarmonic_Callback(hObject, eventdata, handles)

val = vcNewObjectValue('SCENE');
scene = sceneCreate('harmonic');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSceneTestLine_Callback(hObject, eventdata, handles)
% Scene | Patterns | Line (D65 vert) 
% Impulse with a D65 spectral curve
%  

[val,scene] = vcGetSelectedObject('SCENE');
scene = sceneCreate('impulse1dd65',256);
ieAddObject(scene);
sceneRefresh(hObject,eventdata,handles);

return;

% --------------------------------------------------------------------
function menuScenesRamp_Callback(hObject, eventdata, handles)

val = vcNewObjectValue('SCENE');
scene = sceneCreate('ramp');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuUniform_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSceneUniformPhoton_Callback(hObject, eventdata, handles)
% Scene | Uniform | Equal Photon
val = vcNewObjectValue('SCENE');
scene = sceneCreate('uniformequalphoton');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;


% --------------------------------------------------------------------
function menuSceneUniformEE_Callback(hObject, eventdata, handles)
% Scene | Uniform | Equal Energy
val = vcNewObjectValue('SCENE');
scene = sceneCreate('uniformee');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneUniformEESpecify_Callback(hObject, eventdata, handles)
% Scene | Uniform | Equal Energy (specify)
sz = 32;  % Spatial samples
wavelength = ieReadNumber('Enter waves','380:4:1068','%.0f');
if isempty(wavelength), disp('User canceled.'); return; end

scene = sceneCreate('uniformeeSpecify',sz,wavelength);
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSceneUniformBBspecify_Callback(hObject, eventdata, handles)
% Scene | Uniform | Blackbody (specify)
% sz = 32;  % Spatial samples

% Read the size 
prompt = {'Image size','Color Temp','Wave (nm)'};
def = {'32','5000','400:700'};
answer = inputdlg(prompt,'Uniform blackbody',1,def);
if isempty(answer), disp('User canceled'); return;
else
    sz = str2double(answer{1});
    cTemp = str2double(answer{2});
    wave = eval(answer{3});
end

scene = sceneCreate('uniformbb',sz,cTemp,wave);
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuUniformD65_Callback(hObject, eventdata, handles)
% Scene | Uniform | D65
val = vcNewObjectValue('SCENE');
scene = sceneCreate('uniformD65');
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditNewScene_Callback(hObject, eventdata, handles)
scene = sceneCreate;
ieAddObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditClearWindow_Callback(hObject, eventdata, handles)
ieInWindowMessage('',ieSessionGet('sceneWindowHandles'),[]);
return

% --------------------------------------------------------------------
function menuEditFontSize_Callback(hObject, eventdata, handles)
% Edit | Change Font Size

ieFontSizeSet(handles.figure1);

return;

% --------------------------------------------------------------------
function editCrop_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');
[scene,rect] = sceneCrop(scene);

illF        = sceneGet(scene,'illuminant format');
switch illF
    case 'spatial spectral'
        % Get the illuminant photons out and put them in the main photon
        % slot.
        illuminantSPD = sceneGet(scene,'illuminant photons');
        sceneI = sceneSet(scene,'photons',illuminantSPD);
        
        % Crop them
        sceneI = sceneCrop(sceneI,rect);
        illuminantSPD = sceneGet(sceneI,'photons');
        
        % Stuff them back into the illuminant slot
        scene = sceneSet(scene,'illuminant photons',illuminantSPD);
    otherwise
end

vcReplaceObject(scene,val);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditSceneName_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');

newName = ieReadString('New scene name','new-scene');
if isempty(newName),  return;
else    scene = sceneSet(scene,'name',newName);
end

vcReplaceAndSelectObject(scene,val)
sceneRefresh(hObject,eventdata,handles);

return;

% --------------------------------------------------------------------
function menuEditDelete_Callback(hObject, eventdata, handles)
% Edit | Delete Current Scene
vcDeleteSelectedObject('SCENE');
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditDeleteSome_Callback(hObject, eventdata, handles)
% Edit | Delete Some Scenes
vcDeleteSomeObjects('scene');
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditTransform_Callback(hObject, eventdata, handles)
% hObject    handle to menuEditTransform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
return;

% --------------------------------------------------------------------
function menuEditTranspose_Callback(hObject, eventdata, handles)
% Edit | Transform | Transpose
[val,scene] = vcGetSelectedObject('SCENE');
photons     = imageTranspose(sceneGet(scene,'photons'));
scene       = sceneSet(scene,'photons',photons);
illF        = sceneGet(scene,'illuminant format');
switch illF
    case 'spatial spectral'
        photons     = imageTranspose(sceneGet(scene,'illuminant photons'),'leftRight');
        scene       = sceneSet(scene,'illuminant photons',photons);
    otherwise
end
vcReplaceObject(scene,val); sceneWindow();
return;

% --------------------------------------------------------------------
function menuEditRotate_Callback(hObject, eventdata, handles)
% Edit | Transform | Rotate
return;

% --------------------------------------------------------------------
function menuEditFlip_Callback(hObject, eventdata, handles)
% Edit | Transform | Flip
return;

% --------------------------------------------------------------------
function menuEditFlipHorizontal_Callback(hObject, eventdata, handles)
% Edit | Transform | Flip | Horizontal
[val,scene] = vcGetSelectedObject('SCENE');
photons     = imageFlip(sceneGet(scene,'photons'),'leftRight');
scene       = sceneSet(scene,'photons',photons);
illF        = sceneGet(scene,'illuminant format');
switch illF
    case 'spatial spectral'
        photons     = imageFlip(sceneGet(scene,'illuminant photons'),'leftRight');
        scene       = sceneSet(scene,'illuminant photons',photons);
    otherwise
end

vcReplaceObject(scene,val); sceneWindow();
return;

% --------------------------------------------------------------------
function menuEditFlipVertical_Callback(hObject, eventdata, handles)
% Edit | Transform | Flip | Vertical
[val,scene] = vcGetSelectedObject('SCENE');
photons     = imageFlip(sceneGet(scene,'photons'),'upDown');
scene       = sceneSet(scene,'photons',photons);

illF        = sceneGet(scene,'illuminant format');
switch illF
    case 'spatial spectral'
        photons     = imageFlip(sceneGet(scene,'illuminant photons'),'upDown');
        scene       = sceneSet(scene,'illuminant photons',photons);
    otherwise
end
vcReplaceObject(scene,val); sceneWindow();
return;

% --------------------------------------------------------------------
function menuEditRotCW_Callback(hObject, eventdata, handles)
% Edit | Transform | Rotate | ClockWise
[val,scene] = vcGetSelectedObject('SCENE');
photons     = imageRotate(sceneGet(scene,'photons'),'cw');
scene       = sceneSet(scene,'photons',photons);

illF        = sceneGet(scene,'illuminant format');
switch illF
    case 'spatial spectral'
        photons     = imageRotate(sceneGet(scene,'illuminant photons'),'cw');
        scene       = sceneSet(scene,'illuminant photons',photons);
    otherwise
end
vcReplaceObject(scene,val); sceneWindow();
return;

% --------------------------------------------------------------------
function menuEditRotCCW_Callback(hObject, eventdata, handles)
% Edit | Transform | Rotate | CounterClockWise
[val,scene] = vcGetSelectedObject('SCENE');
photons     = imageRotate(sceneGet(scene,'photons'),'ccw');
scene       = sceneSet(scene,'photons',photons);

illF        = sceneGet(scene,'illuminant format');
switch illF
    case 'spatial spectral'
        photons     = imageRotate(sceneGet(scene,'illuminant photons'),'ccw');
        scene       = sceneSet(scene,'illuminant photons',photons);
    otherwise
end
vcReplaceObject(scene,val); sceneWindow();
return;

% --------------------------------------------------------------------
function menuEditZoom_Callback(hObject, eventdata, handles)
zoom
return;

% --------------------------------------------------------------------
function menuEditViewer_Callback(hObject, eventdata, handles)
scene = vcGetSelectedObject('scene');
img = sceneGet(scene,'photons');
rgb = imageSPD(img,sceneGet(scene,'wavelength'));
ieViewer(rgb);

return;

% --------------------------------------------------------------------
function menuSpectral_Callback(hObject, eventdata, handles)
return;


% --------------------------------------------------------------------
function menuResampleWave_Callback(hObject, eventdata, handles)
[val,scene] = vcGetSelectedObject('SCENE');
scene = sceneInterpolateW(scene,[]);
vcReplaceObject(scene,val);
sceneRefresh(hObject,eventdata,handles);
return;


% --------------------------------------------------------------------
function menuEditAdjustMonochrome_Callback(hObject, eventdata, handles)
% Edit | Adjust SPD | Adjust Monochrome Wavelength

s = vcGetObject('scene');
w = sceneGet(s,'wavelength');
newWave = ieReadNumber('Enter new wavelength',w,'%.0f');
s = sceneSet(s,'wave',newWave);

vcReplaceAndSelectObject(s);
sceneRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSPDdiv_Callback(hObject, eventdata, handles)

[val,scene] = vcGetSelectedObject('SCENE');
scene = sceneSPDScale(scene,[],'divide');
vcReplaceObject(scene,val);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuSPDMult_Callback(hObject, eventdata, handles)
% Edit | Adjust SPD | Multiply
[val,scene] = vcGetSelectedObject('SCENE');
scene = sceneSPDScale(scene,[],'multiply');
vcReplaceObject(scene,val);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditSetIlluminant_Callback(hObject, eventdata, handles)
% Edit | Adjust SPD | Change Illuminant

scene = vcGetObject('scene');
scene = sceneAdjustIlluminant(scene);

% Replace and refresh
vcReplaceObject(scene);
sceneRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
return

% --------------------------------------------------------------------
% function menuHelpISETmanual_Callback(hObject, eventdata, handles)
% % Help | Iset manual (pdf)
% ieManualViewer('pdf','ISET_Manual');
% return

% --------------------------------------------------------------------
function menuHelpAppNotes_Callback(hObject, eventdata, handles)
% Help | Documentation (web)
ieManualViewer('imageval code');
return

% --------------------------------------------------------------------
function menuHelpSceneProgrammers_Callback(hObject, eventdata, handles)
% Help | Scene Programmers (online)
ieManualViewer('scene functions');
return

% --------------------------------------------------------------------
function menuHelpProgGuide_Callback(hObject, eventdata, handles)
% Help | ISET functions (online)
ieManualViewer('iset functions');
return


% --------------------------------------------------------------------
function menuFileRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



