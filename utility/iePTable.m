function t = iePTable(obj,varargin)
% Create a table listing the object parameters
%
%   tbl = iePTable(obj,varargin);
%
% Input
%  Obj:      Can be a scene, oi, optics, sensor, pixel, IP, or camera
%  varargin: figure properties (e.g., Units, Color, Toolbar, Menubar, ...) 
%
% Returns
%  tbl:  A table object.  The window is the 'Parent'
%          (get(tbl,'Parent')).  Table parameters can be set.
%
% TODO:  Should we add to allow custom table entries?  
%        Should we make a saveas output to EPS?
%        Mathworks should have a way to make a display figure from a table
%        object.  What they do is allow you to create a uitable display
%        object, but this uitable doesn't take a table object as an input.
%        That seems wrong to me.
%
% Examples:
%  tbl = iePTable(cameraCreate);
%  tbl = iePTable(oiCreate); 
%
% Adjust the table parameters
%  tbl = iePTable(sceneCreate); set(tbl,'FontSize',24);
%
% Sets the window parameters
%  iePTable(cameraCreate,'Color',[.6 .1 .3],'MenuBar','None');
%
% (c) Stanford VISTA Team, 2014

%% Default table and window parameters
if ieNotDefined('obj') || isempty(obj), error('ISET object required.'); end

bColor   = [.8 .8 .8];  % Window background color

% Main window
hdl = vcNewGraphWin([],'upper left',...
    'Units','pixel',...
    'Color',bColor, ...
    'ToolBar','None');

% Set additional window parameters from the arguments.  Perhaps we should
% be adjusting table parameters, or do we just do that on the return?
if ~isempty(varargin) && ~isodd(length(varargin))
    for ii=1:2:length(varargin)
        set(hdl,varargin{ii},varargin{ii+1});
    end
end

%% Build table
FontSize = 14;          % Table font size
inset    = 25;          % Pixels from the left window edge

t = uitable('Parent',hdl,'Units','pixel');
pos = get(hdl,'Position');   % Lower left corner of the window
set(t, 'RowName', '');       % No numbers at left

% Not sure this is the right way to set up the size.
cWidth = round((pos(3) - 2*inset)/2);
set(t, 'Position', [inset, inset, pos(3)-2*inset, pos(4)-2*inset]);
set(t,'ColumnWidth',{cWidth});

cNames = {'Property','Value'};
cFormat = {'char','numeric'};
set(t,'ColumnName',cNames,'ColumnFormat',cFormat);

set(t,'FontSize',FontSize);

oType = vcEquivalentObjtype(obj.type);
% Handle each object a little differently
switch lower(oType)
    case 'scene'
        data = tableScene(obj);
    case 'opticalimage'
        data = tableOI(obj);
    case 'optics'
        data = tableOptics(obj);
    case 'pixel'
        data = tablePixel(obj);
    case 'isa'  % image sensor array
        data = tableSensor(obj);
    case 'vcimage'
        data = tableIP(obj);
    case 'camera'
        % Make the table a little bigger for this case
        data = tableCamera(obj);
        set(gcf,'Name',cameraGet(obj,'name'));
    case 'display'
        data = tableDisplay(obj);
    otherwise
        error('Unknown type %s\n',obj.type);
end

set(t, 'Data', data);

% Readjust the window height to accommodate the rows of the table
current = pos(3);
target  = FontSize*size(data,1)*2.5; 
delta   = target - current;

% [x,y,width,height];   Lower left corner is (0,0)
pos(4) = max(pos(4),pos(4) + delta);  % Enlarge the row height
pos(2) = min(pos(2),pos(2) - delta);  % Move the lower left corner down
set(hdl, 'Position', [pos(1), pos(2), pos(3), pos(4)]); % Enlarge window
set(t, 'Position', [inset, inset pos(3)-2*inset, pos(4)-2*inset]);

end

function data = tableScene(scene)
% iePTable(sceneCreate);
precision = 4;
data = {...
    '-----Scene-----',''
    'Name',                           sceneGet(scene,'name');
    'Field of view (horizontal, deg)',num2str(sceneGet(scene,'fov'));
    'Rows/cols',                      num2str(sceneGet(scene,'size'));
    'Height/Width (mm)',              num2str(sceneGet(scene,'height and width','mm'),precision);
    'Distance (m)',                   num2str(sceneGet(scene,'distance','m'),precision);
    'Angular res (deg/sample)',       num2str(sceneGet(scene,'angular resolution'),precision);
    'Sample spacing (mm/sample)',     num2str(sceneGet(scene,'sample spacing','mm'),precision);
    'Mean luminance',                 num2str(sceneGet(scene,'mean luminance'),precision);
    'Illuminant name',                sceneGet(scene,'illuminant name');
    };

end

function data = tableOI(oi)
% iePTable(oiCreate);

% Handle the camera case with no oi.
if isempty(oi), data = []; return; end  

% OK, we have an oi so put up the data.
precision = 3;
data = {...
    '-----Optical image-----',''
    'Name',                   oiGet(oi,'name');
    'Rows/cols',              num2str(oiGet(oi,'size'));
    'FOV (deg, horizontal)',  num2str(oiGet(oi,'fov'));
    'Resolution (um/sample)', num2str(oiGet(oi,'spatial resolution','um'),precision);
    'Mean illuminance',       num2str(oiGet(oi,'mean illuminance'),precision);
    'Area (mm^2)',            num2str(oiGet(oi,'area','mm'),precision);
    '',''
    };

% Deal with light field optical image parameters.
if isfield(oi, 'lightfield')
    lfData = {...
        '----- LF array -----',''
        'Pinholes',           num2str(oi.lightfield.pinholes);
        '',''
        };
    data = cellCombine(data,lfData);
end

oData = tableOptics(oiGet(oi,'optics'));
data = cellCombine(data,oData);

end

function data = tableOptics(optics)
% iePTable(opticsCreate);

% num2str, 2nd argument is precision
data = {...
    '-----Optics-----',''
    'Name',                  opticsGet(optics,'name');
    'Focal length (mm)',     num2str(opticsGet(optics,'focal length','mm'),1);
    'F-number',              sprintf('%.1f',opticsGet(optics,'fnumber'));
    'Aperture diameter (mm)',num2str(opticsGet(optics,'aperture diameter','mm'),2);
    '',''
    };
end

function data = tableSensor(sensor)
% iePTable(sensorCreate);

% Handle the camera case with no sensor.
if isempty(sensor), data = []; return; end 

% num2str - 2nd argument is precision
data = {
        '-----Sensor-----',''
    'Row/col',           num2str(sensorGet(sensor,'size'));
    'Exp time (s)',      num2str(sensorGet(sensor,'exp time'));
    'Size (mm)',         num2str(sensorGet(sensor,'dimension','mm'),1);
    'DSNU (V)',          num2str(sensorGet(sensor, 'dsnu level'),2);
    'PRNU (%)',          num2str(sensorGet(sensor, 'prnu level'),2);
    'Analog Gain',       num2str(sensorGet(sensor, 'analog gain'),2);
    'Analog Offset (V)', num2str(sensorGet(sensor, 'analog offset'),2);
    '',''
    };

pData = tablePixel(sensorGet(sensor,'pixel'));
data = cellCombine(data,pData);

end

function data = tablePixel(pixel)
% iePTable(pixel);

data = {
        '-----Pixel-----',''
    'Width/height (um)',      num2str(pixelGet(pixel, 'width','um'),2);
    'Fill factor',            num2str(pixelGet(pixel, 'fill factor'),2);
    'Dark voltage (V/sec)',   num2str(pixelGet(pixel, 'dark voltage'),2);
    'Read noise (V)',         num2str(pixelGet(pixel, 'read noise'),3);
    'Conversion Gain (V/e-)', num2str(pixelGet(pixel, 'conversion gain'),2);
    'Voltage Swing (V)',      num2str(pixelGet(pixel, 'voltage swing'),2);
    'Well Capacity (e-)',     num2str(pixelGet(pixel, 'well capacity'));
    '',''
    };

end

function data = tableIP(ip)
% iePtable(ipCreate)

if isempty(ip), data = []; return; end
data = {
        '-----Img Proc-----','';
        'name',                ipGet(ip,'name');
        'row, col, primaries', num2str(ipGet(ip,'result size'));
        'demosaic',            ipGet(ip,'demosaic method');
        'sensor conversion',   ipGet(ip,'sensor conversion method');
        'illuminant correct',  ipGet(ip,'illuminant correction method');
        };
end

function data = tableDisplay(display)
% iePTable(displayCreate);
data = {
        '-----Display-----','';
        'name',    displayGet(display,'name');
        'dpi',     num2str(displayGet(display,'dpi'));
        'DAC size',num2str(displayGet(display,'dac size'));
        };
    
end

function data = tableCamera(camera)
% Creates separate tables for each of the main camera components

% iePTable(cameraCreate);

% Camera table shows optics, pixel and sensor parameters.  This should be
oData = tableOI(cameraGet(camera, 'oi'));
sData = tableSensor(cameraGet(camera,'sensor'));
data  = cellCombine(oData,sData);

ipData = tableIP(cameraGet(camera,'ip'));
data  = cellCombine(data,ipData);

end

function data = cellCombine(oData,sData)
% Related to cellMerge, but works for matrices of cell arrays.

% Edge case - we only have one or the other
if isempty(oData), data = sData; return; end
if isempty(sData), data = oData; return; end

% We have both, so merge them.
oRows = size(oData,1);
sRows = size(sData,1);
data =  cell(oRows + sRows,2);
cols = size(oData,2);

for ii=1:cols
    data(1:oRows,ii) = oData(:,ii);
    data((oRows+1):end,ii) = sData(:,ii);
end

end
