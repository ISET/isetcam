function filename = sensor2EXR(sensor,filename,varargin)
% Save sensor volts (default) or digital values into an EXR file
%
% Synopsis
%   filename = sensor2EXR(sensor,filename,varargin)
%
% Input
%   sensor   - Sensor after sensorCompute
%   filename - If empty, a temporary file name is created and returned
%
% Key/val
%  datatype  - 'volts' or 'dv'  (default: 'volts')
%
% TODO:
%   Improve the comments that are placed in the Attributes field.
%   Perhaps EXR format should be one of several options.
%   There is no great way to save comments in the info slot
%
% See also
%   sensorSaveImage

% Example:
%{
scene = sceneCreate; 
oi = oiCreate('wvf'); oi = oiCompute(oi,scene);
sensor = sensorCreate; sensor = sensorCompute(sensor,oi);

fname = sensor2EXR(sensor,'','data type','volts');

img = exrread(fname); 
info = exrinfo(fname); disp(info.AttributeInfo.Comments)
ieNewGraphWin; imagesc(img); colormap(gray)
%}

%% Parse

varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('sensor',@(x)(isstruct(x) && isequal(x.type,'sensor')))
p.addRequired('filename',@ischar);
p.addParameter('datatype','volts',@ischar);
p.addParameter('comment','',@isstruct);

p.parse(sensor,filename,varargin{:});

datatype = p.Results.datatype;

%%
switch datatype
    case 'volts'
        data = sensorGet(sensor,'volts');
    case 'digital'
        data = sensorGet(sensor,'dv');
end

if isempty(filename), filename = [fullfile(tempname),'.exr']; end

exrwrite(data,filename);
info = exrinfo(filename);

pSize = sensorGet(sensor,'pixel size','um');
str = sprintf('Name: %s | Noise-flag: %d | Pixel-Size: %.2f um | N-Channels: %d',...
    sensorGet(sensor,'name'),...
    sensorGet(sensor,'noise flag'), ...
    pSize(1), ...
    sensorGet(sensor,'nfilters'));
info.AttributeInfo.Comments = str;
exrwrite(data, filename, 'Attributes', info.AttributeInfo);

end

%{
% Create an empty struct
exr_info = struct();

% Add fields dynamically
exr_info.FileName = '';
exr_info.PartName = '';
exr_info.PartType = '';
exr_info.DisplayWindow = [];
exr_info.ChannelInfo = struct('PixelType', {}, 'XSubSampling', {}, 'YSubSampling', {});
exr_info.AttributeInfo = struct();
%}