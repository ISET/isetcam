function d = ipPlot(ip,param,varargin)
% Gatway plotting routine for the image processing structure
%
%
% Copyright Imageval Consulting, LLC 2015

%% Decode parameters

if ieNotDefined('ip'), error('ip required.'); end
if ieNotDefined('param'), error('plotting parameter required'); end

%
param    = ieParamFormat(param);
varargin = ieParamFormat(varargin);

switch param
    case 'horizontalline'
        plotDisplayLine(ip,'h');
    case 'verticalline'
        plotDisplayLine(ip,'v');
    case 'chromaticity'
        plotDisplayColor(ip,'chromaticity');
    case 'cielab'
        plotDisplayColor(ip,'CIELAB');
    case 'cieluv'
        plotDisplayColor(ip,'CIELUV');
    case 'luminance'
        plotDisplayColor(ip,'luminance');
    case 'rgbhistogram'
        plotDisplayColor(ip,'RGB');
    case 'rgb3d'
        plotDisplayColor(ip,'rgb3d');

    otherwise
        error('Uknown parameter %s\n',param);
end


end
