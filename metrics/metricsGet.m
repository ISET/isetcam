function val = metricsGet(handles,param,varargin)
%
%   val = metricsGet(handles,param,varargin)
%
%Author: ImagEval
%Purpose:
%

if ieNotDefined('handles'), error('Metrics Window handles required.'); end
if ieNotDefined('param'), error('Metrics parameter required.'); end

val = [];

switch lower(param)
    case {'image1name'}
        contents = get(handles.popImageList1,'String');
        which = get(handles.popImageList1,'Value');
        val = contents{which};
    case {'image2name'}
        contents = get(handles.popImageList2,'String');
        which = get(handles.popImageList2,'Value');
        val = contents{which};
    case {'metricaxes','metricsaxes'}
        % metricAxis = metricsGet(handles,'metricAxes');
        val = handles.imgMetric;
        
    case {'metricdata','metricuserdata'}
        val = handles.metricImage;
    case {'currentmetric','curmetric'}
        contents = get(handles.popMetric,'String');
        which = get(handles.popMetric,'Value');
        val = char(contents{which});
        
    case {'listofmetricnames','metricnames'}
        val = get(handles.popMetric,'String');
    case {'metricimagedata','metricimage'}
        val = metricsGet(mFig,'metricdata');
        if isempty(val), return; end
        % Based on the current metric, adjust the data.
        metricNames = get(handles.popMetric,'String');
        metricName = metricNames(get(handles.popMetric,'Value'));
        switch char(metricName)
            case 'CIELAB (dE)'
                val = val/30;
            otherwise
                val = val/max(val(:));
        end
    case {'vcipair','vcimagepair'}
        [val.vci1, val.vci2] = metricsGetVciPair(handles);
        
    otherwise
        error('Unknown metricsGet parameter.');
    end
    
    return;