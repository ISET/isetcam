function varargout = sensorImageWindow(varargin)
%Sensor image window interface
%
%   varargout = sensorImageWindow(varargin)
%   SENSORIMAGEWINDOW M-file for sensorImageWindow.fig
%
%  Graphical user interface to manage the Image Sensor Array (ISA) properties.
%
%  SENSORIMAGEWINDOW, by itself, creates a new SENSORIMAGEWINDOW or raises the existing
%  singleton*.
%
%  H = SENSORIMAGEWINDOW returns the handle to a new SENSORIMAGEWINDOW or the handle to
%  the existing singleton*.
%
%  H = SENSORIMAGEWINDOW(sensor) adds sensor to the ISET database and
%  returns the handle to a new SENSORIMAGEWINDOW or the handle to the
%  existing singleton*.
%
%  SENSORIMAGEWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%  function named CALLBACK in SENSORIMAGEWINDOW.M with the given input arguments.
%
%  SENSORIMAGEWINDOW('Property','Value',...) creates a new SENSORIMAGEWINDOW or raises the
%  existing singleton*.  Starting from the left, property value pairs are
%  applied to the GUI before sensorImageWindow_OpeningFunction gets called.  An
%  unrecognized property name or invalid value makes property application
%  stop.  All inputs are passed to sensorImageWindow_OpeningFcn via varargin.
%
%  *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%  instance to run (singleton)".
%
% Copyright ImagEval Consultants, LLC, 2005.

% Last Modified by GUIDE v2.5 02-Apr-2018 20:42:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name', mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @sensorImageWindow_OpeningFcn, ...
    'gui_OutputFcn',  @sensorImageWindow_OutputFcn, ...
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


% --- Executes just before sensorImageWindow is made visible.
function sensorImageWindow_OpeningFcn(hObject, eventdata, handles, varargin)

if isempty(varargin) % Do nothing
elseif isstruct(varargin{1}) && ...
        isfield(varargin{1},'type') && ...
        (strcmp(varargin{1}.type,'sensor'))
    % We have a sensor as input.  Put it in the database.
    ieAddObject(varargin{1});
end

sensorOpen(hObject,eventdata,handles)
sensorRefresh(hObject, eventdata, handles); 

% If the person has set a position and size preference, put the window
% there
ISETprefs = getpref('ISET');
if isfield(ISETprefs,'wPos')
    wPos = ISETprefs.wPos;
    if ~isempty(wPos{4}), set(hObject,'Position',wPos{4}); end
end
return;

% --- Outputs from this function are returned to the command line.
function varargout = sensorImageWindow_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

return;

% --- Executes during object creation, after setting all properties.
function popISA_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% Make sure the right name is in the cfa name popup
% [val,isa] = ieGetObject('ISA');
% set(hObject,'String',sensorCFANameList);

return;

% --- Executes on selection change in popISA.
function popISA_Callback(hObject, eventdata, handles)
% Create sensor with one of a set of standard CFA types
% Called by popup at right that defines the color filter array types.
%
% When this change is made, the current data are
% emptied and the colorOrder, pattern, and unitBlock fields are changed.

% Get the current image sensor array.
[val,sensor] = vcGetSelectedObject('ISA');

% Read the named CFA choice
sensorArrayNames = get(hObject,'String');
thisArrayName = sensorArrayNames{get(hObject,'Value')};

% Depending on the choice, create a default ISA array so you can have the
% proper fields for copying into the current array.
switch ieParamFormat(thisArrayName)
    case 'bayerrgb'
        newSensor = sensorCreate;  % Default is RGB
    case 'bayercmy'
        newSensor = sensorCreate('cmy');
    case 'rgbw'
        newSensor = sensorCreate('rgbw');
    case 'monochrome'
        newSensor = sensorCreate('monochrome');
    otherwise
        ieInWindowMessage('No Other sensor created.',handles,2);
        sensorRefresh(hObject, eventdata, handles);
        return;
end

% Copy the newSensor fields into the currently selected sensor
sensor = sensorSet(sensor,'name',newSensor.name);
sensor = sensorSet(sensor,'color',newSensor.color);
sensor = sensorSet(sensor,'colorfilterarray',newSensor.cfa);

% Empty the data field.
sensor = sensorClearData(sensor);
vcReplaceObject(sensor,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes on button press in btnComputeImage.
function btnComputeImage_Callback(hObject, eventdata, handles)
% Button press computes the image from the optics data
%

OI = ieGetObject('OI');
if isempty(oiGet(OI,'photons'))
    ieInWindowMessage('No optical image photon data.',handles); 
    return; 
else
    ieInWindowMessage([],handles); 
end
[val,ISA] = vcGetSelectedObject('ISA');

% The custom compute button is checked inside of sensorCompute.
ISA = sensorCompute(ISA,OI);

% For the moment, data and ISA are consistent.
ISA = sensorSet(ISA,'consistency',1);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuAnComputeFromOI_Callback(hObject, eventdata, handles)
btnComputeImage_Callback(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuAnComputeFromScene_Callback(hObject, eventdata, handles)

% Recompute the sensor data starting all the way back with the current
% scene and optical image.
[val,scene] = vcGetSelectedObject('scene');
if isempty(scene)
    warndlg('Creating default scene'); 
    scene = sceneCreate; val = 1; 
    vcReplaceAndSelectObject(scene,val);
end

[val,oi] = vcGetSelectedObject('oi');
if isempty(oi), 
    warndlg('Creating default OI'); 
    oi = oiCreate; val = 1; 
end
oi = oiCompute(scene,oi);
vcReplaceAndSelectObject(oi,val);

btnComputeImage_Callback(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editReadNoise_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

function editReadNoise_Callback(hObject, eventdata, handles)

[val,ISA] = vcGetSelectedObject('ISA');
pixel = sensorGet(ISA,'pixel');

rn = str2double(get(hObject,'String'));   % Display is mV, stored in Volts.
pixel = pixelSet(pixel,'readnoisemillivolts',rn);
ISA = sensorSet(ISA,'pixel',pixel); 

vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editDarkCurrent_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;


function editDarkCurrent_Callback(hObject, eventdata, handles)
%
%  The name of this routine should be changed.  We used to specify dark
%  current, but now we specify dark voltage
%  This should be editDarkVoltage_Callback().
%
% We specify dark voltage (no longer current) in mV/pixel/sec.
% The parameters darkcurrent, darkcurrentdensity are now derived from this
% and other sensor properties.

[val,ISA] = vcGetSelectedObject('ISA');
pixel = sensorGet(ISA,'pixel');

% Value entered is in millivolts.  Value stored is in Volts.
dk = str2double(get(hObject,'String'))*10^-3;
pixel =  pixelSet(pixel,'darkvoltage',dk);

ISA = sensorSet(ISA,'pixel',pixel);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editISARows_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%------------------------------------------------
function editISARows_Callback(hObject, eventdata, handles)
% Edit number of sensor rows
[val,sensor] = vcGetSelectedObject('sensor');

targetSize = str2double(get(hObject,'String'));
sensor = sensorSet(sensor,'rows',targetSize); 
str = sprintf('%.0f',sensorGet(sensor,'rows')); 
set(gcbo,'string',str);

% 
% unitBlockRows = sensorGet(sensor,'unitblockrows');
% targetSize = str2double(get(hObject,'String'));
% sensor.rows = round(targetSize/unitBlockRows)*unitBlockRows;

str = sprintf('%.0f',sensorGet(sensor,'rows')); 
set(gcbo,'string',str);

sensor = sensorClearData(sensor);
vcReplaceObject(sensor,val);

sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editISAcols_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

% -------------------------------------------------------
function editISAcols_Callback(hObject, eventdata, handles)
% Edit box - adjust number of columns
[val,sensor] = vcGetSelectedObject('ISA');

targetSize = str2double(get(hObject,'String'));
sensor = sensorSet(sensor,'cols',targetSize); 
str = sprintf('%.0f',sensorGet(sensor,'cols')); 
set(gcbo,'string',str);

sensor = sensorClearData(sensor);
vcReplaceObject(sensor,val);
sensorRefresh(hObject, eventdata, handles);
return;


% --- Executes during object creation, after setting all properties.
function popScaleSize_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popScaleSize.
function popScaleSize_Callback(hObject, eventdata, handles)

contents = get(hObject,'String');
factor   = contents{get(hObject,'Value')};

switch lower(factor)
    case 'x'
        return;
    case 'x 2'
        s = 2;
    case 'x 4'
        s = 4;
    case 'x 1/2'
        s = 1/2;
    case 'x 1/4'
        s = 1/4;
    otherwise
end

% Get the current image sensor array
[val,sensor] = vcGetSelectedObject('ISA');

% Define target size to be consistent with desired scale and CFA
cfaSize = sensorGet(sensor,'cfaSize');
targetSize = ceil(s*sensorGet(sensor,'size') ./ cfaSize).* cfaSize;

% If for some reason ceil(sz/cfaSize) is zero, we set size to one pixel
% cfa.
if targetSize(1) == 0, targetSize = cfaSize; end

% Set size
% Data are cleared
sensor = sensorSet(sensor,'size',targetSize); 

vcReplaceObject(sensor,val);
sensorRefresh(hObject, eventdata, handles);

return;


% --- Executes during object creation, after setting all properties.
function editConvGain_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;


function editConvGain_Callback(hObject, eventdata, handles)

[val,ISA] = vcGetSelectedObject('ISA');

% Interface is in microvolts per electron, typical value is 10-100 uV/e-
% We store the value in standard units:  V/e- 
ISA.pixel.conversionGain = str2double(get(hObject,'String'))*10^(-6);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);
return;


% --- Executes during object creation, after setting all properties.
function editExpTime_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%----------------------------------------------------------------
function editExpTime_Callback(hObject, eventdata, handles)
%
[val,sensor] = vcGetSelectedObject('sensor');

% Interface is in several possible time units. We read in the those units,
% but we store exposure time in seconds.
str = get(handles.txtExposureUnits,'string');
switch str
    case '(sec)'
        sFactor = 1;
    case '(us)'
        sFactor = 1e-6;
    case '(ms)'
        % (ms)
        sFactor = 1e-3;
    otherwise
        sFactor = 1e-3;
        warning('unexpected time string %s\n',str);
end
sensor = sensorSet(sensor,'expTime',str2double(get(hObject,'String'))*sFactor);

% If the expTime is in bracketed mode, create the vector
if isequal(get(handles.popupExpMode,'Val'),2)
    sensor = sensorAdjustBracketTimes(handles,sensor);
elseif isequal(get(handles.popupExpMode,'Val'),1)
    % Do nothing
else
    error('Exposure popup value (expPopup)%f\n',get(handles.popupExpMode,'Val'))
end

% Turn off auto-exposure
sensor = sensorSet(sensor,'autoexposure','off');
vcReplaceObject(sensor,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editVoltageSwing_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

%---------------------------------------------------------
function editVoltageSwing_Callback(hObject, eventdata, handles)

[val,ISA] = vcGetSelectedObject('ISA');
ISA.pixel.voltageSwing = str2double(get(hObject,'String'));
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editOffsetFPN_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

function editOffsetFPN_Callback(hObject, eventdata, handles)
% DSNU measurement in mv
%
[val,ISA] = vcGetSelectedObject('ISA');

% SD displayed in millivolts, stored in volts
sd = str2double(get(hObject,'String'))*10^-3;
ISA = sensorSet(ISA,'offsetsd',sd);
ISA = sensorSet(ISA,'offsetfpnimage',[]);

vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editGainFPN_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editGainFPN_Callback(hObject, eventdata, handles)

[val,sensor] = vcGetSelectedObject('ISA');

% Standard deviation of the slope of the photoresponse function.  
% These numbers are stored as a percentage, just as in the interface.
% When we compute the standard deviation of the slope, we calculate
% gainImage = 1 + randn()*(sigmaGainFPN/100)
%
% This produces a normal random variable with a standard deviation equal to
% the percent in the window.
%
gainSD = str2double(get(hObject,'String'));
sensor = sensorSet(sensor,'gainSD',gainSD);
sensor = sensorSet(sensor,'gainFPNimage',[]);

vcReplaceObject(sensor,val);

sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
return;

function menuFileLoad_Callback(hObject, eventdata, handles, varargin)
return;

function menuFileSave_Callback(hObject, eventdata, handles, varargin)
return;

% --------------------------------------------------------------------
function menuFileLoadVoltsMat_Callback(hObject, eventdata, handles)
% Load Volts (MAT file)
% Load in new voltage data from a MAT file
%
fullName = vcSelectDataFile('stayput','r','mat');
if isempty(fullName), return; end

tmp = load(fullName,'volts');
isa = vcGetObject('ISA');
isa = sensorSet(isa,'volts',tmp.volts);

vcReplaceAndSelectObject(isa);
sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuFileSaveVoltsMat_Callback(hObject, eventdata, handles)
% Save Volts (MAT file)
isa = vcGetObject('ISA');
volts = sensorGet(isa,'volts');
if isempty(volts), errordlg('No voltage data.'); end

fullName = vcSelectDataFile('stayput','w','mat');
if ~isempty(fullName), save(fullName,'volts'); end

return;

% --------------------------------------------------------------------
function menuSaveImage_Callback(hObject, eventdata, handles)
% Save Display (RGB Image)
%
% An option to save other data types will be needed some day, including DV
% in particular.

[val,isa] = vcGetSelectedObject('ISA');
gam = str2double(get(handles.editGam,'String'));
scaleMax = get(handles.btnDisplayScale,'Value');

sensorSaveImage(isa,[],'volts',gam,scaleMax);

return;

% --------------------------------------------------------------------
function menuFileSpecsheet_Callback(hObject, eventdata, handles)
% File | Spec sheet
% Write out an Excel (or text?) spec sheet describing the sensor
%

disp('Spec sheet not yet implemented')

% The idea is to create a set of sensor spec values and then use
% xlswrite to printout an Excel spreadsheet summarizing them.

return;

% --------------------------------------------------------------------
function menuFileClose_Callback(hObject, eventdata, handles)
sensorClose
return;

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditName_Callback(hObject, eventdata, handles)
[val,sensor] = vcGetSelectedObject('ISA');

newName = ieReadString('New sensor name','new-isa');
if isempty(newName),  return;
else    sensor = sensorSet(sensor,'name',newName);
end

vcReplaceObject(sensor,val);
sensorRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuCopySensor_Callback(hObject, eventdata, handles)

sensor = vcGetObject('ISA');

newName = ieReadString('New ISA name','new-isa');
if isempty(newName),  return;
else    sensor = sensorSet(sensor,'name',newName);
end

vcAddAndSelectObject('ISA',sensor);
sensorRefresh(hObject, eventdata, handles);         
   
return;

% --------------------------------------------------------------------
function menuEditCreate_Callback(hObject, eventdata, handles)

createNewSensor(hObject, eventdata, handles);
sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditDelete_Callback(hObject, eventdata, handles)
sensorDelete(hObject,eventdata,handles);
sensorRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditResWave_Callback(hObject, eventdata, handles)
% Edit | Resample Wavelength
isa = vcGetObject('isa');
isa = sensorResampleWave(isa);
vcReplaceObject(isa);
return;

% --------------------------------------------------------------------
function sensorEditClearData_Callback(hObject, eventdata, handles)
% Edit | clear data
[val,ISA] = vcGetSelectedObject('ISA');
ISA = sensorClearData(ISA);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);   
return;

% --------------------------------------------------------------------
function menuEditClearMessage_Callback(hObject, eventdata, handles)
ieInWindowMessage('',ieSessionGet('sensorWindowHandles'),[]);
return;

% --------------------------------------------------------------------
function menuEditZoom_Callback(hObject, eventdata, handles)
% Edit | Zoom
% Toggle the zoom state.  The zoom state is stored in the status of the
% checkbox of the zoom menu item.
if isequal(get(hObject,'checked'),'off'), 
    zoom('on');
    set(hObject,'checked','on');
else % Must be on
    zoom('off');
    set(hObject,'checked','off');
end

return;

% --------------------------------------------------------------------
function menuEditViewer_Callback(hObject, eventdata, handles)
% Edit | Viewer
sensor = vcGetObject('ISA');
img = sensorData2Image(sensor,'volts');
ieViewer(img);
return;

% --- Executes on button press in btnAutoExp.
function btnAutoExp_Callback(hObject, eventdata, handles)
% Auto exposure button
[val,ISA] = vcGetSelectedObject('ISA');
ISA.AE = get(hObject,'Value');
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuAnalyzePOVignetting_Callback(hObject, eventdata, handles)
% Analyze | Pixel Optics | Relative Illumination
sensor = vcGetObject('sensor');
sensorPlot(sensor,'etendue');
return;
% --------------------------------------------------------------------
function menuSensorHumanCones_Callback(hObject, eventdata, handles)
% hObject    handle to menuSensorHumanCones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
return;

% --------------------------------------------------------------------
function humanCones631_Callback(hObject, eventdata, handles)
% Sensor | Human cones | Cones-631
params.sz = [128,192];
params.rgbDensities = [0.0 .6 .3 .1]; % Empty, L,M,S
params.coneAperture = [2.5 2.5]*1e-6;     % In meters
pixel = [];
sensor = sensorCreate('human',pixel,params);
vcAddAndSelectObject(sensor);
sensorRefresh(hObject, eventdata, handles);
return

% --------------------------------------------------------------------
function humanConesKLMS1631_Callback(hObject, eventdata, handles)
% Sensor | Human cones | Cones-631
params.sz = [128,192];
params.rgbDensities = [0.1 .6 .3 .1]; % Empty, L,M,S
params.coneAperture = [2.5 2.5]*1e-6;     % In meters
pixel = [];
sensor = sensorCreate('human',pixel,params);
vcAddAndSelectObject(sensor);
sensorRefresh(hObject, eventdata, handles);
return

% --------------------------------------------------------------------
function menuSensorPixelVignetting_Callback(hObject, eventdata, handles)
% Sensor | Pixel OE Method
%
% Set check the Pixel OE computation.

ISA = vcGetObject('ISA');

% Set the vignetting
pvFlag = sensorGet(ISA,'vignetting');
str = sprintf('Help: 0=skip,1=bare,2=centered,3=optimal');
pvFlag = ieReadNumber(str,pvFlag,'%.0f');
if isempty(pvFlag), return; end

ISA = sensorSet(ISA,'vignetting',pvFlag);
ISA = sensorSet(ISA,'etendue',[]);

vcReplaceObject(ISA);
sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSensorMicrolens_Callback(hObject, eventdata, handles)
% Sensor | Design Microlens
if ~exist('microLensWindow.m','file')
    errordlg('You do not have the optics toolkit.  Please contact ImagEval.');
else
    microLensWindow;
end

return;

% --------------------------------------------------------------------
function menuSensorCDS_Callback(hObject, eventdata, handles)
%  Set check on CDS menu item.  We should probably display this in the
%  information box at the right, also.

ISA = vcGetObject('ISA');
state = get(hObject,'Check');

switch state
    case 'on'
        set(hObject,'Check','off');
        ISA = sensorSet(ISA,'cds',0);
    case 'off'
        set(hObject,'Check','on');
        ISA = sensorSet(ISA,'cds',1);
end
vcReplaceObject(ISA);
sensorRefresh(hObject, eventdata, handles);

return;


% --------------------------------------------------------------------
function menuSensorColFPN_Callback(hObject, eventdata, handles)

sensor = vcGetObject('ISA');
state = get(hObject,'Check');

switch state
    case 'on'
        set(hObject,'Check','off');
        sensor = sensorSet(sensor,'columnFPN',[]);
        sensor = sensorSet(sensor,'columnDSNU',[]);
        sensor = sensorSet(sensor,'columnPRNU',[]);
        % Should we clear the sensor data here?
    case 'off'
        % Store the column FPN value.
        set(hObject,'Check','on');
        
        % Should we pull this out as a separate routine?
        prompt={'Enter column DSNU (sd in millivolts)', ...
                'Enter column PRNU (sd. around unity gain)'}; 
        def={'1','0.01'}; 
        dlgTitle= sprintf('ISET read number'); 
        answer = inputdlg(prompt,dlgTitle,2,def);
        
        if   isempty(answer),  val = []; return;
        else                   
            colOffsetFPN = eval(answer{1})/1000;     % Read in mV, stored in volts
            colGainFPN   = eval(answer{2});          % Store as sd around unity gain
        end

        % Create and store the column noise parameters and an instance of
        % the noise itself
        nCol = sensorGet(sensor,'cols');
        colDSNU = randn(1,nCol)*colOffsetFPN;       % Offset noise stored in volts
        colPRNU = randn(1,nCol)*colGainFPN + 1;             % Column gain noise

        % Set the parameters.  Could combine the two reads into one.
        sensor = sensorSet(sensor,'columnFPN',[colOffsetFPN,colGainFPN]);
        sensor = sensorSet(sensor,'columnDSNU',colDSNU);
        sensor = sensorSet(sensor,'columnPRNU',colPRNU);
        
end
vcReplaceObject(sensor);
sensorRefresh(hObject, eventdata, handles);

return;


% --------------------------------------------------------------------
function menuSensorSetComputeGrid_Callback(hObject, eventdata, handles)
% Sensor | Set Compute Grid
% Sets pixel samples in signalCurrent

sensor = vcGetObject('ISA');
currentPixelSamples = sensorGet(sensor,'nSamplesPerPixel');
nPixelSamples = ieReadNumber('Enter odd integer specifying number of samples/pixel (default=1)',currentPixelSamples,'%.0f');

if isempty(nPixelSamples), return;
elseif nPixelSamples < 1, nPixelSamples = 1;
elseif ~mod(nPixelSamples,2), nPixelSamples = nPixelSamples+1;
end

sensor = sensorSet(sensor,'nSamplesPerPixel',nPixelSamples);
vcReplaceObject(sensor);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function popupSelect_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupSelect.
function popupSelect_Callback(hObject, eventdata, handles)
% Main popup window at top.  Create a New ISA or select a different one.
contents = get(hObject,'String');

switch  (contents{get(hObject,'Value')})
    
    case 'New'
        createNewSensor(hObject, eventdata, handles);
        
    otherwise,
        % The first two entries is always New.  The selections,
        % therefore, begin with the entry number in the list - 1.
        val = get(hObject,'Value') - 1;
        vcSetSelectedObject('ISA',val);
        sensorRefresh(hObject, eventdata, handles);
end

return;

% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% Push button with the + on the right of the selection popup
s  = ieSessionGet('selected','sensor');
nS = ieSessionGet('nobjects','sensor');
s = min(s + 1,nS);
s = max(s,1);
vcSetSelectedObject('ISA',s);
sensorRefresh(hObject, eventdata, handles);
return;

% --- Executes on button press in btnPrev.
function btnPrev_Callback(hObject, eventdata, handles)
% Push button with the - on the left of the selection popup
s  = ieSessionGet('selected','sensor');
nS = ieSessionGet('nobjects','sensor');
s = min(s - 1,nS);
s = max(s,1);
vcSetSelectedObject('ISA',s);
sensorRefresh(hObject, eventdata, handles);
return;

% --- Executes on selecting new from the popup.
function createNewSensor(hObject, eventdata, handles)
% New ISA
% Defaults to current values, except new color, as per sensorCreate.

newISA = vcGetObject('ISA');
newVal = vcNewObjectValue('ISA');

sensorArrayNames = get(handles.popISA,'String');
thisArrayName = sensorArrayNames{get(handles.popISA,'Value')};
switch lower(thisArrayName)
    case {'bayer-grbg'}
        newISA = sensorCreate('bayer-grbg');
    case {'bayer-rggb'}
        newISA = sensorCreate('bayer-rggb');
    case {'bayer-bggr'}
        newISA = sensorCreate('bayer-bggr');
    case 'bayer-ycmy'
        newISA = sensorCreate('bayer-ycmy');
    case {'Four Color'}
        newISA = sensorCreate('fourcolor');
    case 'monochrome'
        newISA = sensorCreate('monochrome');
    otherwise
        warning('Creating default sensor.')
        newISA = sensorCreate('default');
end

vcReplaceAndSelectObject(newISA,newVal);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes on button press in btnDelete.
function sensorDelete(hObject, eventdata, handles)

vcDeleteSelectedObject('ISA');
[val,isa] = vcGetSelectedObject('ISA');
if isempty(val)
    isa = sensorCreate('default');
    vcReplaceAndSelectObject(isa,1);
end

sensorRefresh(hObject, eventdata, handles);

return;

function editDeleteSome_Callback(hObject, eventdata, handles)
% Edit delete some sensors
%
vcDeleteSomeObjects('sensor');
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editGam_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editGam_Callback(hObject, eventdata, handles)
% Handle value is read during refresh.

% Don't change the red consistency button
sensor = vcGetObject('sensor');
sensor = sensorSet(sensor,'consistency',-1);
vcReplaceObject(sensor);
sensorRefresh(hObject,eventdata,handles);
return;

% --- Executes on button press in btnDisplayScale.
function btnDisplayScale_Callback(hObject, eventdata, handles)
% Handle value is read during refresh.

% Don't change the red consistency button
sensor = vcGetObject('sensor');
sensor = sensorSet(sensor,'consistency',-1);
vcReplaceObject(sensor);

sensorRefresh(hObject, eventdata, handles);
return;

% --- Executes during object creation, after setting all properties.
function popupColor_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes during object creation, after setting all properties.
function popFormat_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --------------------------------------------------------------------
function menuFileRefresh_Callback(hObject, eventdata, handles)
sensorRefresh(hObject, eventdata, handles);
return;

function sensorRefresh(hObject, eventdata, handles)
sensorEditsAndButtons(handles);
return;

% --- Executes during object creation, after setting all properties.
function popQuantization_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popQuantization.
function popQuantization_Callback(hObject, eventdata, handles)

contents = get(hObject,'String');
qMethod = contents{get(hObject,'Value')};
[val,isa] = vcGetSelectedObject('ISA');

isa = sensorSet(isa,'quantization',qMethod);

isa = sensorClearData(isa);
vcReplaceObject(isa,val);

sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuSensor_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSensorCIF_Callback(hObject, eventdata, handles)

return;
% --------------------------------------------------------------------
function menuSensorQQCIFSixteenthInch_Callback(hObject, eventdata, handles)
%

[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('qqcif'),sensorFormats('sixteenthinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);         

return;

% --------------------------------------------------------------------
function menuSensorQQCIFQuartInch_Callback(hObject, eventdata, handles)
%

[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('qqcif'),sensorFormats('quarterinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);     

return;

% --------------------------------------------------------------------
function menuSensorQCIFQuartInch_Callback(hObject, eventdata, handles)
%
% QCIF format, half-inch sensor

[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('qcif'),sensorFormats('quarterinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);  

return;

% --------------------------------------------------------------------
function menuSensorCIFHalfInch_Callback(hObject, eventdata, handles)
%
[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('cif'),sensorFormats('halfinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);          
return;

% --------------------------------------------------------------------
function menuSensorVGA_Callback(hObject, eventdata, handles)
% Sensor->VGA
return;

% --------------------------------------------------------------------
function menuSensorQQVGAQuartInch_Callback(hObject, eventdata, handles)
%
[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('qqvga'),sensorFormats('quarterinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuSensorQVGAQuartInch_Callback(hObject, eventdata, handles)
%
[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('qvga'),sensorFormats('quarterinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuSensorQVGAHalfInch_Callback(hObject, eventdata, handles)
[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('qvga'),sensorFormats('halfinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuSensorVGAHalfInch_Callback(hObject, eventdata, handles)
%
[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('vga'),sensorFormats('halfinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuSensorQQVGASixteenthInch_Callback(hObject, eventdata, handles)
%
[val,isa] = vcGetSelectedObject('ISA');
isa = sensorRescale(isa,sensorFormats('qqvga'),sensorFormats('sixteenthinch'));
vcReplaceObject(isa,val);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuDesignCFA_Callback(hObject, eventdata, handles)
% I first use the 'Design CFA' option in the Sensor Menu to design the CFA
% I desire. I make sure I position the individual color filters
% appropriately in the 2x2 square as 'RGGB'.
%  
% Then after I load all the respective transmissivity values for each of
% the filters, I save the CFA to a file (say we call this file
% micronRGGB.mat).
%  
% Now during a simulation run, when I load this CFA using the "Load CFA"
% option in the Sensor menu, the "Standard CFA" cell in the upper right
% hand side of the ISET-Sensor Window gets automatically updated as "Other"
% instead of 'bayer-rggb' as I would expect.
%      
sensorDesignCFA;
return;


% --------------------------------------------------------------------
function menuSensorExport_Callback(hObject, eventdata, handles)
% File | Save | Save sensor (.mat)
[val,isa] = vcGetSelectedObject('ISA');
fullName = vcExportObject(isa);
return;

% --------------------------------------------------------------------
function menuSensorImport_Callback(hObject, eventdata, handles)
% File | Load  | Sensor (.mat)
%
newVal = vcImportObject('ISA');
if isempty(newVal), return; end
vcSetSelectedObject('ISA',newVal);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuAnSNR_Callback(hObject, eventdata, handles)
% Analyze SNR menu
return;

% --------------------------------------------------------------------
function menuAnHistogram_Callback(hObject, eventdata, handles)
% Analyze Histogram Menu
return;

% --------------------------------------------------------------------
function menuISOSat_Callback(hObject, eventdata, handles)
%
speed = ISOspeed('saturation');
str = sprintf('ISO speed (saturation):    %.0f\n\n',speed);
str = [str,sprintf('Measured for a uniform D65 optical image.\n\n')];
str = [str,sprintf('Larger means saturates at lower lux-sec level.\n\n')];
fprintf('\n\n');
disp(str)

hdl = vcNewGraphWin;
p = get(hdl,'Position');
set(hdl,'Position',[p(1),p(2),p(3)/2,p(4)/2]);
set(hdl,'Menubar','none')
text(0,0.5,str,'fontsize',14); axis off;

return;

% --------------------------------------------------------------------
function menuAnExposureValue_Callback(hObject, eventdata, handles)
% Analyze | SNR | Exposure Value

oi     = vcGetObject('oi');
optics = oiGet(oi,'optics');
sensor = vcGetObject('sensor');
EV = exposureValue(optics,sensor);

str = sprintf('Exposure value (log2(f/#^2 / T)):    %.2f',EV);
ieInWindowMessage(str,ieSessionGet('sensorwindowhandles'));
fprintf('\n\n'); disp(str);
return;

%-------------Photometric Exposure Value (lux-sec)
function menuAnPhotExp_Callback(hObject, eventdata, handles)
% Analyze | SNR | Photometric Exp

str = sprintf('Photometric exposure (lux-sec): %.2f',...
    photometricExposure(vcGetObject('OI'),vcGetObject('ISA')));

% Display in window message
ieInWindowMessage(str,ieSessionGet('sensorwindowhandles'));
fprintf('\n\n'); disp(str);
return;

% ---------------Plot Menu------------------------
function menuPlot_Callback(hObject, eventdata, handles)
% Menu Plot
return;
% --------------------------------------------------------------------
function menuPlotSpectra_Callback(hObject, eventdata, handles)
% Plot-> SpectralInformation
return;

% --------------------------------------------------------------------
function menuPlotPixelSR_Callback(hObject, eventdata, handles)
sensorPlot([],'pixel spectral sr');
return;

% --------------------------------------------------------------------
function menuPlotColorFilters_Callback(hObject, eventdata, handles)
sensorPlot([],'color filters');
return;

% --------------------------------------------------------------------
function plotSpecCFApattern_Callback(hObject, eventdata, handles)
% Plot | Spectral Information | CFA Pattern
sensorPlot([],'CFA');
return;
% --------------------------------------------------------------------
function menuPlotIR_Callback(hObject, eventdata, handles)
sensorPlot([],'irfilter');
return;

% --------------------------------------------------------------------
function menuPlotPDSpectralQE_Callback(hObject, eventdata, handles)
sensorPlot([],'pixel spectral QE');
return;

% --------------------------------------------------------------------
function menuPlotSpecResp_Callback(hObject, eventdata, handles)
sensorPlot([],'sensor spectral qe');
return;

% --------------------------------------------------------------------
function menuPlotSensorImageTSize_Callback(hObject, eventdata, handles)
% Plot | SensorImage (True Size)
gam      = str2double(get(handles.editGam,'String'));
scaleMax = get(handles.btnDisplayScale,'Value');
sensor   = vcGetObject('sensor');

% Get voltages or digital values
bits     = sensorGet(sensor,'bits');
if isempty(bits)
    img      = sensorData2Image(sensor,'volts',gam,scaleMax);
else
    img      = sensorData2Image(sensor,'dv',gam,scaleMax);
end

if ismatrix(img)
    % imtool needs monochrome images scaled between 0 and 1
    w = vcNewGraphWin; img = img/max(img(:)); 
    imshow(img); truesize(w);
    set(w,'Name',sensorGet(sensor,'name'));
else
    ieViewer(img);
end


return;

% --------------------------------------------------------------------
function plotMccOverlay_Callback(hObject, eventdata, handles)
% Plot | MCC overlay off
% Delete the MCC boxes showing the selection

sensor = vcGetObject('sensor');
macbethDrawRects(sensor,'off');
vcReplaceObject(sensor);
sensorRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuPlotHumanCone_Callback(hObject, eventdata, handles)
% Plot | Human Cone

sensor = vcGetObject('sensor');
if sensorCheckHuman(sensor), sensorConePlot(sensor)
else ieInWindowMessage('Not a human cone sensor',handles,3);
end

return

% --------------------------------------------------------------------
function menuPlotNewGraphWindow_Callback(hObject, eventdata, handles)
vcNewGraphWin;
return;

% --------------------------------------------------------------------
function menuAnalyze_Callback(hObject, eventdata, handles)
% Analyze menu
return;

% --------------------------------------------------------------------
function menuAnLine_Callback(hObject, eventdata, handles)
% Analyze->Line menu
return;

% --------------------------------------------------------------------
function menuHorizontal_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuVertical_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnLineV_Callback(hObject, eventdata, handles)
% Analyze | Line | Vertical | Electrons
sensorPlot(vcGetObject('sensor'),'electrons vline');
%OLD:  sensorPlotLine(vcGetObject('ISA'),'v','volts','space');
return;

% --------------------------------------------------------------------
function menuAnLineH_Callback(hObject, eventdata, handles)
% Analyze | Line | Horizontal | Volts
sensorPlot(vcGetObject('sensor'),'volts hline');
return;

% --------------------------------------------------------------------
function menuHorLineE_Callback(hObject, eventdata, handles)
% Analyze | Line | Horizontal | Electrons
sensorPlot(vcGetObject('sensor'),'electrons hline');
return;

% --------------------------------------------------------------------
function menuVertLineE_Callback(hObject, eventdata, handles)
% Analyze | Line | Vertical | Electrons
sensorPlot(vcGetObject('sensor'),'electrons vline');
return;

% --------------------------------------------------------------------
function menuHorLineDV_Callback(hObject, eventdata, handles)
% sensorPlotLine(vcGetObject('sensor'),'h','dv','space');
sensorPlot(vcGetObject('sensor'),'dv hline');
return;

% --------------------------------------------------------------------
function menuVertLineDV_Callback(hObject, eventdata, handles)
% sensorPlotLine(vcGetObject('sensor'),'v','dv','space');
sensorPlot(vcGetObject('sensor'),'dv vline');
return;

% --------------------------------------------------------------------
function menuFFThor_Callback(hObject, eventdata, handles)
sensorPlotLine(vcGetObject('sensor'),'h','volts','fft');
return;

% --------------------------------------------------------------------
function menuFFTVert_Callback(hObject, eventdata, handles)
sensorPlotLine(vcGetObject('sensor'),'v','volts','fft');
return;

% --------------------------------------------------------------------
% function menuAnPixHistQ_Callback(hObject, eventdata, handles)
% plotSensorHistogram('e');
% return;

% --------------------------------------------------------------------
function menuAnPixHistV_Callback(hObject, eventdata, handles)
% Analyze | Line | Vertical | Volts
sensorPlot(vcGetObject('sensor'),'volts hist');
return;

% --------------------------------------------------------------------
function menuAnPixelSNR_Callback(hObject, eventdata, handles)
% Graph the pixel SNR as a function of voltage swing
sensorPlot(vcGetObject('sensor'),'pixel snr');
% plotPixelSNR;
return;

% --------------------------------------------------------------------
function menuAnSensorSNR_Callback(hObject, eventdata, handles)
%
plotSensorSNR;
return;

% --------------------------------------------------------------------
function menuAnROIStats_Callback(hObject, eventdata, handles)
% Analysis->ROI statistics
return;

% --------------------------------------------------------------------
function menuAnBasicV_Callback(hObject, eventdata, handles)
%
sensorStats([],'basic','volts');
return;

% --------------------------------------------------------------------
function menuAnBasicE_Callback(hObject, eventdata, handles)
sensorStats([],'basic','electrons');
return;

% ----------------------Pixel Optics-------------------
function menuAnPO_Callback(hObject, eventdata, handles)
% Analysis->Pixel Optics
return;


% --------------------------------------------------------------------
function menuAnPixOptLoadUL_Callback(hObject, eventdata, handles)
% Analyze | Pixel Optics | Load uL

fullName = vcSelectDataFile('stayPut','r');
if isempty(fullName), disp('User canceled'); return; end
tmp = load(fullName);
if isfield(tmp,'ml')
    ISA = vcGetObject('ISA');
    ISA = sensorSet(ISA,'microLens',tmp.ml);
    vcReplaceObject(ISA);
else
    error('No microlens structure (named ml) in the file.');
end

return;

% --------------------------------------------------------------------
function menuAnPixOptSaveUl_Callback(hObject, eventdata, handles)
% Analyze | Pixel Optics | Save uL

ISA = vcGetObject('ISA');
ml = sensorGet(ISA,'microLens');
fullName = vcSelectDataFile('stayPut','w');
if isempty(fullName), disp('User canceled'); return; end
save(fullName,'ml');

return;

% --------------------------------------------------------------------
function menuAnColor_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnColorRB_Callback(hObject, eventdata, handles)
% Analyze | Color | RB Analysis
sensorPlotColor(ieGetObject('ISA'),'rb');
return;

% --------------------------------------------------------------------
function menuAnColorRG_Callback(hObject, eventdata, handles)
% Analyze | Color | RG Analysis
sensorPlotColor(vcGetObject('ISA'),'rg');
return;

% --------------------------------------------------------------------
function menuAnColCCM_Callback(hObject, eventdata, handles)
% Analyze | Color | Color Conversion Matrix

sensor = vcGetObject('sensor');
[L,corners] = sensorCCM(sensor); %#ok<ASGLU>

fprintf('    ==  MCC to XYZ_D65 matrix  ==\n');
disp(L)

% Store the selection of the corners
sensor = sensorSet(sensor,'mcc corner points',corners);
vcReplaceObject(sensor);

return;

% --------------------------------------------------------------------
function menuEdgeOp_Callback(hObject, eventdata, handles)
% Start a new process to initiate the edge operator window.  
% This window works with monochrome sensor images and investigate how
% various operators perform with different types of sensors.
edgeOperatorWindow;
return;

% ------------------PlotImage------------------------------
function menuIm_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuImDSNU_Callback(hObject, eventdata, handles)
sensorPlot([],'dsnu');
return;

% --------------------------------------------------------------------
function menuImPRNU_Callback(hObject, eventdata, handles)
sensorPlot([],'prnu');
return;

% --------------------------------------------------------------------
function menuImShotNoise_Callback(hObject, eventdata, handles)
sensorPlot([],'shotnoise');
return;

% --------------------------------------------------------------------
function menuSensorLuxSec_Callback(hObject, eventdata, handles)
sensorSNRluxsec;
return;

% --------------------------------------------------------------------
function menuPixelLuxSec_Callback(hObject, eventdata, handles)
pixelSNRluxsec;
return;

% --------------------------------------------------------------------
function menuPDSize_Callback(hObject, eventdata, handles)
% Sensor | Design photodetector geometry
pixelGeometryWindow;
return;

% --------------------------------------------------------------------
% function menuPixelLayers_Callback(hObject, eventdata, handles)
% % Sensor | Design pixel layers
% pixelOEWindow;
% return;

% --------------------------------------------------------------------
function menuLoadSF_Callback(hObject, eventdata, handles)
% Load spectral functions heading.
return;

% --------------------------------------------------------------------
function menuLoadCFA_Callback(hObject, eventdata, handles)
% 
[val,ISA] = vcGetSelectedObject('ISA');
ISA = sensorReadFilter('cfa',ISA);
ISA = sensorClearData(ISA);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles); 
return;

% --------------------------------------------------------------------
function menuColorFilters_Callback(hObject, eventdata, handles)
% Sensor | Load Color Filters
[val,ISA] = vcGetSelectedObject('ISA');
ISA = sensorReadFilter('colorfilters',ISA);
ISA = sensorClearData(ISA);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuInfraRed_Callback(hObject, eventdata, handles)
[val,ISA] = vcGetSelectedObject('ISA');
ISA = sensorReadFilter('infrared',ISA);
ISA = sensorClearData(ISA);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);         
return;

% --------------------------------------------------------------------
function menuPDQE_Callback(hObject, eventdata, handles)
[val,ISA] = vcGetSelectedObject('ISA');
ISA = sensorReadFilter('pdspectralqe',ISA);
ISA = sensorClearData(ISA);
vcReplaceObject(ISA,val);
sensorRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditFontSize_Callback(hObject, eventdata, handles)
% Edit | Change font size
ieFontSizeSet(handles.sensorImageWindow);
return;

% --------------------------------------------------------------------
function menuAnalyzeMicroLens_Callback(hObject, eventdata, handles)
% Analyze | Pixel Optics | Microlens window
if isempty(which('microLensWindow'))
    warndlg('No micro lens analysis software on your path.  Contact ImagEval for a license.');
    return;
else
    % Should test for license here
end

microLensWindow;
return;

% --------------------------------------------------------------------
function menuAnPOShowUL_Callback(hObject, eventdata, handles)
ISA = vcGetObject('ISA');
mlPrint(sensorGet(ISA,'microLens'));
return;

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAppNotes_Callback(hObject, eventdata, handles)
% Help | Documentation (web)
ieManualViewer('imageval code');
return;

% --------------------------------------------------------------------
function menuHelpSensorOnline_Callback(hObject, eventdata, handles)
% Help | Sensor (online)
ieManualViewer('sensor functions');
return;

% --------------------------------------------------------------------
function menuHelpPixelOnline_Callback(hObject, eventdata, handles)
% Help | Pixel (online)
ieManualViewer('pixel functions');
return;

% --------------------------------------------------------------------
function menuHelpISETOnlineManual_Callback(hObject, eventdata, handles)
% Help | ISET (online)
ieManualViewer('iset functions')
return;

% --- Executes during object creation, after setting all properties.
function popupExpMode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

return;
% --- Executes on selection change in popupExpMode.
function popupExpMode_Callback(hObject, eventdata, handles)
% Exposure popup control
%
% Hints: contents = get(hObject,'String') returns popupExpMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupExpMode

sensor = vcGetObject('sensor');

% Determine which case we popped into
contents = get(hObject,'String');
switch contents{get(hObject,'Value')}
    case 'Single'
        set(handles.btnAutoExp,'visible','on');
        set(handles.editExpTime,'visible','on');
        set(handles.btnShowCFAExpDurations,'visible','off');
        set(handles.editNExposures,'visible','off');
        set(handles.editExpFactor,'visible','off');
        set(handles.sliderSelectBracketedExposure,'visible','off');
        set(handles.txtBracketExposure,'visible','off');
        
        eTime  = sensorGet(sensor,'geometricMeanExposureTime');
        sensor = sensorSet(sensor,'expTime',eTime);

    case 'Bracketing'
        set(handles.editExpTime,'visible','on');
        set(handles.sliderSelectBracketedExposure,'visible','on');
        set(handles.editNExposures,'visible','on');
        set(handles.editExpFactor,'visible','on');
        set(handles.btnShowCFAExpDurations,'visible','off');

        set(handles.btnAutoExp,'visible','off');
        set(handles.txtBracketExposure,'visible','on');
        
        % Manage the bracket times
        sensor = sensorAdjustBracketTimes(handles,sensor);
        
    case 'CFA Exposure'
        set(handles.btnAutoExp,'visible','on');
        set(handles.btnShowCFAExpDurations,'visible','on');
        set(handles.editExpTime,'visible','off');
        set(handles.editNExposures,'visible','off');
        set(handles.editExpFactor,'visible','off');
        set(handles.sliderSelectBracketedExposure,'visible','off');
        set(handles.txtBracketExposure,'visible','off');
        
        sensor = sensorAdjustCFATimes(handles,sensor);
        
    otherwise
        error('Unknown exposure condition %s\n',contents{get(hObject,'Value')});
end

sensor = sensorClearData(sensor);
vcReplaceObject(sensor);
sensorRefresh(hObject, eventdata, handles);
return;

% --- Executes during object creation, after setting all properties.
function editNExposures_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editNExposures_Callback(hObject, eventdata, handles)
% Set the number of exposures in the bracketing mode
sensor = vcGetObject('sensor');
sensor = sensorAdjustBracketTimes(handles,sensor);
sensor = sensorClearData(sensor);
vcReplaceObject(sensor);
sensorRefresh(hObject, eventdata, handles);
return;

% --- Executes during object creation, after setting all properties.
function editExpFactor_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;
function editExpFactor_Callback(hObject, eventdata, handles)
% Set the scale factor between exposures in bracketing mode
%
% Hints: get(hObject,'String') returns contents of editExpFactor as text
%        str2double(get(hObject,'String')) returns contents of editExpFactor as a double
sensor = sensorAdjustBracketTimes(handles);
sensor = sensorClearData(sensor);
vcReplaceObject(sensor);
sensorRefresh(hObject, eventdata, handles);
return;

% --- Executes on button press in btnShowCFAExpDurations.
function btnShowCFAExpDurations_Callback(hObject, eventdata, handles)
% Bring up a gui that shows the CFA exposures

sensor = vcGetObject('sensor');

% Make sure we are in the CFA format
sensor = sensorAdjustCFATimes(handles,sensor);

% Put the exposureData matrix into the base workspace in ms
fmt    = '%.1f'; 
prompt = 'Time (ms)';
defMatrix = sensorGet(sensor,'expTime')*1e3;
saturation = 0.3;
filterRGB = sensorFilterRGB(sensor,saturation);
ieReadSmallMatrix(size(defMatrix),defMatrix,fmt,prompt,[],'msExposureData',filterRGB);

%Read base space data in seconds
secExposureData = evalin('base','msExposureData')*1e-3;  

% Put the sensor back
sensor = sensorSet(sensor,'expTime',secExposureData);
vcReplaceObject(sensor);

return;

% --- Executes during object creation, after setting all properties.
function sliderSelectBracketedExposure_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
       
end
% --- Executes on slider movement.
function sliderSelectBracketedExposure_Callback(hObject, eventdata, handles)
% Slider on the lower left of the window
% Chooses which of the exposures to display
sensor = vcGetObject('sensor');

exposurePlane = get(handles.sliderSelectBracketedExposure,'value');
sensor = sensorSet(sensor,'exposurePlane',exposurePlane);
sensor = sensorSet(sensor,'consistency',-1);  % Don't change the red consistency button

vcReplaceObject(sensor);
sensorRefresh(hObject, eventdata, handles);

return;

% --- Executes any time we need to update the bracketed exposures.
function sensor = sensorAdjustBracketTimes(handles,sensor)
% Examine the bracket settings edit boxes and adjust the exposure times
%
% Another display mode is needed for multiple exposure times that are not
% necessarily in bracketed mode.

% This can be called by editing the exp time box or the nExposures or the
% scale factor on exposures.
%
% If it is called from the exp time box, then we get the sensor passed in.
% Otherwise we use the default sensor.
if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

% Require odd exposure number.  Update the edit box with the right number
nExposures = str2double(get(handles.editNExposures,'String'));
if ~isodd(nExposures), nExposures = nExposures + 1; end
set(handles.editNExposures,'String',num2str(nExposures));

% Create the exposure list from GUI data
sFactor         = str2double(get(handles.editExpFactor,'String'));
centralExposure = sensorGet(sensor,'Geometric Mean Exposure Time');
nBelow          = floor(nExposures/2);
shortExposure   = centralExposure/(sFactor^nBelow);
expTimes = zeros(1,nExposures);
for ii=1:nExposures
    expTimes(ii) = shortExposure*sFactor^(ii-1);
end

% Update the sensor
sensor        = sensorSet(sensor,'Exp Time',expTimes);
exposurePlane = floor(nExposures/2) + 1;
sensor = sensorSet(sensor,'Exposure Plane',exposurePlane);

% Slider (lower left) for bracketed exposures now set in
% sensorEditsAndButtons

return;

% --- Executes any time we need to update the CFA exposures
function sensor = sensorAdjustCFATimes(handles,sensor)
% Adjust the sensor exposure time slot to match the CFA size, putting the
% sensor into the CFA exposure mode.
%

if ieNotDefined('sensor'), sensor = vcGetObject('sensor'); end

mSize = size(sensorGet(sensor,'pattern'));
eTimes = sensorGet(sensor,'expTimes');

% If the eTimes has the wrong size, use the geometric mean of the current
% eTime values and assign it to a matrix of the right size.
if ~isequal(size(eTimes),mSize)
    eTimes = ones(mSize)*sensorGet(sensor,'geometricMeanExposuretime');
    sensor = sensorSet(sensor,'expTime',eTimes);
end

return;


% --- Executes on button press in btnTruesize.
function btnTruesize_Callback(hObject, eventdata, handles)
% btnTruesize - When pushed, invoke the truesize on refresh
% 
sensorRefresh(hObject, eventdata, handles);

return;
