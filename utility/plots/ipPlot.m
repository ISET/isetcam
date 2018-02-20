function d = ipPlot(ip,param,varargin)
% Gatway plotting routine for the image processing structure
%
%
% Copyright Imageval Consulting, LLC 2015

%% Decode parameters

if ieNotDefined('ip'), error('ip required.'); end
if ieNotDefined('param'), error('plotting parameter required'); end

%
param = ieParamFormat(param);

switch param
    case 'horizontal line'
    otherwise
        error('Uknown parameter %s\n',param);
end


end
