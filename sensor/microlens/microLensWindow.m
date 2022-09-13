function varargout = microLensWindow(varargin)
% MICROLENSWINDOW M-file for microLensWindow.fig
%
%      Analyze the irradiance distribution at a pixel given specific
%      microlens parameters. The irradiance will depend on the properties
%      of (a) the taking/imaging lens and (b) the microlens. The analysis
%      includes various properties, including the function of chief ray
%      angle (equivalently sensor position).
%
%      This script always works on the microlens in the current ISET sensor
%      object.  If none exists, it creates the default microlens using the
%      current sensor/pixel and oi/optics.
%
%      MICROLENSWINDOW, by itself, creates a new MICROLENSWINDOW or raises
%      the existing singleton*.
%
%      H = MICROLENSWINDOW returns the handle to a new MICROLENSWINDOW or
%      the handle to the existing singleton*.
%
%      MICROLENSWINDOW('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in MICROLENSWINDOW.M with the given
%      input arguments.
%
%      MICROLENSWINDOW('Property','Value',...) creates a new
%      MICROLENSWINDOW or raises the existing singleton*.  Starting from
%      the left, property value pairs are applied to the GUI before
%      microLensWindow_OpeningFunction gets called.  An unrecognized
%      property name or invalid value makes property application stop.  All
%      inputs are passed to microLensWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Copyright ImagEval Consultants, LLC, 2003.

% Edit the above text to modify the response to help microLensWindow
%
% Programming TODO:
%   the mlSetCurrent() function should really be a sensorSet
%   The general interaction with sensor and oi objects should be reviewed.
% Last Modified by GUIDE v2.5 15-Feb-2015 11:49:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @microLensWindow_OpeningFcn, ...
    'gui_OutputFcn',  @microLensWindow_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
return;

% --- Executes just before microLensWindow is made visible.
function microLensWindow_OpeningFcn(hObject, eventdata, handles, varargin)

% We no longer check for license
mlOpen(hObject,eventdata,handles);

return;


% --- Outputs from this function are returned to the command line.
function varargout = microLensWindow_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

return;

% --- Executes on button press in btnCompute.
% function btnCompute_Callback(hObject, eventdata, handles)
% %
% %  Compute the spatial distribution of the light - deprecated.
% %
% % The microlens in the current ISET sensor is the master.  Any time and we
% % do a computation we get that micro lens structure and update its
% % parameters from this window.  When we are done with the computation we
% % store the new micro lens information in the sensor window.
% %
% ml = mlGetCurrent();
%
% % Time to check all the units in this call, and presumably in several
% % others.
% ml = mlRadiance(ml);
%
% mlSetCurrent(ml);
%
% % Indicate that the compute is up to date.
% set(handles.btnCompute,'ForegroundColor',[ 0 0 0]);
% mlRefresh(handles,ml);
% return;

%-----------------------------
function editChiefRay_Callback(hObject, eventdata, handles)
% Chief ray angle from source

ml = mlGetCurrent();
v = str2double(get(handles.editChiefRay,'string'));
ml = mlensSet(ml,'chief ray angle',v);
mlSetCurrent(ml);


mlRefresh(handles);
return;

% --- Executes during object creation, after setting all properties.
function editMLOffset_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;


function editMLOffset_Callback(hObject, eventdata, handles)
% Microlens offset (negative is towards array center)
% Microns in the window and microns in the object
%
ml = mlGetCurrent();
v = str2double(get(handles.editMLOffset,'string'));
ml = mlensSet(ml,'offset',v);
mlSetCurrent(ml);


mlRefresh(handles);
return;

% --- Executes during object creation, after setting all properties.
function editMLFocalLength_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------
function editMLFocalLength_Callback(hObject, eventdata, handles)
% Microlens focal length (microns in window, meters in object)

ml = mlGetCurrent();
v = str2double(get(handles.editMLFocalLength,'string'));
v = v*1e-6;
ml = mlensSet(ml,'ml focal length',v);
mlSetCurrent(ml);


mlRefresh(handles,ml);
return;

% --- Executes during object creation, after setting all properties.
function editChiefRay_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% function editChiefRay(hObject, eventdata, handles)
% mlRefresh(handles,ml);
% return;

% --- Executes during object creation, after setting all properties.
function editImageFocalLength_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes during object creation, after setting all properties.
function editImageFocalLength_Callback(hObject, eventdata, handles)
% Source focal length (mm in window, meters in object)

ml = mlGetCurrent();
v = str2double(get(handles.editImageFocalLength,'string'));
v = v*1e-3;  % Millimeters to meters
ml = mlensSet(ml,'source focal length',v);
mlSetCurrent(ml);

mlRefresh(handles);
return;
% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
return;
% --------------------------------------------------------------------
function menuEditInitML_Callback(hObject, eventdata, handles)
% Edit | Init
%

mlGetCurrent();

mlFillWindowFromML(handles,ml);

mlRefresh(handles,ml);
return;

% --------------------------------------------------------------------
function menuPlot_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuPlotPixIrradiance_Callback(hObject, eventdata, handles)
% Plot | Pixel Irradiance
ml = mlGetCurrent();
plotML(ml,'pixelIrradiance');
return;

% --------------------------------------------------------------------
function menuPlotNewGraphWin_Callback(hObject, eventdata, handles)
vcNewGraphWin;
return;

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
return;

% --- Executes during object creation, after setting all properties.
function editWave_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editWave_Callback(hObject, eventdata, handles)
% Edit wavelength box

ml = mlGetCurrent();
v = str2double(get(handles.editWave,'string'));
ml = mlensSet(ml,'wavelength',v);
mlSetCurrent(ml);

% Note change in window
mlRefresh(handles);
return;

% --- Executes during object creation, after setting all properties.
function editMLFNumber_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editMLFNumber_Callback(hObject, eventdata, handles)
% Edit box for microlens fnumber.

ml = mlGetCurrent();
v  = str2double(get(handles.editMLFNumber,'string'));
ml = mlensSet(ml,'ml fnumber',v);
mlSetCurrent(ml);

mlRefresh(handles);

return;

% --- Executes during object creation, after setting all properties.
function editFNumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editFNumber_Callback(hObject, eventdata, handles)
% Edit the source fnumber

ml = mlGetCurrent();
v  = str2double(get(handles.editFNumber,'string'));
ml = mlensSet(ml,'source fnumber',v);
mlSetCurrent(ml);

mlRefresh(handles);
return;

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuFileConsistent_Callback(hObject, eventdata, handles)
% File | Create ML from currrent oi/sensor data

fprintf('** Creating microlens from current oi and sensor\n');

% Build a microlens based on the current pixel and optics parameters.
ml = mlensCreate(vcGetObject('sensor'),vcGetObject('oi'));

% Now adjust any parameters in the microlens window
mlFillWindowFromML(handles,ml);

% Store the microlens in the sensor and update the window
mlSetCurrent(ml);

mlRefresh(handles);
return;

% % --------------------------------------------------------------------
% function menuFileSaveML_Callback(hObject, eventdata, handles)
% % File | Save
% % Save it to a file
% ml = mlGetCurrent();
% fullName = vcSelectDataFile('stayPut','w');
% if isempty(fullName), disp('User canceled'); return; end
% save(fullName,'ml');
% return;

% % --------------------------------------------------------------------
% function menuFileLoadML_Callback(hObject, eventdata, handles)
% % File | Load
% % Load microlens parameters from a file and set it as the current microlens
% %
%
% fullName = vcSelectDataFile('stayPut','r');
% if isempty(fullName), disp('User canceled'); return; end
% tmp = load(fullName);
% if isfield(tmp,'ml')
%     mlSetCurrent(tmp.ml,handles);
%     mlRefresh(handles);
% else
%     error('No microlens structure (named ml) in the file.');
% end
%
% return;

% --------------------------------------------------------------------
% function menuFileLoadFromISA_Callback(hObject, eventdata, handles)
% % sensor -> mLens
% % Copy the microlens from the current sensor into this window.
% % If none is there, we create a default microlens.
% % We also check if there is an oi.  If not, we create one and use that.
%
% ml = sensorGet(vcGetObject('sensor'),'microlens');
%
% if isempty(ml)
%     sensor = vcGetObject('sensor');
%     if isempty(sensor), sensor = sensorCreate; ieAddObject(sensor); end
%
%     oi = vcGetObject('oi');
%     if isempty(oi), oi = oiCreate; ieAddObject(oi); end
%
%     ml = mlensCreate(sensor,oi);
% end
%
% % Should have
% mlFillWindowFromML(handles,ml);
%
% return;

% % --------------------------------------------------------------------
% function menuFileSaveToISA_Callback(hObject, eventdata, handles)
% % File | Save to sensor
% %
% % When the parameters are changed in the mlens window, we update the mlens
% % structure and store it in the sensor window.
% %
%
% % Get the ml in the sensor
% ml = mlGetCurrent();
%
% ml = mlUpdate(handles);
%
% mlSetCurrent(ml);
%
% return;

% --------------------------------------------------------------------
function menuFileRefresh_Callback(hObject, eventdata, handles)
% File | Refresh
ml = mlGetCurrent();
mlRefresh(handles,ml);
return;

% --------------------------------------------------------------------
function menuFileClose_Callback(hObject, eventdata, handles)
closereq;
return;

% --------------------------------------------------------------------
function menuEditFontSize_Callback(hObject, eventdata, handles)
ieFontSizeSet(handles.microLensWindow);
return;

% --------------------------------------------------------------------
function menuAnalyze_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnalyzeVignetting_Callback(hObject, eventdata, handles)
% Analyze | Efficiency: No Microlens
%
% This routine also update the microlens information in the sensor fields.

ml = mlGetCurrent();
mlSetCurrent(ml);
sensor = vcGetObject('sensor');
sensor = mlAnalyzeArrayEtendue(sensor,'nomicrolens');

% Need units here ... use spatialSupport type call
vcNewGraphWin;
mesh(sensorGet(sensor,'etendue'));
xlabel('Pixel col');
ylabel('Pixel row');

vcReplaceObject(sensor);

return;

% --------------------------------------------------------------------
function menuAnalyzeEtendueOpt_Callback(hObject, eventdata, handles)
% Analyze | Efficiency: Optimal Placement
%
% This updates the current sensor microlens with information in the ml
% window

s = vcGetObject('sensor');
s = mlAnalyzeArrayEtendue(s,'optimal');

% Need units here ... use spatialSupport type call
vcNewGraphWin;
mesh(sensorGet(s,'etendue'));
xlabel('Pixel col');
ylabel('Pixel row');

return;

% % --------------------------------------------------------------------
% function menuAnalyzeOptBare_Callback(hObject, eventdata, handles)
% %  Analyze | Optimal Vs. No MicroLens
%
% % This updates the sensor microlens with information in the ml window
% sensor = vcGetObject('sensor');
%
% ISA1     = mlAnalyzeArrayEtendue(sensor,'optimal');
% optimalE = sensorGet(ISA1,'sensor etendue');
%
% ISA2  = mlAnalyzeArrayEtendue(sensor,'no microlens');
% bareE = sensorGet(ISA2,'vignetting');
%
% zLabel = 'Optimal-Bare Improvement (%)';
% plotEtendueRatio(sensor,optimalE,bareE,zLabel);
%
% return;
%
% % --------------------------------------------------------------------
% function menuAnalyzeOptCent_Callback(hObject, eventdata, handles)
% %
% %  Analyze | Optimal Vs. Centered
% %
%
% % This updates the sensor microlens with information in the ml window
% sensor = vcGetObject('sensor');
%
% sensor = mlAnalyzeArrayEtendue(sensor,'optimal');
% optimalE = sensorGet(sensor,'sensorEtendue');
%
% sensor = mlAnalyzeArrayEtendue(sensor,'centered');
% centeredE = sensorGet(sensor,'sensorEtendue');
% zLabel = 'Optimal-Centered Improvement (%)';
% plotEtendueRatio(sensor,optimalE,centeredE,zLabel);
%
%
% return;
% --------------------------------------------------------------------
function menuPlotOptimalOffset_Callback(hObject, eventdata, handles)
% Plot | Offsets
% Make a mesh plot showing the optimal spatial offset of each microlens.

plotML(mlGetCurrent(),'offsets');

return;

% % --------------------------------------------------------------------
% function menuAnalyzeArrayEtendue_Callback(hObject, eventdata, handles)
% %
% % Analyze | Etendue (Custom) at the moment this means centered.
%
% disp('Etendue (Custom) not yet implemented.')
%
% % sensor = vcGetObject('sensor');
% % if isempty(sensor)
% %     error('No image sensor array.');
% %     return;
% % end
% %
% % % Get the current microlens.  It may have more information than just what
% % % is in the window
% % ml = sensorGet(sensor,'microlens');
% %
% % % Use the data in the window, not in the sensor structure.
% % ml = mlFillMLFromWindow(handles,ml);
% % sensor = sensorSet(sensor,'microlens',ml);
% %
% % % Main computation here
% % sensor = mlAnalyzeArrayEtendue(sensor);
% %
% % % Put up the figure
% % plotSensorEtendue(sensor)
% %
% % % The ml and the sensor have been updated.
% % vcReplaceObject(sensor);
%
% return;


% --------------------------------------------------------------------
function menuFileReset_Callback(hObject, eventdata, handles)
% File | Reset
%
% Put the current sensor microlens into the window
%
% This might be used if you change the sensor outside of the window and
% just want everything copied into the window.

ml = sensorGet(vcGetObject('sensor'),'microlens');
if isempty(ml), error('No microlens in current image sensor array.'); end

mlFillWindowFromML(handles,ml);

mlRefresh(handles,ml);
return;


% --------------------------------------------------------------------
function editMlensRefIdx_Callback(hObject, eventdata, handles)
% Edit | Refractive index
% Adjust the refractive index of the microlens

ml = mlGetCurrent();

% Go get the number and replace it
refIdx =  mlensGet(ml,'ml refractive index');
refIdx = ieReadNumber('Enter microlens refractive index',refIdx,' %.2f');
ml = mlensSet(ml,'ml refractive index',refIdx);
mlSetCurrent(ml);

mlRefresh(handles,ml);

return;

% % --- Executes on button press in pb2ISA.
% function pb2ISA_Callback(hObject, eventdata, handles)
% menuFileSaveToISA_Callback(hObject, eventdata, handles);
% menuFileRefresh_Callback(hObject, eventdata, handles);
% return;

% % --- Executes on button press in pbFromISA.
% function pbFromISA_Callback(hObject, eventdata, handles)
% menuFileLoadFromISA_Callback(hObject, eventdata, handles)
% menuFileRefresh_Callback(hObject, eventdata, handles);
% return;

% --- Executes on button press in pbOIParams.
function pbOIParams_Callback(hObject, eventdata, handles)
% button:  Load pixel/optics
%
% Makes the current microlens consistent with the data in the current
% oi/optics and sensor/pixel

menuFileConsistent_Callback(hObject, eventdata, handles);


return;
