function [img,val] = metricsCompute(vc1,vc2,metricName)
%Gateway routine for computing the various types of metrics
%
%   [img,val] = metricsCompute(vc1,vc2,metricName)
%
% Compute an error image or value between the two selected images in the
% metrics window.
%
% Currently available error images are of these types:
%
%     {'cielab'}   - Delta E, requires image white point values
%     {'cieluv'}   - Delta E, requires image white point
%     {'mse'}      - Mean squared error of image digital values
%     {'rmse'}     - Root mean squared error of image digital values
%     {'peaksnr'}  - Peak signal-to-noise ratio
%     {'spatialcielab'}    - Spatial CIELAB analysis
%
% Example:
%    img = metrcisCompute(vc1,vc2,'CIELAB');
%    [img,val] = metrcisCompute(vc1,vc2,'PSNR');
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('vc1'), error('Requires two display images'); end
if ieNotDefined('vc2'), error('Requires two display images'); end
if ieNotDefined('metricName'), metricName = 'difference'; end

handles = guidata(metricsWindow);
set(handles.txtMetricValue,'String',[])

switch lower(metricName)
    
    case {'cielab','cielab (de)'}
        dataXYZ1 = ipGet(vc1,'dataxyz');
        dataXYZ2 = ipGet(vc2,'dataxyz');
        wp{1} = ipGet(vc1,'datawhitepoint');
        if isempty(wp{1})
            errordlg('No data white point for image 1');
            return;
        end
        wp{2} = ipGet(vc2,'datawhitepoint');
        if isempty(wp{2})
            errordlg('No data white point for image 2');
            return;
        end
        img = deltaEab(dataXYZ1,dataXYZ2,wp);
        return;
    case {'cieluv (de)','cieluv'}
        wp = ipGet(vc1,'datawhitepoint');
        if isempty(wp)
            errordlg('No data white point for image 1');
            return;
        end
        dataXYZ1 = ipGet(vc1,'dataxyz');
        dataXYZ2 = ipGet(vc2,'dataxyz');
        img = deltaEuv(dataXYZ1,dataXYZ2,wp);
        return;
    case {'mse','meansquarederror'}
        [val,img] = metricsMSE(vc1,vc2);
        ipGet(vc1,'result');
        peakSNR = psnr(ipGet(vc1,'result'),ipGet(vc2,'result'))
        return;
    case {'rmse','rootmeansquarederror'}
        [val,img] = metricsRMSE(vc1,vc2);
        peakSNR = psnr(ipGet(vc1,'result'),ipGet(vc2,'result'))
        return;
    case {'psnr','peaksnr'}
        peakSNR = psnr(ipGet(vc1,'result'),ipGet(vc2,'result'));
        str = sprintf('Peak SNR: %.3f',peakSNR);
        set(handles.txtMetricValue,'String',str)
        val = peakSNR;
        img = [];
        return;
    case 'dctune'
        warning('Not yet implemented.');
        img = [];
        return;
    case {'spatial cielab','spatialcielab','scielab'}
        %
        warning('Not yet implemented.');
        
        return;
    otherwise
        error('Unknown metric method');
end

return;

%------------------------------------------
function [mse,img] = metricsMSE(vc1,vc2)
%
%

img1 = ipGet(vc1,'result');
img2 = ipGet(vc2,'result');

if size(img1) ~= size(img2)
    ieInWindowMessage('Image size does not match',ieSessionGet('metricshandles'));
    return;
end

img = sum((img1 - img2).^2,3);

mse = mean(img(:));

return;

%------------------------------------------
function [mse,img] = metricsRMSE(vc1,vc2)
%
%

img1 = ipGet(vc1,'result');
img2 = ipGet(vc2,'result');

img = sqrt(sum((img1 - img2).^2,3));

mse = mean(img(:));

return;