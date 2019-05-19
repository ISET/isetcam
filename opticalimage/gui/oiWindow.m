function varargout = oiWindow(varargin)
%Optical image window
%
%     varargout = oiWindow(varargin)
%
%  Graphical user interface to manage the ISET OPTICALIMAGE properties.
%
%  OIWINDOW, by itself, creates a new OIWINDOW or raises the existing
%  singleton*.
%
%  H = OIWINDOW returns the handle to a new OIWINDOW or the handle to
%  the existing singleton*.
%
%  H = OIWINDOW(oi) adds the oi to the database and then opens the
%  oiWindow. Equivalent to ieAddObject(oi); oiWindow;
%
%  OIWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%  function named CALLBACK in OIWINDOW.M with the given input arguments.
%
%  OIWINDOW('Property','Value',...) creates a new OIWINDOW or raises the
%  existing singleton*.  Starting from the left, property value pairs are
%  applied to the GUI before oiWindow_OpeningFunction gets called.  An
%  unrecognized property name or invalid value makes property application
%  stop.  All inputs are passed to oiWindow_OpeningFcn via varargin.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Last Modified by GUIDE v2.5 02-Oct-2016 23:46:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @oiWindow_OpeningFcn, ...
    'gui_OutputFcn',  @oiWindow_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before oiWindow is made visible.
function oiWindow_OpeningFcn(hObject, eventdata, handles, varargin)

% Permits calling as oiWindow(oi);
if ~isempty(varargin)
    oi = varargin{1};
    if strcmp(oi.type,'opticalimage')
        ieAddObject(oi);
    end
end

oiOpen(hObject,eventdata,handles);

g = get(handles.editGamma,'String');
set(handles.editGamma,'String',g);
oiRefresh(hObject, eventdata, handles);

% If the person has set a position and size preference, put the window
% there
ISETprefs = getpref('ISET');
if isfield(ISETprefs,'wPos')
    wPos = ISETprefs.wPos;
    if ~isempty(wPos{3}), set(hObject,'Position',wPos{3}); end
end

return;

% --- Outputs from this function are returned to the command line.
function varargout = oiWindow_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;
return;

% --- Executes on button press in btnDeleteOptImg.
function oiDelete(hObject, eventdata, handles)
% Edit | Delete Current OI
vcDeleteSelectedObject('OPTICALIMAGE');
[~,oi] = vcGetSelectedObject('OPTICALIMAGE');
if isempty(oi)
    oi = oiCreate;
    vcReplaceAndSelectObject(oi,1);
end

oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditDeleteSome_Callback(hObject, eventdata, handles)
% Edit | Delete Some OIs
vcDeleteSomeObjects('oi');
oiRefresh(hObject, eventdata, handles);
return;

% --- Executes during object creation, after setting all properties.
function SelectOptImg_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in SelectOptImg.
function SelectOptImg_Callback(hObject, eventdata, handles)

oiNames = get(hObject,'String');
thisName = oiNames{get(hObject,'Value')};

switch lower(thisName)
    case 'new'
        oiNew(hObject, eventdata, handles);
    otherwise
        val = get(hObject,'Value') - 1;      val = max(1,val);
        nS = ieSessionGet('nobjects','oi');  val = min(val,nS);
        vcSetSelectedObject('OPTICALIMAGE',val);
end
oiRefresh(hObject, eventdata, handles);

return

% --- Executes on button press in btnPrev.
function btnPrev_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% Button to move to previous image
s  = ieSessionGet('selected','oi');
nS = ieSessionGet('nobjects','oi');
s = min(s - 1,nS);
s = max(s,1);
vcSetSelectedObject('oi',s);
oiRefresh(hObject, eventdata, handles);
return;

% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles)
% Button to move to previous image
s  = ieSessionGet('selected','oi');
nS = ieSessionGet('nobjects','oi');
s = min(s + 1,nS);
s = max(s,1);
vcSetSelectedObject('oi',s);
oiRefresh(hObject, eventdata, handles);
return;

function oiRefresh(hObject, eventdata, handles)
oiSetEditsAndButtons(handles);
return;

%%%%%%%%%%%%%%%%%%%% Menus are controlled below here %%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSaveImage_Callback(hObject, eventdata, handles)

oi = ieGetObject('OPTICALIMAGE');
oiSaveImage(oi,[]);

return;

% --------------------------------------------------------------------
function menuFileClose_Callback(hObject, eventdata, handles)
oiClose;
return;

% --------------------------------------------------------------------
function EditMenu_Callback(hObject, eventdata, handles)
return;

% --- Executes during object creation, after setting all properties.Ex
function editFnumber_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

%---------------------------------
function editFnumber_Callback(hObject, eventdata, handles)

fNumber = str2double(get(hObject,'String'));

[val,oi] = vcGetSelectedObject('OPTICALIMAGE');

optics = oiGet(oi,'optics');
optics.fNumber = fNumber;

oi.optics = optics;
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;

% --- Executes during object creation, after setting all properties.
function editFocalLength_CreateFcn(hObject, eventdata, handles)

if ispc, set(hObject,'BackgroundColor','white');
else, set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editFocalLength_Callback(hObject, eventdata, handles)

% Read the edit box
focalLength = str2double(get(hObject,'String'))/1000;

% Get the current OI, or create one.
[val,oi] = vcGetSelectedObject('OPTICALIMAGE');

% Get the optics from the OI and set the focal length
% Focal length is displayed in millimeters but stored in meters
optics = oiGet(oi,'optics');
optics.focalLength = focalLength;

% Put the OI back in the global structure.
oi.optics = optics;
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);

return;

% --- Executes during object creation, after setting all properties.
function editDefocus_CreateFcn(hObject, eventdata, handles)

if ispc, set(hObject,'BackgroundColor','white');
else, set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on button press in btnSimulate.
function btnSimulate_Callback(hObject, eventdata, handles)
% This call back reads the current scene and optics and then calculates a
% the optical image irradiance with the current parameters.   We do not
% calculate a new optical image. Probably, we should put this in a separate
% function rather than keeping it in here.

scene = ieGetObject('scene');
if isempty(scene), ieInWindowMessage('No scene data.',handles); beep; return;
else, ieInWindowMessage('',handles); end

[~,oi] = vcGetSelectedObject('OPTICALIMAGE');

% We now check within oiCompute whether the custom button is selected or
% not.
oi = oiCompute(scene,oi);

oi = oiSet(oi,'consistency',1);

% Save the OI in the vcSESSION as the selected optical image.
vcReplaceAndSelectObject(oi);

% hObject = oiwindow;
oiRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuFileLoadOI_Callback(hObject, eventdata, handles)

newVal = vcImportObject('OPTICALIMAGE');
vcSetSelectedObject('OPTICALIMAGE',newVal);
oiRefresh(hObject, eventdata, handles);

return;


% --------------------------------------------------------------------
function menuFileSaveOI_Callback(hObject, eventdata, handles)

[~,oi] = vcGetSelectedObject('OPTICALIMAGE');
vcSaveObject(oi);

return;


% --- Executes during object creation, after setting all properties.
function editGamma_CreateFcn(hObject, eventdata, handles)

if ispc, set(hObject,'BackgroundColor','white');
else, set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

return;

function editGamma_Callback(hObject, eventdata, handles)
% When we refresh the GUI the value is read and the image is displayed
% with the new gamma value.
oiRefresh(hObject,eventdata,handles);
return;


% --- Executes on selection change in popupDisplay.
function popupDisplay_Callback(hObject, eventdata, handles)
% When we refresh, the rendering method is read and the oiShowImage
% calls the relevant rendering routine.
%
% Hints: contents = get(hObject,'String') returns popupDisplay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupDisplay
oiRefresh(hObject, eventdata, handles);
return

% --- Executes during object creation, after setting all properties.
function popupDisplay_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc, set(hObject,'BackgroundColor','white');
else, set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return

% --- Executes on button press in btnNew.
function oiNew(hObject, eventdata, handles)

[~, newOI] = vcGetSelectedObject('opticalimage');
% newVal = vcNewObjectValue('opticalimage');
newOI.name = vcNewObjectName('opticalimage');
newOI.type = 'opticalimage';
newOI = oiClearData(newOI);

ieAddObject(newOI)
oiRefresh(hObject, eventdata, handles);

return;


% --------------------------------------------------------------------
function menuOptTrans_Callback(hObject, eventdata, handles)
% Read the optical transmittance in wavelength
%
%  We could use a function that multiplies the transmittance by another
%  function, such as a lens or macular pigment transmittance.  As things
%  stand we load a transmittance, but we should probably have a function
%  that gets the existing one and multipllies it by another.

[val,oi] = vcGetSelectedObject('OI');
optics = oiGet(oi,'optics');
wave = opticsGet(oi,'wave');

fullName = vcSelectDataFile('optics');
if isempty(fullName), return;
else,                 optics = opticsSet(optics,'transmittance',ieReadSpectra(fullName,wave));
end

oi = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);
return;

% --------------------------------------------------------------------
function menuFileRefresh_Callback(hObject, eventdata, handles)
oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditScale_Callback(hObject, eventdata, handles)
% Scale irradiance levels by s

s = ieReadNumber('Enter scale factor',1,' %.2f');
if isempty(s), return; end

[val,oi] = vcGetSelectedObject('OPTICALIMAGE');
irrad = oiGet(oi,'photons');
if isempty(irrad)
    handles = ieSessionGet('opticalimagehandle');
    ieInWindowMessage('Can not scale:  No irradiance data.',handles,[]);
else
    handles = ieSessionGet('opticalimagehandle');
    ieInWindowMessage('',handles,[]);
end

ill = oiGet(oi,'illuminance');
meanIll = oiGet(oi,'meanIlluminance');

oi = oiSet(oi,'compressedPhotons',irrad*s);
if ~isempty(ill), oi = oiSet(oi,'illuminance',s*ill); end
if ~isempty(meanIll), oi = oiSet(oi,'meanIlluminance',s*meanIll); end

vcReplaceAndSelectObject(oi,val)
oiRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditFontSize_Callback(hObject, eventdata, handles)
% Edit | Change font size
ieFontSizeSet(handles.figure1);
return;

% --------------------------------------------------------------------
function menuEditName_Callback(hObject, eventdata, handles)

[val,oi] = vcGetSelectedObject('OPTICALIMAGE');
newName = ieReadString('New optical image name','new-oi');

if isempty(newName),  return;
else,    oi = oiSet(oi,'name',newName);
end

vcReplaceAndSelectObject(oi,val)
oiRefresh(hObject, eventdata, handles);

return;
% --------------------------------------------------------------------
function menuCopyOI_Callback(hObject, eventdata, handles)

[~,oi] = vcGetSelectedObject('OI');

newName = ieReadString('New optical image name','new-oi');
if isempty(newName),  return;
else,    oi = oiSet(oi,'name',newName);
end

ieAddObject(oi);
oiRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditDelete_Callback(hObject, eventdata, handles)
oiDelete(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditCreate_Callback(hObject, eventdata, handles)
oiNew(hObject, eventdata, handles);
return;

function menuEditClearMessage_Callback(hObject, eventdata, handles)
ieInWindowMessage('',ieSessionGet('opticalimagehandle'),[]);
return;

% --------------------------------------------------------------------
function menuEditZoom_Callback(hObject, eventdata, handles)
zoom
return;

% --------------------------------------------------------------------
function menuEditViewer_Callback(hObject, eventdata, handles)
oi = ieGetObject('oi');
img = oiGet(oi,'photons');
rgb = imageSPD(img,oiGet(oi,'wavelength'));
ieViewer(rgb);
return;

% --------------------------------------------------------------------
function menuOptics_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuOpticsHalfInch_Callback(hObject, eventdata, handles)

[val, oi] = vcGetSelectedObject('OPTICALIMAGE');
oi = oiClearData(oi);
optics = opticsCreate('standard (1/2-inch)');
oi  = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);

oiRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuOpticsQuarterInch_Callback(hObject, eventdata, handles)

[val, oi] = vcGetSelectedObject('OPTICALIMAGE');
oi = oiClearData(oi);
optics = opticsCreate('standard (1/4-inch)');
oi  = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuOpticsThird_Callback(hObject, eventdata, handles)
[val, oi] = vcGetSelectedObject('OPTICALIMAGE');

optics = opticsCreate('standard (1/3-inch)');
oi.optics = optics;
oi.data = [];
oi = sceneClearData(oi);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuOpticsTwoThirds_Callback(hObject, eventdata, handles)

[val, oi] = vcGetSelectedObject('OPTICALIMAGE');
optics = opticsCreate('standard (2/3-inch)');
oi.optics = optics;
oi = sceneClearData(oi);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuOpticsInch_Callback(hObject, eventdata, handles)

[val, oi] = vcGetSelectedObject('OPTICALIMAGE');

optics = opticsCreate('standard (1-inch)');
oi.optics = optics;
oi = sceneClearData(oi);
vcReplaceObject(oi,val);

oiRefresh(hObject, eventdata, handles);
return;
% --------------------------------------------------------------------
function menuHuman_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuMacular028_Callback(hObject, eventdata, handles)
% These are not updated, as per ISETBIO.
% We should probably remove from ISET, or update.
%
[val,oi] = vcGetSelectedObject('OPTICALIMAGE');
oi = humanMacularTransmittance(oi,0.28);
vcReplaceObject(oi,val);

oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuMacular_Callback(hObject, eventdata, handles)
% These are not updated, as per ISETBIO.
% We should probably remove from ISET, or update.
%
[val,oi] = vcGetSelectedObject('OPTICALIMAGE');

dens = ieReadNumber('Enter macular density',0.28,' %.2f');
oi = humanMacularTransmittance(oi,dens);
vcReplaceObject(oi,val);

oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuOpticsHuman_Callback(hObject, eventdata, handles)
% These are not updated, as per ISETBIO.
% We should probably remove from ISET, or update.

[val, oi] = vcGetSelectedObject('OPTICALIMAGE');

oi = oiClearData(oi);
optics = opticsCreate('human');
optics = opticsSet(optics,'otfMethod','humanOTF');

oi = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuOpticsImport_Callback(hObject, eventdata, handles)
% Optics | Import Optics
vcImportObject('OPTICS');
oiRefresh(hObject,eventdata,handles);
return;

% --------------------------------------------------------------------
function menuOpticsRename_Callback(hObject, eventdata, handles)
% Optics | Re-name

oi = ieGetObject('OI');
optics = oiGet(oi,'optics');

if oiGet(oi,'customCompute')
    name = ieReadString('Enter new ray trace optics name');
    if isempty(name), return; end
    optics = opticsSet(optics,'rtname',name);
else
    name = ieReadString('Enter new diffraction limited optics name');
    if isempty(name), return; end
    optics = opticsSet(optics,'name',name);
end
oi = oiSet(oi,'optics',optics');

vcReplaceObject(oi);
oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuOpticsRayTraceParam_Callback(hObject, eventdata, handles)
% Optics | Ray Trace Params

disp('Not yet implemented')

%  This is the old code.  In the future, we may use this for setting the
%  eccentricity and angle sample spacing for the PSF interpolation
%
% [val, oi] = vcGetSelectedObject('OPTICALIMAGE');
% optics = oiGet(oi,'optics');
%
% spacingMM = opticsGet(optics,'rtComputeSpacing','mm');
% if isempty(spacingMM), spacingMM = 0.2; end
%
% spacingMM = ieReadNumber('Wedge size for PSF computation (mm)',spacingMM,' %.3f');
% if isempty(spacingMM) return; end
%
% % Data are stored in meters
% optics = opticsSet(optics,'rtComputeSpacing',spacingMM/1000);
% oi = oiSet(oi,'optics',optics);
% vcReplaceObject(oi,val);
%
% oiRefresh(hObject,eventdata,handles);
%
% return;
return;


% --------------------------------------------------------------------
function menuOpticsExports_Callback(hObject, eventdata, handles)

[~,optics] = vcGetSelectedObject('OPTICS');
vcExportObject(optics);

return;

% --------------------------------------------------------------------
function menuOpticsLoadSI_Callback(hObject, eventdata, handles)
% Optics | Load SI data

% The user selects a file containing the shift-invariant data.
[val, oi] = vcGetSelectedObject('OPTICALIMAGE');
optics = siSynthetic('custom',oi);
oi     = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);

return;

% --------------------------------------------------------------------
function menuOpticsConvertCV_Callback(hObject, eventdata, handles)
% Optics | Convert Code V

if isempty(which('rtRootPath')), warndlg('Optics toolbox not installed. Contact ImagEval'); return; end

[val, oi] = vcGetSelectedObject('OPTICALIMAGE');
optics = oiGet(oi,'OPTICS');
optics = rtImportData(optics,'Code V');

% Replace the optics.
oi = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuOpticsConvertZM_Callback(hObject, eventdata, handles)
%
% Optics | Convert Zemax

if isempty(which('rtRootPath'))
    warndlg('Optics toolbox not installed. Contact ImagEval'); 
    return; 
end

[val, oi] = vcGetSelectedObject('OPTICALIMAGE');
optics = oiGet(oi,'OPTICS');
optics = rtImportData(optics,'Zemax');

% Replace the optics.
oi = oiSet(oi,'optics',optics);

vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function PlotMenu_Callback(hObject, eventdata, handles)
% Plot Menu
return;

% --------------------------------------------------------------------
function plotIrradiance_Callback(hObject, eventdata, handles)
% Plot | Irradiance (photons)
oi = ieGetObject('oi');
oiPlot(oi,'irradiance photons roi');
return;

% --------------------------------------------------------------------
function menuPlotIrradEnergy_Callback(hObject, eventdata, handles)
% Plot | Irradiance (energy)
oi = ieGetObject('oi');
oiPlot(oi,'irradiance energy roi');
return;

% --------------------------------------------------------------------
function menuPlotImageGrid_Callback(hObject, eventdata, handles)
% Plot | Image (RGB, grid)
oiPlot(ieGetObject('oi'),'irradiance image with grid');
return;

% --------------------------------------------------------------------
function menuPlotDepthmap_Callback(hObject, eventdata, handles)
% Plot | Depth Map

oi = ieGetObject('oi');
if isempty(oiGet(oi,'depth map'))
    handles = ieSessionGet('optical image handle');
    ieInWindowMessage('No depth data.',handles,3);
else
    oiPlot(oi,'depth map');
end

return

% --------------------------------------------------------------------
function menuPlotDepthContour_Callback(hObject, eventdata, handles)
% Plot | Depth Contour

oi = ieGetObject('oi');
if isempty(oiGet(oi,'depth map'))
    handles = ieSessionGet('optical image handle');
    ieInWindowMessage('No depth data.',handles,3);
else
    oiPlot(oi,'depth map contour');
end

return


% --------------------------------------------------------------------
function menuPlotHLContrast_Callback(hObject, eventdata, handles)
% Might never be called.  If it is, it is from Analyze pull down.
oi = ieGetObject('OPTICALIMAGE');
oiPlot(oi,'hline contrast');
return;


% --------------------------------------------------------------------
function menuPlotVLContrast_Callback(hObject, eventdata, handles)
% Might never be called.  If it is, it is from Analyze pull down.
oi = ieGetObject('OPTICALIMAGE');
oiPlot(oi,'vlinecontrast');
return;

% --------------------------------------------------------------------
function menuPlotIllumLog_Callback(hObject, eventdata, handles)

[val,oi] = vcGetSelectedObject('OI');

if ~checkfields(oi,'data','illuminance')
    illuminance = oiCalculateIlluminance(oi);
    oi = oiSet(oi,'illuminance',illuminance);
    vcReplaceObject(oi,val);
end

% Plots log10 or linear luminance,
% oiPlotIlluminance(oi,'log');
oiPlot(oi,'illuminance mesh log');

return;

% --------------------------------------------------------------------
function menuPlotIllumLin_Callback(hObject, eventdata, handles)

[val,oi] =  vcGetSelectedObject('OPTICALIMAGE');

if ~checkfields(oi,'data','illuminance')
    [oi.data.illuminance, oi.data.meanIll] = oiCalculateIlluminance(oi);
    vcReplaceObject(oi,val);
end
% Plots log10 or linear luminance,
oiPlot(oi,'illuminance mesh linear');

return;

% --------------------------------------------------------------------
function menuPlotCIE_Callback(hObject, eventdata, handles)
%
oi = ieGetObject('OI');
oiPlot(oi,'chromaticity roi');
return

% --------------------------------------------------------------------
function menuPlotNewGraphWin_Callback(hObject, eventdata, handles)
vcNewGraphWin;
return;

% --------------------------------------------------------------------
function menuPlOp_Callback(hObject, eventdata, handles)
% Plot -> Optics
return;

% --------------------------------------------------------------------
function menuTransmittance_Callback(hObject, eventdata, handles)
% Analyze | Optics | Transmittance
opticsPlotTransmittance(ieGetObject('OPTICALIMAGE'));
return;

% --------------------------------------------------------------------
function menuAnPSFMovie_Callback(hObject, eventdata, handles)
psfMovie;
return;

% --------------------------------------------------------------------
function menuPlotPS550_Callback(hObject, eventdata, handles)
% Analyze | Optics | PSF Mesh (550)

oi = ieGetObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(oi,'psf',550);
    otherwise
        oiPlot(oi,'psf 550');
end
return;

% --------------------------------------------------------------------
function menuPlotLSWave_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% Analyze | Optics | LS by Wavelength

oi = ieGetObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        ieInWindowMessage('Ray trace: ls wavelength not yet implemented.',handles);
        disp('Not yet implemented')
    otherwise
        oiPlot(oi,'ls Wavelength');
end

return;

% --------------------------------------------------------------------
function menuPlOTFWave_Callback(hObject, eventdata, handles)
% Analyze | Optics | OTF 1d by wave

oi = ieGetObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(oi,'otf');
    otherwise
        oiPlot(oi,'otf Wavelength');
end

return;

% --------------------------------------------------------------------
function menuOTFAnyWave_Callback(hObject, eventdata, handles)
% Analyze | Optics | OTF
% User selects wavelength and plots OTF

oi = ieGetObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(oi,'otf');
    otherwise
        oiPlot(oi,'otf');
end

return;

% --------------------------------------------------------------------
function plotOTF_Callback(hObject, eventdata, handles)
% Analyze | Optics | OTF (550)
%

oi = ieGetObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(oi,'otf 550');
    otherwise
        oiPlot(oi,'otf 550');
end

return;

% --------------------------------------------------------------------
function menuPlotOffAxis_Callback(hObject, eventdata, handles)
% Analyze | Optics | Off-Axis fall-off

oi = ieGetObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(ieGetObject('OI'),'relativeIllumination');
    otherwise
        opticsPlotOffAxis(ieGetObject('OI'));    % If  no ray trace, cos4th.
end

return;

% --------------------------------------------------------------------
function menuPlCIE_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAn_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnOpImFieldAndWave_Callback(hObject, eventdata, handles)
% Analyze | Optics | PSF images (rt)

oi = ieGetObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(oi,'psfimages');
    otherwise
        ieInWindowMessage('No psf images for SI and diffraction.',handles);
        disp('Not yet implemented')
end

return;

% --------------------------------------------------------------------
function menuAnOpticsPSF_Callback(hObject, eventdata, handles)
% Analyze | Optics | PSF

oi          = ieGetObject('OPTICALIMAGE');
optics      = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(oi,'psf');
    otherwise
        oiPlot(oi,'psf');
end

return;

% --------------------------------------------------------------------
function menuAnalyzeLinePlots_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnLineIllum_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnLineIllumHorizontal_Callback(hObject, eventdata, handles)
oiPlot(ieGetObject('OI'),'illuminance hline');
return;

% --------------------------------------------------------------------
function menuAnLineIllumVertical_Callback(hObject, eventdata, handles)
oiPlot(ieGetObject('OI'),'illuminance vline');
return;

% --------------------------------------------------------------------
function menuAnLineIllumHorFFT_Callback(hObject, eventdata, handles)
oiPlot(ieGetObject('OI'),'illuminance fft hline');
return;

% --------------------------------------------------------------------
function menuAnLineIllumVertFFT_Callback(hObject, eventdata, handles)
oiPlot(ieGetObject('OI'),'illuminance fft vline');
return;

% --------------------------------------------------------------------
function menuAnOptSampling_Callback(hObject, eventdata, handles)
% The image sampling rate supports a certain spatial frequency. The
% diffraction limited optics supports a certain spatial frequency. We only
% obtain a very accurate spatial representation when the image sampling
% supports a representation as high as the diffraction limited optics.
% Otherwise, the higher spatial frequencies are not represented in the
% result.
%
% In many cases, people will leave the lower sampling rate, which provides
% speed but blurs the image, because they are interested in other features
% of the simulation.
oi = ieGetObject('oi');
inCutoff = opticsGet(oiGet(oi,'optics'),'maxincutoff','mm');
maxFres = oiGet(oi,'maxFreqRes','mm');
str = sprintf('DL cutoff: %.2f - Samp cutoff %.2f (cyc/mm)\n',inCutoff,maxFres);
ieInWindowMessage(str,handles);
return;

% --------------------------------------------------------------------
function menuROISummaries_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnalyzeOptFieldD_Callback(hObject, eventdata, handles)

if isempty(which('rtRootPath')), warndlg('Optics toolbox not installed. Contact ImagEval'); return; end

oi     = ieGetObject('OI');
optics = oiGet(oi,'optics');
opticsModel = opticsGet(optics,'model');
switch lower(opticsModel)
    case 'raytrace'
        rtPlot(oi,'distortion');
    otherwise
        ieInWindowMessage('No geometric distortion with diffraction limited optics',handles);
        disp('Not yet implemented')
end

return;

% --------------------------------------------------------------------
function menuPlotLuxHist_Callback(hObject, eventdata, handles)
% Analyze | ROI Summary | Illuminance
oi = ieGetObject('OI');
oiPlot(oi,'illuminance roi');
return;

% --------------------------------------------------------------------
function menuPlotRGB_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% Plot | Image (RGB)
% Plots the current RGB image in a separate window
imageMultiview('oi',vcGetSelectedObject('oi'));
return;

% --------------------------------------------------------------------
function menuPlotMultiRGB_Callback(hObject, eventdata, handles)
% Plot | Multiple images (RGB)
% Plots the selected RGB images from all the OIs in the session
imageMultiview('oi');
return;

% --------------------------------------------------------------------
function menuHline_Callback(hObject, eventdata, handles)
% Analyze | Line | Horizontal
oi = ieGetObject('OI');
oiPlot(oi,'hline');
return;

% --------------------------------------------------------------------
function menuVLine_Callback(hObject, eventdata, handles)
% Analyze | Line | Vertical
oi = ieGetObject('OI');
oiPlot(oi,'vline');
return;

% --------------------------------------------------------------------
function menuFFTamp_Callback(hObject, eventdata, handles)
% Analyze | FFT2dAmp
% Default is whole image and a middle wavelength

oi = ieGetObject('OI');
oiPlot(oi,'irradiance fft');

return;

% --------------------------------------------------------------------
function menuStandForm_Callback(hObject, eventdata, handles)
% Optics->StanfordFormat
return;

% --- Executes during object creation, after setting all properties.
function popCustom_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Select type of optics model
function popOpticsModel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --- Interpret the popup call back
function popOpticsModel_Callback(hObject, eventdata, handles)
% Manage optics model 
%
% The method names are in the GUI of the window.  The options are
%   Diffraction-limited
%   Shift-invariant
%   Ray trace

contents = get(handles.popOpticsModel,'String');

method = contents{get(handles.popOpticsModel,'Value')};

oi = ieGetObject('oi');
optics = oiGet(oi,'optics');

switch lower(method)
    case 'diffraction-limited'
        optics = opticsSet(optics,'model','diffraction limited');
    case 'shift-invariant'
        optics = opticsSet(optics,'model','shift invariant');
        if isempty(opticsGet(optics,'otfdata'))
            % Warn the user
            ieInWindowMessage('Shift-invariant OTF data not loaded.',handles,2);
            disp('Shift-invariant data not loaded')
        end
    case 'ray trace'
        if isempty(opticsGet(optics,'ray trace'))
            % Warn the user
            ieInWindowMessage('Ray trace data not loaded.',handles,2);
            disp('Ray trace data not loaded')
        end
        optics = opticsSet(optics,'model','ray trace');
    case 'iset3d'
                optics = opticsSet(optics,'model','iset3d');

    otherwise
        error('Unknown optics method');
end

oi = oiSet(oi,'optics',optics);
vcReplaceObject(oi);
oiRefresh(hObject, eventdata, handles);

return;


% --- Executes on button press in btnOffAxis.
function btnOffAxis_Callback(hObject, eventdata, handles)
% Off axis button.  Sets cos4th on or off

[val,oi] = vcGetSelectedObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');
if get(hObject,'Value')
    optics = opticsSet(optics,'offaxismethod','cos4th');
    ieInWindowMessage([],handles,[]);
else
    optics = opticsSet(optics,'offaxismethod','skip');
    ieInWindowMessage([],handles,[]);
end
oi = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;


% --- Executes during object creation, after setting all properties.
function popDiffuser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popDiffuser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --- Executes on selection change in popDiffuser.
function popDiffuser_Callback(hObject, eventdata, handles)
%  Popup selects diffuser method
%  Current methods: skip, blur, birefringent

[val,oi] = vcGetSelectedObject('OPTICALIMAGE');
contents = get(handles.popDiffuser,'String');
dMethod  = contents{get(handles.popDiffuser,'Value')};

oi = oiSet(oi,'diffuserMethod',dMethod);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);

return

% --- Executes on button press in btnDiffuser.
function btnDiffuser_Callback(hObject, eventdata, handles)
% Turn on or off diffuser simulation
% I think this is obsolete now, replaced by the popup for the diffuser
% popDiffuser
%
[val,oi] = vcGetSelectedObject('OPTICALIMAGE');
if get(hObject,'Value')
    oi = oiSet(oi,'diffuser Method','blur');
    ieInWindowMessage([],handles,[]);
else
    oi = oiSet(oi,'diffuser Method','skip');
    ieInWindowMessage([],handles,[]);
end

vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;


% --- Executes during object creation, after setting all properties.
function editDiffuserBlur_CreateFcn(hObject, eventdata, handles)
if ispc, set(hObject,'BackgroundColor','white');
else,    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editDiffuserBlur_Callback(hObject, eventdata, handles)
% Set FWHM (um) of the diffuser
%
[val,oi] = vcGetSelectedObject('OPTICALIMAGE');

% returns contents of editDiffuserBlur as a double
blur = str2double(get(hObject,'String'));

oi = oiSet(oi,'diffuserBlur',blur*10^-6);   % Stored in meters
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;


% --- Executes on button press in btnOTF.
function btnOTF_Callback(hObject, eventdata, handles)
% Button for diffraction limited OTF

[val,oi] = vcGetSelectedObject('OPTICALIMAGE');
optics = oiGet(oi,'optics');

if get(hObject,'Value')
    optics = opticsSet(optics,'otfmethod','dlMTF');
    ieInWindowMessage([],handles,[]);
else
    optics = opticsSet(optics,'otfmethod','skip');
    ieInWindowMessage([],handles,[]);
end
oi = oiSet(oi,'optics',optics);
vcReplaceObject(oi,val);
oiRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
% function menuHelpISETmanual_Callback(hObject, eventdata, handles)
% ieManualViewer('pdf','ISET_Manual');
% return;

% --------------------------------------------------------------------
function menuHelpAppNotes_Callback(hObject, eventdata, handles)
% Help | Documentation (web)
ieManualViewer('imageval code');
return;

% --------------------------------------------------------------------
function menuHelpOpticsOnline_Callback(hObject, eventdata, handles)
% Help | optics functions
ieManualViewer('optics functions');
return;

% --------------------------------------------------------------------
function menuHelpOIOnline_Callback(hObject, eventdata, handles)
% Help | Optics functions
ieManualViewer('oi functions');
return;

% --------------------------------------------------------------------
function menuHelpISETOnline_Callback(hObject, eventdata, handles)
% Help | ISET functions
ieManualViewer('iset functions');
return;


% --------------------------------------------------------------------
function menuOpticsExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuOpticsExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function btnSimulate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btnSimulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
