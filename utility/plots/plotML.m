function plotML(ml,pType)
% Gateway routine for microlens summary plots
%
%   plotML(ml,pType)
%
% Plot types (pType)
%  'offsets'
%  'mesh pixel irradiance'
%  'image pixel irradiance'
%
% Examples:
%   ml = mlensCreate; ml = mlRadiance(ml);
%   plotML(ml,'image pixel irradiance');
%   plotML(ml,'mesh pixel irradiance');
%   plotML(ml,'offsets');
%
% Copyright Imageval Consulting, 2004

%%
if ieNotDefined('ml'), error('Microlens required.'); end

vcNewGraphWin;

%%
switch ieParamFormat(pType)
    case {'offsets'}
        
        optimalOffsets = mlensGet(ml,'micro optimal offsets');
        support = sensorGet(vcGetObject('sensor'),'spatial Support','mm');
        
        mesh(support.y, support.x, optimalOffsets);
        xlabel('Position (mm)');
        ylabel('Position (mm)');
        zlabel('Optimal offset (um) toward center');
        
    case {'meshpixelirradiance','pixelirradiance'}
        irrad = mlensGet(ml,'pixel irradiance');
        x = mlensGet(ml,'x coordinate');
        mesh(x,x,irrad);
        xlabel('Position (um)');
        ylabel('Position (um)');
        zlabel('Relative irradiance');
        h = hot(256); colormap(h(30:220,:))
        
    case {'imagepixelirradiance'}
        mlIrradianceImage(ml);
        
    otherwise
        error('Unknown plotML type %s\n',pType);
end

return;







%
uData.support = support;
uData.optimalOffsets = optimalOffsets;
uData.command = 'mesh(support.y, support.x, optimalOffsets)';

set(figNum,'userdata',uData);

return;

