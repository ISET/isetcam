function handles = metricsShowMetric(handles)
%
%  handles = metricsShowMetric(handles)
%
%Author: ImagEval
%Purpose:
%  Display the metrics image in the metrics window.
%
% Examples:
%   metricsShowImage(img,1/2.2)

if ieNotDefined('handles'), error('Metric window handles not valid.'); end

contents = get(handles.popMetric,'String');
metric = contents{get(handles.popMetric,'Value')};
img = handles.metricImage;
axes(handles.imgMetric);

% I am not sure we should ever use this value because the numbers we
% display are usually in real units.  I put this here just to make sure the
% call works.  It does, and we can use it later if needed.
% gam = str2double(get(handles.editGamma,'String'));

switch metric
    
    case 'CIELAB (dE)'
        
        % Only show dE values below 30.
        img = ieClip(img,0,30);
        barHndl = imagescM(img,gray(30),'horiz',1);
        axis image; axis off
        
    case 'CIELUV (dE)'
        
        img = ieClip(img,0,30);
        imagescM(img,[],'horiz');
        axis image; axis off
        
    case 'Spatial CIELAB'
        warning('Spatial CIELAB Not yet implemented.')
        
    case 'DcTune'
        warning('DcTune Not yet implemented.')
        
    case 'RMSE'
        imagescM(img,[],'horiz',0);
        axis image; axis off
        
    case 'MSE'
        imagescM(img,[],'horiz');
        axis image; axis off
        
    case 'PSNR'
        axis image; axis off
        
    otherwise
end


return;

