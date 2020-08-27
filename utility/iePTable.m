function thisTable = iePTable(obj,varargin)
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

% Examples:
%{
 scene = sceneCreate;
 thisTable = iePTable(scene,'format','window');
%}
%{
 scene = sceneCreate;
 thisTable = iePTable(scene,'format','embed');
%}
%% Default table and window parameters

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('obj',@isstruct);
vFunc = @(x)(ismember(x,{'window','embed'}));
p.addParameter('uitable',[],@(x)(isa(x,'matlab.ui.control.Table')));
p.addParameter('format','window',vFunc);
p.addParameter('backgroundcolor',[0.8 0.8 0.8],@isvector);
p.addParameter('fontsize',14,@isscalar);
p.parse(obj,varargin{:});

format   = p.Results.format;
bColor   = p.Results.backgroundcolor;
FontSize = p.Results.fontsize;

% Main window
if isequal(format,'window')
    thisWindow = ieNewGraphWin([],'upper left','ISET Param Table', ...
        'Units','normalized',...
        'Color',bColor, ...
        'ToolBar','None');
end

% Set additional window parameters from the arguments.  Perhaps we should
% be adjusting table parameters, or do we just do that on the return?
% if ~isempty(varargin) && ~isodd(length(varargin))
%     for ii=1:2:length(varargin)
%         set(thisWindow,varargin{ii},varargin{ii+1});
%     end
% end

%% Build table

oType = vcEquivalentObjtype(obj.type);
% Handle each object a little differently
switch lower(oType)
    case 'scene'
        data = tableScene(obj,format);
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

%% Create the table in its own window or embedded format

if isequal(format,'window')
    thisWindow.Position = [0.0070    0.6785    0.25    0.25];

    thisTable = uitable('Parent',thisWindow,'Units','normalized');
    thisTable.ColumnName = {'Property','Value','Units'};
    thisTable.ColumnWidth = {200,200,200};
    thisTable.Position = [0.025 0.025, 0.95, 0.95];
    thisTable.FontSize = FontSize;
else
    if ~isempty(p.Results.uitable)
        thisTable = p.Results.uitable;
    else
        thisTable = uitable;
    end
    thisTable.ColumnName = {'Property','Value'};
    thisTable.ColumnWidth = 'auto';
    thisTable.FontName = 'Courier';
    thisTable.FontSize = getpref('ISET','fontSize') - 3;
end

thisTable.Data = data;
thisTable.RowName = '';       % No numbers at left
% thisTable.ColumnFormat = {'char','numeric'};

end

function data = tableScene(scene,format)
% iePTable(sceneCreate);
switch format
    case 'window'
        precision = 4;
        data = {...
            'Name',                     sceneGet(scene,'name'), '';
            'Field of view',            num2str(sceneGet(scene,'fov')), 'width deg';
            'Rows/cols',                num2str(sceneGet(scene,'size')),'samples';
            'Height/Width',             num2str(sceneGet(scene,'height and width','mm'),precision), 'mm';
            'Distance ',                num2str(sceneGet(scene,'distance','m'),precision), 'meters';
            'Angular res',              num2str(sceneGet(scene,'angular resolution'),precision), 'deg/samp';
            'Sample spacing',           num2str(sceneGet(scene,'sample spacing','mm'),precision), 'mm/sample';
            'Mean luminance',           num2str(sceneGet(scene,'mean luminance'),precision), 'cd/m^2 (nits)';
            'Illuminant name',          sceneGet(scene,'illuminant name'), '';
            };
    case 'embed'
        precision = 2;
        data = {...
            'FoV (width)',            num2str(sceneGet(scene,'fov'),precision);
            'Rows/cols',                num2str(sceneGet(scene,'size'));
            'Hght/Width (mm)',          num2str(sceneGet(scene,'height and width','mm'),precision+2);
            'Distance (m)',             num2str(sceneGet(scene,'distance','m'),precision);
            'Angular res (deg/samp)',   num2str(sceneGet(scene,'angular resolution'),precision);
            'Samp space (mm/sample)',     num2str(sceneGet(scene,'sample spacing','mm'),precision);
            'Mean luminance (cd/m^2)',    num2str(sceneGet(scene,'mean luminance'),precision);
            'Illuminant name',          sceneGet(scene,'illuminant name');
            };
    otherwise
        error('Unknown table format %s\n',format);
end

end

function data = tableOI(oi)
% iePTable(oiCreate);

% Handle the camera case with no oi.
if isempty(oi), data = []; return; end  

% OK, we have an oi so put up the data.
precision = 3;
data = {...
    'Name',                   oiGet(oi,'name'), '';
    'Rows/cols',              num2str(oiGet(oi,'size')), 'samples';
    'FOV ',  num2str(oiGet(oi,'fov')), 'horizontal, deg';
    'Resolution', num2str(oiGet(oi,'spatial resolution','um'),precision),'um/sample';
    'Mean illuminance',       num2str(oiGet(oi,'mean illuminance'),precision),'lux';
    'Area',            num2str(oiGet(oi,'area','mm'),precision),'mm^2';
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
    'Name',                  opticsGet(optics,'name'), '';
    'Focal length',     num2str(opticsGet(optics,'focal length','mm'),1), 'mm';
    'F-number',              sprintf('%.1f',opticsGet(optics,'fnumber')), 'dimensionless';
    'Aperture diameter',num2str(opticsGet(optics,'aperture diameter','mm'),2), 'mm';
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
