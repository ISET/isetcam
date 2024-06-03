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
%{
 scene = sceneCreate;
 oi = oiCreate; oi = oiCompute(oi,scene);
 thisTable = iePTable(oi,'format','window');
%}
%% Default table and window parameters

varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('obj',@isstruct);
vFunc = @(x)(ismember(x,{'window','embed'}));
p.addParameter('uitable',[],@(x)(isa(x,'matlab.ui.control.Table')));
p.addParameter('format','window',vFunc);
% p.addParameter('backgroundcolor',[0.8 0.8 0.8],@isvector);
p.addParameter('fontsize',14,@isscalar);
p.parse(obj,varargin{:});

format   = p.Results.format;
% bColor   = p.Results.backgroundcolor;
FontSize = p.Results.fontsize;

% Main window
if isequal(format,'window')
    thisWindow = uifigure('Name', "ISET Parameter Table");
    movegui(thisWindow,'northwest');
end

%% Build table

oType = vcEquivalentObjtype(obj.type);
% Handle each object a little differently
switch lower(oType)
    case 'scene'
        data = tableScene(obj,format);
        extendTitle = " for a Scene";
    case 'opticalimage'
        data = tableOI(obj,format);
        extendTitle = " for an Optical Image";
    case 'optics'
        data = tableOptics(obj,format);
        extendTitle = " for an Optics";
    case 'pixel'
        data = tablePixel(obj,format);
        extendTitle = " for a Pixel";
    case 'isa'  % image sensor array
        data = tableSensor(obj,format);
        extendTitle = " for a Sensor";
    case 'vcimage'
        data = tableIP(obj,format);
        extendTitle = " for an Imaging Pipeline";
    case 'camera'
        % Make the table a little bigger for this case
        data = tableCamera(obj,format);
        extendTitle = " for a Camera";
        % set(gcf,'Name',cameraGet(obj,'name'),format);
    case 'display'
        data = tableDisplay(obj,format);
        extendTitle = " for a Display";
        
    otherwise
        error('Unknown type %s\n',obj.type);
        
end
%% Create the table in its own window or embedded format

if isequal(format,'window')
    
    thisWindow.Name = strcat(thisWindow.Name, extendTitle);
    %can't set to normalized in 2020a
    %thisTable = uitable('Parent',thisWindow,'Units','normalized');
    thisTable = uitable('Parent', thisWindow);
    thisTable.ColumnName  = {'Property','Value','Units'};
    thisTable.ColumnWidth = {200,200,200};
    winPos = thisWindow.Position;
    thisTable.Position = [2 2 winPos(3)-2 winPos(4)-2];
    %thisTable.Position    = [0.025 0.025, 0.95, 0.95];
    thisTable.FontSize    = FontSize;
    thisTable.FontName    = 'Courier';
    thisTable.Tag = 'IEPTable Table';
    
    mnuTools = uimenu(thisWindow,'Text','File');
    
    mnuExport = uimenu(mnuTools,'Text','Export...');
    mnuExport.MenuSelectedFcn = @mnuExportSelected;
    
    
    
else
    if ~isempty(p.Results.uitable)
        thisTable = p.Results.uitable;
    else
        thisTable = uitable;
    end
    thisTable.ColumnName  = {'Property','Value'};
    thisTable.ColumnWidth = {round(thisTable.Position(3)/2),round(thisTable.Position(3)/2)}; %'auto';
    thisTable.FontName    = 'Courier';
    thisTable.FontSize    = getpref('ISET','fontSize',18) - 3;
    
end

thisTable.Data    = data;
thisTable.RowName = '';       % No numbers at left

end

function data = tableScene(scene,format)
% iePTable(sceneCreate);
wave = sceneGet(scene,'wave');
if numel(wave) > 1
    wave = [wave(1), wave(end), wave(2)-wave(1)];
end

switch format
    case 'window'
        precision = 4;
        data = {...
            'Name',                     char(sceneGet(scene,'name')),                                '';
            'Field of view (hor)',      num2str(sceneGet(scene,'fov')),                              'deg';
            'Field of view (diag)',     num2str(sceneGet(scene,'diagonal field of view')),           'deg';
            'Rows & columns',           num2str(sceneGet(scene,'size')),                             'samples';
            'Height & Width',           num2str(sceneGet(scene,'height and width','mm'),precision),  'mm';
            'Distance',                 num2str(sceneGet(scene,'distance','m'),precision),           'meters';
            'Angular resolution',       num2str(sceneGet(scene,'angular resolution'),precision),     'deg/samp';
            'Sample spacing',           num2str(sceneGet(scene,'sample spacing','mm'),precision),    'mm/sample';
            'Wave - min,max,delta (nm)', num2str(wave), 'nm';
            'Peak radiance, wave',      sprintf('%.2e, %.0f',sceneGet(scene,'peakradianceandwave')),   'q/s/sr/m^2, nm';
            'Mean luminance',           num2str(sceneGet(scene,'mean luminance'),precision),         'cd/m^2 (nits)';
            'Dynamic range (linear)',   sprintf('%.2e',sceneGet(scene,'luminance dynamic range')),   'linear';
            'Illuminant name',          sceneGet(scene,'illuminant name'),                           '';
            'Depth range',              num2str(sceneGet(scene,'depth range')),                      'm';
            };
    case 'embed'
        precision = 2;
        data = {...
            'FoV (width)',              num2str(sceneGet(scene,'fov'),precision);
            'Rows/cols',                num2str(sceneGet(scene,'size'));
            'Hght/Width (mm)',          num2str(sceneGet(scene,'height and width','mm'),precision+2);
            'Distance (m)',             num2str(sceneGet(scene,'distance','m'),precision);
            'Angular res (deg/samp)',   num2str(sceneGet(scene,'angular resolution'),precision);
            'Samp space (mm/sample)',   num2str(sceneGet(scene,'sample spacing','mm'),precision);
            'Wave (nm)',                num2str(wave);
            'Mean luminance (cd/m^2)',  num2str(sceneGet(scene,'mean luminance'),precision);
            'Dynamic range (linear)',   sprintf('%.2e',sceneGet(scene,'luminance dynamic range'));
            'Illuminant name',          sceneGet(scene,'illuminant name');
            };
    otherwise
        error('Unknown table format %s\n',format);
end

end

%%
function data = tableOI(oi, format)
% iePTable(oiCreate);

if isempty(oi), data = []; return; end
wave = oiGet(oi,'wave');
if numel(wave) > 1
    wave = [wave(1), wave(end), wave(2)-wave(1)];
end
  
switch format
    case 'window'
        % OK, we have an oi so put up the data.
        precision = 3;
        data = {...
            'Optical Image name', char(oiGet(oi,'name')), '';
            'Compute method',   oiGet(oi,'compute method'), '';
            'Rows & cols',        num2str(oiGet(oi,'size')),                             'samples';
            'Horizontal FOV',     num2str(oiGet(oi,'fov')),                              'deg';
            'Wave (nm)',          num2str(wave), 'nm';
            'Spatial resolution', num2str(oiGet(oi,'spatial resolution','um'),precision),'um/sample';
            'Mean illuminance',   num2str(oiGet(oi,'mean illuminance'),precision),       'lux';
            'Dynamic range',      num2str(oiGet(oi,'dynamic range'),precision),          'linear';            
            'Area',               num2str(oiGet(oi,'area','mm'),precision),              'mm^2';
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
        
    case 'embed'
        % OK, we have an oi so put up the data.
        precision = 3;
        data = {...
            'Compute method',        oiGet(oi,'compute method');
            'Rows & columns',         num2str(oiGet(oi,'size'));
            'H FOV (deg)',            num2str(oiGet(oi,'fov'));
            'Wave (nm)',              num2str(wave);
            'Resolution (um/sample)', num2str(oiGet(oi,'spatial resolution','um'),precision);
            'Mean illuminance (lux)', num2str(oiGet(oi,'mean illuminance'),precision);
            'Dynamic range',          num2str(oiGet(oi,'dynamic range'),precision);
            'Area (mm^2)',            num2str(oiGet(oi,'area','mm'),precision)';
            };
        
        % Deal with light field optical image parameters.
        if isfield(oi, 'lightfield')
            data{end+1,:} = ...
                {
                'Pinholes',           num2str(oi.lightfield.pinholes);
                };
        end
    otherwise
        error('Unknown table format %s\n',format);
end

oData = tableOptics(oiGet(oi,'optics'),format);
data  = cellCombine(data,oData);

end

%%
function data = tableOptics(optics,format)
% iePTable(opticsCreate);

switch format
    case 'window'
        % num2str, 2nd argument is precision
        precision = 3;
        
        data = {...
            'Optics model',     opticsGet(optics,'model'),                     '';
            'Optics name',      opticsGet(optics,'name'),                      '';
            'Focal length',     num2str(opticsGet(optics,'focal length','mm'),precision),      'mm';
            'F-number',         sprintf('%.1f',opticsGet(optics,'fnumber')),              'dimensionless';
            'Aperture diameter',num2str(opticsGet(optics,'aperture diameter','mm'),precision), 'mm';
            };
        
    case 'embed'
        precision = 3;
        
        data = {...
            'Optics model',          sprintf('%s-%s',opticsGet(optics,'name'),opticsGet(optics,'model'));
            'Focal length (mm)',     num2str(opticsGet(optics,'focal length','mm'),     precision);
            'F-number',              sprintf('%.1f',opticsGet(optics,'fnumber'));
            'Aperture diameter (mm)',num2str(opticsGet(optics,'aperture diameter','mm'),precision);
            };
    otherwise
        error('Unknown table format %s\n',format);
end
end

function data = tableSensor(sensor,format)
% iePTable(sensorCreate);

% Handle the camera case with no sensor.
if isempty(sensor), data = []; return; end
oi = ieGetObject('oi');
if isempty(oi), oi = oiCreate; end

switch sensorGet(sensor,'quantization method') 
    case 'linear'
        nbits = sprintf('%d',sensorGet(sensor,'nbits'));
    case 'analog'
        nbits = 'analog';
end

switch format
    case 'window'
        % num2str - 2nd argument is precision
        precision = 3;
        
        data = {
            'Name',         sensorGet(sensor,'name'), '';
            'Size',          num2str(sensorGet(sensor,'dimension','mm'),precision), 'mm';
            'Rows and Columns',       num2str(sensorGet(sensor,'size')),                     '';
            'Horizontal FOV',       num2str(sensorGet(sensor,'fov', 1e6, oi),precision),   'deg';
            'Horizontal Res / distance',       num2str(sensorGet(sensor,'wspatial resolution','um'),precision), 'um';
            'Horizontal Res / degrees',       num2str(sensorGet(sensor,'h deg per pixel',oi),precision), 'deg/pixel';
            'Exposure time',      num2str(sensorGet(sensor,'exp time')),                 's';
            'Bits',               nbits,                                           'bits';
            'DSNU',          num2str(sensorGet(sensor, 'dsnu level'),precision),    'V';
            'PRNU',          num2str(sensorGet(sensor, 'prnu level'),precision),    'percent';
            'Analog gain',   num2str(sensorGet(sensor, 'analog gain'),precision),   '';
            'Analog offset', num2str(sensorGet(sensor, 'analog offset'),precision), 'V';
            };
        
        % When it is the full window, we add in the pixel values.
        pData = tablePixel(sensorGet(sensor,'pixel'),format);
        data = cellCombine(data,pData);
        
    case 'embed'
        precision = 3;
        data = {
            'Size (mm)',     num2str(sensorGet(sensor,'dimension','mm'),precision);
            'Hor FOV (deg)', num2str(sensorGet(sensor,'fov',1e6, oi),precision);
            'Res (um)',      num2str(sensorGet(sensor,'wspatial resolution','um'),precision);
            'Res (deg/pix)', num2str(sensorGet(sensor,'h deg perpixel'),precision);
            'Bits',          nbits;
            'Analog gain',   num2str(sensorGet(sensor,'analog gain'), precision);
            'Analog offset', num2str(sensorGet(sensor,'analog offset'),precision);
            };
        
    otherwise
        error('Unknown table format %s\n',format);
end

end

%%
function data = tablePixel(pixel,format)
% iePTable(pixel);

switch format
    case 'window'
        precision = 3;
        data = {
            '-------------------', '------- Pixel -------',  '-------------------';
            'Width & height',           num2str(pixelGet(pixel, 'width','um'),     precision),  'um';
            'Fill factor',            num2str(pixelGet(pixel, 'fill factor'),    precision),  '';
            'Dark voltage (V/sec)',   num2str(pixelGet(pixel, 'dark voltage'),   precision), 'V/sec';
            'Read noise (V)',         num2str(pixelGet(pixel, 'read noise'),     precision),  'V';
            'Conversion Gain (V/e-)', num2str(pixelGet(pixel, 'conversion gain'),precision), 'V/e-';
            'Voltage Swing (V)',      num2str(pixelGet(pixel, 'voltage swing'),  precision),  'V';
            'Well Capacity (e-)',     num2str(pixelGet(pixel, 'well capacity'),  precision),  'e-';
            '','',''
            };
        
    case 'embed'
        % Needs to be adjusted for what is already on the screen.
        precision = 3;
        data = {
            'Width/height (um)',      num2str(pixelGet(pixel, 'width','um'),     precision);
            'Fill factor',            num2str(pixelGet(pixel, 'fill factor'),    precision);
            'Read noise (V)',         num2str(pixelGet(pixel, 'read noise'),     precision);
            'Conversion Gain (V/e-)', num2str(pixelGet(pixel, 'conversion gain'),precision);
            'Voltage Swing (V)',      num2str(pixelGet(pixel, 'voltage swing'),  precision);
            'Well Capacity (e-)',     num2str(pixelGet(pixel, 'well capacity'),  precision);
            '',''
            };
        
    otherwise
        error('Unknown table format %s\n',format);
end
end

%%
function data = tableIP(ip,format)
% iePtable(ipCreate)

if isempty(ip), data = []; return; end
if ipGet(ip,'max sensor') < 256,  nbits = 'analog';
else,          nbits = sprintf('%d',log2(ipGet(ip,'max sensor')));
end

switch format
    case 'window'
        precision = 3;
        data = {
            'Name',                ipGet(ip,'name'), '';
            'Rows, Columns, Primaries', num2str(fix(ipGet(ip,'result size'))), '';
            'Demosaic',            ipGet(ip,'demosaic method'),                '';
            'Sensor conversion',   ipGet(ip,'sensor conversion method'),       '';
            'Illuminant correction',  ipGet(ip,'illuminant correction method'),   '';
            'Display name',        ipGet(ip,'display name'),                   '';
            'Display dpi',         num2str(ipGet(ip,'display dpi')),           'dots per inch';
            'Display bits',        nbits,                                      'bits'
            '--------------------', '-----------------------', '-------------------';
            };
        
    case 'embed'
        precision = 3;
        
        data = {
            'name',                ipGet(ip,'name');
            'row, col, primaries', num2str(fix(ipGet(ip,'result size')));
            'display name',        ipGet(ip,'display name');
            'n bits',              nbits;               
            };
    otherwise
        error('Unknown table format %s\n',format);
end
end

function data = tableDisplay(display,format)
% iePTable(displayCreate);
switch format
    case 'window'
        precision = 3;
        data = {
            'Name',     displayGet(display,'name'),                       '';
            'DPI',      num2str(displayGet(display,'dpi'),precision),     '';
            'DAC size', num2str(displayGet(display,'dac size'),precision),'';
            '--------', '------------------------','---------------------';
            };
        
    case 'embed'
        precision = 3;
        data = {
            'name',     displayGet(display,'name');
            'dpi',      num2str(displayGet(display,'dpi'),precision);
            'DAC size', num2str(displayGet(display,'dac size'),precision);
            };
    otherwise
        error('Unknown table format %s\n',format);
end
end

%%
function data = tableCamera(camera,format)
% Creates separate tables for each of the main camera components

% iePTable(cameraCreate);

% Camera table shows optics, pixel and sensor parameters.  This should be
oData = tableOI(cameraGet(camera, 'oi'),format);
sData = tableSensor(cameraGet(camera,'sensor'),format);
data  = cellCombine(oData,sData);

ipData = tableIP(cameraGet(camera,'ip'),format);
data  = cellCombine(data,ipData);

end

%%
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
    data((sRows+1):end,ii) = oData(:,ii);
    data(1:sRows,ii) = sData(:,ii);
end

end

%%
function mnuExportSelected(src,event)
% allow user to export the current parameters
paramFolder = fullfile(isetRootPath, "local", "parameters");
if ~isfolder(paramFolder)
    mkdir(paramFolder);
end
[paramFileName, paramFilePath] = uiputfile(fullfile(paramFolder,"*.csv"),"Choose a filename for your Score data");
if ~isequal(paramFileName,0)
    ourFigure = ancestor(src,'figure');
    ourTable = findobj([ourFigure], 'Tag', 'IEPTable Table');
    writecell(ourTable.Data, fullfile(paramFilePath, paramFileName));
end

end