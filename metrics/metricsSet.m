function handles = metricsSet(handles, param, val, varargin)
%
%   handles = metricsSet(handles,param,val,varargin)
%
%Author: ImagEval
%Purpose:
%

if ieNotDefined('handles'), error('Metrics Window handles required.'); end
if ieNotDefined('param'), error('Metrics parameter required.'); end

switch lower(param)
    case {'metricdata', 'metricuserdata'}
        handles.metricImage = val;

    otherwise
        error('Unknown metricsSet parameter.');
end

return;