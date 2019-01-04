function varargout = ipWindow(varargin)
% Graphical user interface to manage the ISET Processor (vcimage).
%
%    varargout = ipWindow(varargin)
%
%      IPWINDOW, by itself, creates a new IPWINDOW or raises the existing
%      singleton*.
%
%      H = IPWINDOW returns the handle to a new IPWINDOW or the handle to
%      the existing singleton*.
%
%      IPWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IPWINDOW.M with the given input arguments.
%
%      IPWINDOW('Property','Value',...) creates a new IPWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ipWindow_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ipWindow_OpeningFcn via varargin.
%
% Examples:
%  Refresh the window.
%    f = ieSessionGet('vcimagefigure');
%    ipWindow('ipRefresh',f,[],guihandles(f))
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO
%  implement drawRect function below.

% Last Modified by GUIDE v2.5 10-Oct-2016 18:03:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ipWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @ipWindow_OutputFcn, ...
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


% --- Executes just before ipWindow is made visible.
function ipWindow_OpeningFcn(hObject, eventdata, handles, varargin)

% Permits calling as ipWindow(ip);
if ~isempty(varargin) && ...
        isstruct(varargin{1}) && ...
        strcmp(varargin{1}.type,'vcimage')
    ieAddObject(varargin{1});
end

ipOpen(hObject,eventdata,handles);
ipRefresh(hObject, eventdata, handles); 

ISETprefs = getpref('ISET');
if isfield(ISETprefs,'wPos')
    wPos = ISETprefs.wPos;
    if ~isempty(wPos{5}), set(hObject,'Position',wPos{5}); end
end

return;

% --- Executes on button press in btnScale.
function btnScale_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of btnScale

[val,vci] = vcGetSelectedObject('VCIMAGE');

% Should be ipSet(vci,'DisplayScale',get());
vci.render.scale = get(hObject,'Value');
vcReplaceObject(vci,val);

ipRefresh(hObject,eventdata,handles);

return;

% --- Executes on button press in btnCustomOnOff.
function btnCustomOnOff_Callback(hObject, eventdata, handles)
% On Custom button press

vci = ieGetObject('vci');

val = get(hObject,'Value');  % returns toggle state of btnCustomOnOff
vci = ipSet(vci,'customRender',val);

vcReplaceObject(vci);
ipRefresh(hObject,eventdata,handles);

return;

% --- Outputs from this function are returned to the command line.
function varargout = ipWindow_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

return;

% --- Executes on button press in rbCustomPath.
function rbCustomPath_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of rbCustomPath
ipRefresh(hObject,eventdata,handles);
return;

% --- Executes during object creation, after setting all properties.
function popCustomPath_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popCustomPath.
function popCustomPath_Callback(hObject, eventdata, handles)
%
% Managing the custom render popup.  It is initialized with
% ipComputer, Add Custom, Delete Custom, -----
% We add and delete routines from the vcSESSION.CUSTOM.procMethod list.

contents = get(handles.popCustomPath,'String'); 
method = contents{get(handles.popCustomPath,'Value')};

[val,vci] = vcGetSelectedObject('VCIMAGE');

vci = ipSet(vci,'render method',method);

vci = ipSet(vci,'consistency',0);
vcReplaceObject(vci,val);
ipRefresh(hObject,eventdata,handles);

return;

% --- Executes during object creation, after setting all properties.
function popDemosaic_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popDemosaic.
function popDemosaic_Callback(hObject, eventdata, handles)

[val,vci] = vcGetSelectedObject('VCIMAGE');

contents = get(handles.popDemosaic,'String');
method = contents{get(handles.popDemosaic,'Value')};

if strncmp(method,'----',4)
    % If the Custom List is selected by mistake, then we set the answer to
    % Bilinear, at the top.
    vci = ipSet(vci,'demosaic method','Bilinear');
else
    % We do some checking here for permissible combinations.  For example,
    % we don't have a Laplacian implemented for CMY.  So, we test for that
    % condition and disallow it here.
    isa = ieGetObject('isa');
    cOrder = sensorGet(isa,'filter Color Letters');
    filters = sort(unique(cOrder(:)))';
    switch(filters)
        case {'bgr'}
            vci = ipSet(vci,'demosaicmethod',method);
            ieInWindowMessage('',handles)

        case {'cmy'}
            switch (lower(method))
                case {'bilinear','nearest neighbor'}
                    vci = ipSet(vci,'demosaic method',method);
                    ieInWindowMessage('',handles);
                otherwise
                    ieInWindowMessage('CMY: only bilinear and nearest neighbor available.',handles)
                    vci = ipSet(vci,'demosaic method','Bilinear');
            end
        otherwise
            ieInWindowMessage('Not or (CMY/RGB) sensor: only bilinear demosaicing available.',handles)
            vci = ipSet(vci,'demosaic method','Bilinear');
    end
end

vci = ipSet(vci,'consistency',0);
vcReplaceObject(vci,val);
ipRefresh(hObject,eventdata,handles);

return;

% --- Executes during object creation, after setting all properties.
function popTransform_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --- Executes on selection change in popTransform.
function popTransform_Callback(hObject, eventdata, handles)
% popTransform - Transform processing popup
%
% Chooses between use current, enter new transform, or use adaptive methods
% Perhaps there should be a 'None' option, which just copies the sensor
% data to the result data.
%

% Read the popup string
contents = get(hObject,'String');    % Contents of the popup
s = contents{get(hObject,'Value')};  % returns selected item from

% Store it in the transform method slot
vci = ieGetObject('vcimage');
vci = ipSet(vci,'transform method',s);
vcReplaceObject(vci);
ipRefresh(hObject,eventdata,handles);

return;


% --- Executes during object creation, after setting all properties.
function popBalance_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popBalance.
function popBalance_Callback(hObject, eventdata, handles)

[val,vci] = vcGetSelectedObject('VCIMAGE');

contents = get(handles.popBalance,'String'); 
method = contents{get(handles.popBalance,'Value')};
vci = ipSet(vci,'illuminant correction method',method);

vci = ipSet(vci,'consistency',0);
vcReplaceObject(vci,val);
ipRefresh(hObject,eventdata,handles);

return;

% --- Executes on button press in btnCompute.
function btnCompute_Callback(hObject, eventdata, handles)
% Compute button

[val,vci] = vcGetSelectedObject('vcimage');
[~,sensor]  = vcGetSelectedObject('sensor');

% We require the sensor data
if isempty(sensorGet(sensor,'dvorvolts'))
    ieInWindowMessage('No sensor voltage data.',handles);
    return;
else ieInWindowMessage('',handles);
end

vci = ipCompute(vci,sensor);
vci = ipSet(vci,'consistency',1);
vcReplaceObject(vci,val);

ipRefresh(hObject,eventdata,handles);

return;

% --------------------------------------------------------------------
function menuAnComputeFromSensor_Callback(hObject, eventdata, handles)
btnCompute_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnComputeFromScene_Callback(hObject, eventdata, handles)
%
% Recompute the OI, ISA and VCIMAGE
scene = ieGetObject('scene');
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

[val,isa] = vcGetSelectedObject('isa');
if isempty(isa)
    warndlg('Creating default sensor'); 
    isa = sensorCreate; val = 1; 
end
isa = sensorCompute(isa,oi);
vcReplaceAndSelectObject(isa,val);

btnCompute_Callback(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuComputeFromOI_Callback(hObject, eventdata, handles)
%
% Don't recompute the OI.  Just Recompute the ISA and the vcimage.

[val,oi] = vcGetSelectedObject('oi');
if isempty(oi), errordlg('No optical image'); end

[val,isa] = vcGetSelectedObject('isa');
if isempty(isa)
    warndlg('Creating default sensor'); 
    isa = sensorCreate; val = 1; 
end
isa = sensorCompute(isa,oi);
vcReplaceAndSelectObject(isa,val);

btnCompute_Callback(hObject, eventdata, handles);
return;


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuFileRefresh_Callback(hObject, eventdata, handles)
ipRefresh(hObject,eventdata,handles);
return;

% --------------------------------------------------------------------
function menuFileClose_Callback(hObject, eventdata, handles)
vcimageClose;
return;

% --------------------------------------------------------------------
function menuFileSaveProcData_Callback(hObject, eventdata, handles)
% File |  Save (.mat)
vci = ieGetObject('vcimage');

fullName = vcSelectDataFile([],'w','mat','Processor data');
if isempty(fullName), return; end

save(fullName,'vci');

return;

% --------------------------------------------------------------------
function menuFileLoadProcData_Callback(hObject, eventdata, handles)
% File | Load  (.mat)

fullName = vcSelectDataFile([],'r','mat','Processor data');
if isempty(fullName), return; end

load(fullName,'vci');

ieAddObject(vci)
ipRefresh(hObject,eventdata,handles);

return;


function menuFileLoadImage_Callback(hObject, eventdata, handles)
% File | Load Image Data

% Maybe we should put up some kind of a warning.

% Start with defaults of current image
ip = ieGetObject('vcimage');

fullName = vcSelectDataFile('stayput','r');
if isempty(fullName), return; end
scene = sceneFromFile(fullName,'rgb');
srgb = sceneGet(scene,'rgb');
% vcNewGraphWin; imagesc(srgb)

% By setting result close to lrgb, the image rendered in the display window
% is about what we see from just visualization the original image.
% But this might defeat the purpose of reading in the image file.
% lrgb = srgb2lrgb(srgb);

[p,fname] = fileparts(fullName);
ip = ipSet(ip,'name',fname);
ip = ipSet(ip,'input',[]);   % Not sure what this should be.
ip = ipSet(ip,'result',srgb);
ip = ipSet(ip,'gamma',2);

ieAddObject(ip);
ipRefresh(hObject,eventdata,handles);

return;

% --------------------------------------------------------------------
function menuFileSave_Callback(hObject, eventdata, handles)
% File | Save Image
% Write the data in the vcimage result to a file containing an RGB image.
% This works for jpg, png and other formats.  Apparently not for 'tif'.

ip = ieGetObject('VCIMAGE');

fullName = vcSelectDataFile('stayPut','w');
if isempty(fullName), return; end
[p,n,e] = fileparts(fullName);
if isempty(e), e = '.png'; fullName = [fullName, e];  end % Add ext 

gam = str2double(get(handles.editGamma,'String'));
img = imageShowImage(ip, gam, true,0);
imwrite(img,fullName);
fprintf('Saved image file %s\n',fullName);

return

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditName_Callback(hObject, eventdata, handles)
% Edit | (Re-) Name image

[val,vci] = vcGetSelectedObject('VCIMAGE');
newName = ieReadString('New vcimage name','new-vcimage');

if isempty(newName),  return; 
else                  vci = ipSet(vci,'name',newName);
end

vcReplaceAndSelectObject(vci,val)
ipRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuScaleDisplay_Callback(hObject, eventdata, handles)
% Edit | Scale data (max)
%
%  Scale the data in vci.data.result setting the largest value in the image
%  to the maximum display range.  The display values are almost always in
%  the [0,1] range.
%

[val,vci] = vcGetSelectedObject('VCIMAGE');

% Scale the displayed data so the max value is the max of the display.
vci = ipSet(vci,'result',ipGet(vci,'result scaled to max'));

vcReplaceObject(vci,val);
ipRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuScaleChooseMax_Callback(hObject, eventdata, handles)
%  Edit | Scale data (ROI)
%
%  Let the user choose a region of the image (ROI).  Find the mean of this region.
%  Scale the data values in vci.data.results so that the largest of the
%  [R,G,B] values in the ROI is set to 1 (i.e. max display intensity).
%
%  The data may be clipped by this procedure; hence, this function cannot
%  be inverted. 

[val,vci] = vcGetSelectedObject('VCIMAGE');

% Get the data from an ROI
d = vcGetROIData(vci,vcROISelect(vci),'result');
mn = mean(d(:));

img = ipGet(vci,'result')/mn;
img = ieClip(img,0,1);
vci = ipSet(vci,'result',img);

vcReplaceObject(vci,val);
ipRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuImageWhite_Callback(hObject, eventdata, handles)
% Edit | Image White Point (ROI)
%
%  Allow the user to pick a region of the image that will be used as the
%  image white point in metrics calculations. 
%  This white point is the logical one to use for deltaE
%  type calculations, as opposed to the white point of the monitor.

[val,vci] = vcGetSelectedObject('VCIMAGE');
roiLocs = vcROISelect(vci);
dataXYZ = imageDataXYZ(vci,roiLocs);
vci.data.wp = mean(dataXYZ);
vcReplaceObject(vci,val);
ipRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditResetWhite_Callback(hObject, eventdata, handles)
% Edit | Reset White
%
% Put the image white point equal to the display white point.  This allows
% the user to go back to a default position.

[val,vci] = vcGetSelectedObject('VCIMAGE');

wp = ipGet(vci,'display whitepoint');
vci = ipSet(vci,'data white point',wp);

vcReplaceObject(vci,val);
ipRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditDelete_Callback(hObject, eventdata, handles)
vcImageDelete(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuEditCreate_Callback(hObject, eventdata, handles)
% Edit | Create new image
%
% Create a new image processor that is a copy of the current one but with
% the data cleared.

ip = ieGetObject('ip');
ip = vcimageClearData(ip);

% We use this name for now and over-write when we compute
ip = ipSet(ip,'name',sprintf('copy %s',ipGet(ip,'name'))); 
ieAddObject(ip);
ipRefresh(hObject, eventdata, handles);

return;

% --------------------------------------------------------------------
function menuEditClearMessage_Callback(hObject, eventdata, handles)
ieInWindowMessage('',ieSessionGet('vcimagehandle'),[]);
return;

% --------------------------------------------------------------------
function menuEditZoom_Callback(hObject, eventdata, handles)
zoom
return;

% --------------------------------------------------------------------
function menuEditViewer_Callback(hObject, eventdata, handles)
vci = ieGetObject('vcimage');
result = ipGet(vci,'result');
ieViewer(result);
return;


% --------------------------------------------------------------------
function menuPlot_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function plotDisplaySPD_Callback(hObject, eventdata, handles)
vci = ieGetObject('VCIMAGE');
plotDisplaySPD(vci);
return;


% --------------------------------------------------------------------
% function plotColorProcessingMatrices_Callback(hObject, eventdata, handles)
% % plot | Current matrix
% % Print out the current transform matrix
% vci = ieGetObject('vci');
% T = ipGet(vci,'prodT');
% disp(T)
% return

% --------------------------------------------------------------------
function plotColorProcessingMatrices_Callback(hObject, eventdata, handles)
% Plot | Color Processing matrices

vci = ieGetObject('vci');
T = ipGet(vci,'each Transform');

fprintf('\n\n--------------------------------------------\n');
fprintf('Sensor -> Internal color space\n'),  disp(T{1})
fprintf('Illuminant correction\n'),  disp(T{2})
fprintf('Internal color space -> Display primaries\n'), disp(T{3})

% Now the product of the first three
fprintf('Color matrices combined\n'), 
T{4} = ipGet(vci,'prodT');
disp(T{4})
fprintf('--------------------------------------------\n');

return

% --------------------------------------------------------------------
function plotGamut_Callback(hObject, eventdata, handles)
ip = ieGetObject('vci');
displayPlot(ipGet(ip,'display'),'gamut');
return;

% --------------------------------------------------------------------
function newGraphWin_Callback(hObject, eventdata, handles)
vcNewGraphWin;
return;

% --- Executes during object creation, after setting all properties.
function popSelect_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popSelect.
function popSelect_Callback(hObject, eventdata, handles)

switch get(hObject,'Value')
    case 1
        % The first entry is always New.  When New is selected, we
        % create a new VCIMAGE structure.  That structure is a copy of the current
        % VCIMAGE structure with a new name.  Then we adjust the parameter
        % settings and compute a new VCIMAGE image. 
        menuEditCreate_Callback(hObject, eventdata, handles);
        
    otherwise,
        % Select one of the existing VCIMAGE objects.
        val = get(hObject,'Value') - 1;
        vcSetSelectedObject('ip',val);
end

ipRefresh(hObject, eventdata, handles);

return;

% --- Executes on button press in btnPrev.
function btnPrev_Callback(hObject, eventdata, handles)
% Show previous ip data (button next to popSelect)
s  = ieSessionGet('selected','ip');
nS = ieSessionGet('nobjects','ip');
s = min(s - 1,nS);
s = max(s,1);
vcSetSelectedObject('ip',s);
ipRefresh(hObject, eventdata, handles);
return

% --- Executes on button press in btnNext.
function btnNext_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% Show next ip data (button next to popSelect)
s  = ieSessionGet('selected','ip');
nS = ieSessionGet('nobjects','ip');
s = min(s + 1,nS);
s = max(s,1);
vcSetSelectedObject('ip',s);
ipRefresh(hObject, eventdata, handles);
return

%------------------------------------
function vcImageDelete(hObject, eventdata, handles)
% Edit | Delte Current Image

vcDeleteSelectedObject('VCIMAGE');

% What condition does this wolve?
[val,vcImage] = vcGetSelectedObject('VCIMAGE');
if isempty(val)
    vcImage = ipCreate('default');
    vcReplaceAndSelectObject(vcImage,1);
end
ipRefresh(hObject, eventdata, handles);
return

% --------------------------------------------------------------------
function menuEditDeleteSome_Callback(hObject, eventdata, handles)
% Edit | Delete Some Images
vcDeleteSomeObjects('VCI');
ipRefresh(hObject, eventdata, handles);
return

%-------------------------------------------------
function ipRefresh(hObject,eventdata,handles)
% Main refresh
ipEditsAndButtons(handles,ieGetObject('VCIMAGE'));
return;

% --------------------------------------------------------------------
function menuReadSPD_Callback(hObject, eventdata, handles)
% Display | Load
%
% Load a new display structure that will be attached to the ip.
% 

% Chooses a new default display
[val,ip] = vcGetSelectedObject('ip');
dName = vcSelectDataFile('displays');
if isempty(dName), disp('User canceled'); return; end

d   = displayCreate(dName);
ip = ipSet(ip,'display',d);

ip = vcimageClearData(ip);
vcReplaceObject(ip,val);
ipRefresh(hObject,eventdata,handles)

return;

% --- Executes during object creation, after setting all properties.
function editGamma_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

function editGamma_Callback(hObject, eventdata, handles)
% The gamma edit box is read by the refresh routine during the re-display
% of the image data.  The display gamma value is not stored in any data
% objects.
gam = str2num(get(handles.editGamma,'String'));

[val,vci] = vcGetSelectedObject('ip');
vci = ipSet(vci,'render Gamma',gam);
vcReplaceObject(vci,val);

ipRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuAnalyze_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnROI_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnLine_Callback(hObject, eventdata, handles)
% Analyze | Line intensities
return;

% --------------------------------------------------------------------
function menuAnLineH_Callback(hObject, eventdata, handles)
% Analyze | Line intensities | Horizontal
ip = ieGetObject('ip');
plotDisplayLine(ip,'h');
return;

% --------------------------------------------------------------------
function menuAnLineV_Callback(hObject, eventdata, handles)
% Analyze | Line intensities | Vertical
ip = ieGetObject('ip');   % Image proessor, same as vci
plotDisplayLine(ip,'v');
return;

% --------------------------------------------------------------------
function menuAnalyzeCreateSB_Callback(hObject, eventdata, handles)
% Analyze | Create slanted bar

% The new version of ISO MTF relies on camera structure.  So we create one.
if exist('cameraCreate','file')
    camera = cameraCreate;
    sensor = ieGetObject('sensor');
    if isempty(sensor)
        h = warndlg('No sensor defined.  Using default');
        sensor = sensorCreate;
    end
    camera = cameraSet(camera,'sensor',sensor);
else
    camera = [];
end

vci = vcimageISOMTF(camera);

ieAddObject(vci);
ipRefresh(hObject,eventdata,handles);

% If we opened the warning dialog, close it.
if exist('h','var'), close(h); end

return;

% --------------------------------------------------------------------
function menuAnalyzeSMTF_Callback(hObject, eventdata, handles)
% Not currently used

% Computes the responses to a series of harmonics. This routine assumes the
% current parameters of the optics, isa and vcimage. It passes a set of
% harmonics through these objects and analyzes the contrast of the
% resulting displayed image. We have an ISO standard that we should
% implement here. 
[rContrast,freq,fNames,rImages,sImages] = vcimageSystemMTF([],[],[],[],0);

% Bad computation returns empty value.
if isempty(rContrast), return; 
else
    
    % Plot the response contrast on the screen for each of the three display
    % primaries.  These two plotting/imaging calls should be in a separate
    % routine and they should be improved.
    figure(vcSelectFigure('GRAPHWIN'));
    clf;
    rContrast = rContrast';
    plot(freq,rContrast(:,1),'ro-',freq,rContrast(:,2),'go-',freq,rContrast(:,3),'bo-')
    str = sprintf('System MTF (sensor %s)',fNames);
    title(str);  
    xlabel('Spatial frequency (cpd)'); ylabel('Relative modulation');
    grid on
    line([0,freq(end)],[0,0],'color',[0,0,0]);
    uData.freq = freq;
    uData.rContrast = rContrast;
    uData.fNames = fNames;
    uData.rImages = rImages;
    uData.sImages = sImages;
    set(gca,'UserData',uData);
end

return

% --------------------------------------------------------------------
function menuAnColLumNoise_Callback(hObject, eventdata, handles)
% Analyze | Color and Luminance | MCC Luminance Noise
macbethLuminanceNoise;
return;

% --------------------------------------------------------------------
function menuAnColorMacbeth_Callback(hObject, eventdata, handles)
% Analyze | ???
vci = vcimageSRGB; 
ieAddObject(vci)
ipRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuAnColVisualComp_Callback(hObject, eventdata, handles)
% Analyze | Color and Luminance | Visual Compare (D65)
macbethCompareIdeal;
return;

% --------------------------------------------------------------------
function menuIm_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuPlImTrueSize_Callback(hObject, eventdata, handles)
% Plot | True size image

gam = str2double(get(handles.editGamma,'String'));
ip = vcGetObject('ip');
ip = ipSet(ip,'gamma',gam);

imageShowImage(ip,gam,true,vcNewGraphWin);

return;

% --------------------------------------------------------------------
function multipleImageRGB_Callback(hObject, eventdata, handles)
% Plot | Multiple image (RGB)
imageMultiview('vcimage');
return;

% --------------------------------------------------------------------
function menuCIE_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuPattern_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnColor_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnChrom_Callback(hObject, eventdata, handles)
% Analyze | Color and luminance | ROI | Chromaticity (xy)
vci = ieGetObject('vcimage');
plotDisplayColor(vci,'chromaticity');
return;

% --------------------------------------------------------------------
function menuAnColMCCsRGB_Callback(hObject, eventdata, handles)
% Analyze | Color | MCC Color Metrics (sRGB)
macbethColorError(ieGetObject('VCIMAGE'),[],[],'sRGB');
return;

% --------------------------------------------------------------------
function menuAnColMCCEst_Callback(hObject, eventdata, handles)
% Analyze | Color | MCC Color Metrics (custom display)
macbethColorError(ieGetObject('VCIMAGE'),[],[],'custom');
return;

% --------------------------------------------------------------------
function menuAnColorLAB_Callback(hObject, eventdata, handles)
vci = ieGetObject('VCIMAGE');
plotDisplayColor(vci,'cielab');
return;

% --------------------------------------------------------------------
function menuAnLUV_Callback(hObject, eventdata, handles)
vci = ieGetObject('VCIMAGE');
plotDisplayColor(vci,'CIELUV');
return;


% --------------------------------------------------------------------
function menuEditIPDefault_Callback(hObject, eventdata, handles)
[val,vci] = vcGetSelectedObject('vcimage');
vci.renderingMethod = 'imageval';
vcReplaceObject(vci,val);
return;


% --------------------------------------------------------------------
function menuAnLum_Callback(hObject, eventdata, handles)
vci = ieGetObject('vcimage');
plotDisplayColor(vci,'luminance');
return;

% --------------------------------------------------------------------
function menuWhitePoint_Callback(hObject, eventdata, handles)

[val,vci] = vcGetSelectedObject('VCIMAGE');

vci = displaySetWhitePoint(vci,'XYZ');
vcReplaceObject(vci,val);
ipRefresh(hObject, eventdata, handles);
return;

% --------------------------------------------------------------------
function menuCIELUV_Callback(hObject, eventdata, handles)
% Analyze | Color and luminance | ROI | CIELUV
warning('Not yet implemented.')
return;

% --------------------------------------------------------------------
function menuRGBHist_Callback(hObject, eventdata, handles)
% Analyze | Color and luminance | ROI | RGB Histogram
plotDisplayColor([],'RGB');
return;

% --------------------------------------------------------------------
function menuDisplay_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuDisplayWindow_Callback(hObject, eventdata, handles)
% Display | Display window

% Place the display for this IP in the ISET database
ip = ieGetObject('ip');
d  = ipGet(ip,'display');
ieAddObject(d);

% Place the rendered srgb data into the vcSESSION.
% This seems like a mistake to me, and we should be attaching it to the
% display object. I think we should have
%   d = displaySet(d,'rgb image');
% Check with HJ why he did it this way
global vcSESSION
vcSESSION.imgData = imageShowImage(ip,[],[],0);

% Bring up the display window.
displayWindow;

return

% --------------------------------------------------------------------
function menuDisplayViewD_Callback(hObject, eventdata, handles)
% Display | Adjust | Viewing Distance
vci = ieGetObject('vci');

val = ipGet(vci,'displayViewingDistance');
val = ieReadNumber('Viewing distance (m)',val,'%0.2f');
vci = ipSet(vci,'displayViewingDistance',val);

vcReplaceObject(vci);
return

% --------------------------------------------------------------------
function menuDisplayDPI_Callback(hObject, eventdata, handles)
% Display | Adjust | DPI
vci = ieGetObject('vci');

val = ipGet(vci,'display DPI');
val = ieReadNumber('Dots per inch (dpi)',val,'%.2f');
vci = ipSet(vci,'display DPI',val);

vcReplaceObject(vci);
return

% --------------------------------------------------------------------
function menuMetricsWindow_Callback(hObject, eventdata, handles)
metricsWindow;
return;

% --------------------------------------------------------------------
function menuDisProp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuSetLum_Callback(hObject, eventdata, handles)

[val,vci] = vcGetSelectedObject('vcimage');
vci = displaySetMaxLuminance(vci);
vcReplaceObject(vci,val);
ipRefresh(hObject,eventdata,handles);

return;

% --------------------------------------------------------------------
function menuImportFile_Callback(hObject, eventdata, handles)
warning('Import display from file not yet implemented.');
return;

% --- Executes during object creation, after setting all properties.
function popColorConversionM_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popColorConversionM.
function popColorConversionM_Callback(hObject, eventdata, handles)

[val,vci] = vcGetSelectedObject('VCIMAGE');

contents = get(handles.popColorConversionM,'String'); 
method   = contents{get(handles.popColorConversionM,'Value')};
vci      = ipSet(vci,'sensor conversion method',method);

vci = ipSet(vci,'consistency',0);
vcReplaceObject(vci,val);
ipRefresh(hObject,eventdata,handles);

return;

% --- Executes during object creation, after setting all properties.
function popColorSpace_CreateFcn(hObject, eventdata, handles)
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
return;

% --- Executes on selection change in popColorSpace.
function popColorSpace_Callback(hObject, eventdata, handles)
%
% Set internal color space for image processing

[val,vci] = vcGetSelectedObject('VCIMAGE');

contents = get(hObject,'String');
vci = ipSet(vci,'internalcs',contents{get(hObject,'Value')});
% ics = ipGet(vci,'internalcs');
 
vci = ipSet(vci,'consistency',0);
vcReplaceObject(vci,val);
ipRefresh(hObject,eventdata,handles);

return;

% --------------------------------------------------------------------
function plotMCCOverOff_Callback(hObject, eventdata, handles)
% Plot | MCC Overlay Off
%
vci = ieGetObject('vcimage');
vci = macbethDrawRects(vci,'off');
vcReplaceObject(vci);
ipRefresh(hObject,eventdata,handles);
return

% --------------------------------------------------------------------
function menuPlotDisplay_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditFontSize_Callback(hObject, eventdata, handles)
% Edit | Change Font Size

ieFontSizeSet(handles.figure1);

return;

% --------------------------------------------------------------------
function menuEditCopyImage_Callback(hObject, eventdata, handles)
warndlg('Not yet implemented');
return;

% --------------------------------------------------------------------
function menuAnROIvSNR_Callback(hObject, eventdata, handles)
% Analyze | Color and Luminance | vSNR (0.5 m)

vci = ieGetObject('vci');
dpi = ipGet(vci,'display DPI');
dist = ipGet(vci,'display Viewing Distance');

vSNR = vcimageVSNR(vci,dpi,dist);
fprintf('\n***vSNR***\n');
fprintf('Assumed dpi: %.1f and viewing distance %.2f (m)\n',dpi,dist);
fprintf('Uniform patch Visual SNR (vSNR): %f\n',vSNR)

return;

% --------------------------------------------------------------------
function menuAnalyzeISO12233_Callback(hObject, eventdata, handles)
% Analyze | ISO 12233 (Slanted Bar)
% Read a slanted bar in the display window and plot the ISO 12233 graph
%
vci = ieGetObject('VCIMAGE');

% UPDATE THIS TO USE THE NEW iso functions
figure(handles.figure1);

ieInWindowMessage('Choose rectangular ROI (short sides must intersect edge)',handles);

% Have the user select the edge.  Need more comments to the user in the
% window.
[roiLocs,rect] = vcROISelect(vci);

% rect is [col,row,colWidth,rowHeight]

% Extract the data
barImage = vcGetROIData(vci,roiLocs,'results');
c = rect(3)+1;
r = rect(4)+1;
barImage = reshape(barImage,r,c,3);
% figure; imagesc(barImage(:,:,1)); axis image; colormap(gray);

sensor = ieGetObject('ISA');
if ~isempty(sensor)
    pixel = sensorGet(sensor,'pixel');
    dx = pixelGet(pixel,'width','mm');  % Pixel width in mm
else
    fprintf('Assuming 2 um pixel');
    dx = [];
end

% Run the ISO 12233 code.  The results are stored in the window.
[results, ~, ~, fig] = ISO12233(barImage,dx);
results.rect = rect;
set(fig,'userdata',results);

ieInWindowMessage('',handles);

return;

% ----------------------------
function drawRect(hObject, eventdata, handles, rect)
% Not  implemented yet.
rectangle('Position',rect);
return;

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuHelpProcessorOnline_Callback(hObject, eventdata, handles)
% Help | Processor functions
ieManualViewer('ip functions');
return;

% --------------------------------------------------------------------
function menuHelpMetricsPG_Callback(hObject, eventdata, handles)
% Help | Metrics functions
ieManualViewer('metrics functions');
return;

% --------------------------------------------------------------------
function menuHelpISETOnline_Callback(hObject, eventdata, handles)
% Help | ISET functions
ieManualViewer('iset functions');
return;

% --------------------------------------------------------------------
function menuHelpAppNotes_Callback(hObject, eventdata, handles)
% Help | Documentation (web)
ieManualViewer('imageval code');
return;
