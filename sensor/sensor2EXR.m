function [filename, rgb] = sensor2EXR(sensor,filename,varargin)
% Save sensor volts (default) or digital values into an EXR file
%
% Synopsis
%   [filename, rgb] = sensor2EXR(sensor,filename,varargin)
%
% Input
%   sensor   - Sensor after sensorCompute
%   filename - If empty, a temporary file name is created and returned
%
% Key/val
%  dataformat - 'noisy rgb' or 'mosaic' (default: 'noisy rgb')
%  datatype   - 'volts' or 'dv'  (default: 'volts')
%  comment    -  Comment characters
%  noiselevel -  Scale for uniform [0 1] noise to fill in (default: 0.02)
%
% Output
%  filename   - EXR output file
%  rgb        - Sensor data in RGB format for display
%
% Description
%
% TODO:
%   The 'noisy rgb' is used for the Restormer network.
%   Improve default the comments that are placed in the Attributes field.
%
% See also
%   sensorSaveImage

% Example:
%{
scene = sceneCreate('freqorient',512); scene = sceneSet(scene,'fov',10);
oi = oiCreate('wvf'); oi = oiCompute(oi,scene);
sensor = sensorCreate; 
sensor = sensorSet(sensor,'fov',sceneGet(scene,'fov'),oi);
sensor = sensorCompute(sensor,oi);

% A lot of noise for visibility.  But the default is quite small.
[fname,rgb] = sensor2EXR(sensor,'','data type','volts','data format','noisyrgb','noise level',0.5);
ieNewGraphWin; imagesc(rgb); axis image;

img  = exrread(fname); 
info = exrinfo(fname); disp(info.AttributeInfo.Comments)
ieNewGraphWin; imagesc(img); colormap(gray)
delete(fname);
%}

%% Parse

varargin = ieParamFormat(varargin);
p = inputParser;

p.addRequired('sensor',@(x)(isstruct(x) && isequal(x.type,'sensor')))
p.addRequired('filename',@(x)(ischar(x) || isstring(x)));
p.addParameter('datatype','volts',@ischar);
p.addParameter('dataformat','noisyrgb',@ischar);
p.addParameter('comment','',@ischar);
p.addParameter('noiselevel',0.02,@isscalar);

p.parse(sensor,filename,varargin{:});

datatype   = p.Results.datatype;
dataformat = p.Results.dataformat;
comment    = p.Results.comment;
noiselevel = p.Results.noiselevel;

%%
switch datatype
    case 'volts'
        data = sensorGet(sensor,'volts');
    case 'digital'
        data = sensorGet(sensor,'dv');
end

switch dataformat
    case 'mosaic'
        % Leave data in mosaic form
    case 'noisyrgb'
        % Convert to separate planes with zero in the empty positions. This
        % behavior is used by Zhenyi for the RGBW demosaicking experiments.
        rgb = plane2rgb(data,sensor,0);
        % ieNewGraphWin; imagesc(rgb); axis image

        % Replace the zero values with a small amount of noise.
        nChannels = size(rgb,3);
        for ii=1:nChannels
            tmp = rgb(:,:,ii);
            noise = noiselevel * rand(size(tmp,1),size(tmp,2));
            noise = noise .* (tmp==0);
            % ieNewGraphWin; imagesc(noise); axis image
            tmp = tmp + noise;
            rgb(:,:,ii) = tmp;
        end
        data = rgb;
        % ieNewGraphWin; imagesc(data); axis image
    otherwise
        error('unknown format %s',dataformat);
end

if isempty(filename), filename = [fullfile(tempname),'.exr']; end

% Not sure if the RGB ordering is right.
exrwrite(data,filename);
info = exrinfo(filename);
% system(sprintf('open %s',filename));

if isempty(comment)
    pSize = sensorGet(sensor,'pixel size','um');
    comment = sprintf('Name: %s | Exposure %.2f ms | Pixel-Size: %.2f um | N-Channels: %d |  Noise-flag: %d',...
        sensorGet(sensor,'name'),...
        sensorGet(sensor,'exp time','ms'), ...
        pSize(1), ...
        sensorGet(sensor,'nfilters'), ...
        sensorGet(sensor,'noise flag'));
end

info.AttributeInfo.Comments = comment;
exrwrite(data, filename, 'Attributes', info.AttributeInfo);

end
