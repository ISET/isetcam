function [uData, g] = ipPlot(ip,param,xy,varargin)
% Gatway plotting routine for the image processing structure
%
% Syntax
%   [uData, g] = ipPlot(ip,param,varargin)
%
% Brief description
%   Image processing (ip) plotting gateway.
%
% Inputs
%   ip:    - Image processing struct
%   param: - Plot parameter
%   xy     - xy position on the image for plotting a line
%
% Key/val pairs
%
% Returns
%    uData
%    hdl
%
% Parameters
%    'horizontal line' - send in the xy or select it
%    'vertical line'   -   "
%    'chromaticity'    -  send in an ROI or select it
%    'cielab'          -   "
%    'cieluv'          -   "
%    'luminance'       -   "
%    'rgbhistogram'    -   "
%    'rgb3d'           -  Three-D plot of points
%    'roi'             -  Show the ROI on the image
%
%
% ieExamplesPrint('ipPlot');
%
% See also
%  ieROISelect, ieROIDraw, ieDrawShape

% Examples:
%{
 camera = cameraCreate;  scene = sceneCreate;
 camera = cameraCompute(camera, scene); ip = cameraGet(camera,'ip');
 ipWindow(ip);
 [uData,hdl] = ipPlot(ip,'horizontal line',[20 20]);
%}

%% Decode parameters

% varargin = ieParamFormat(varargin);
if ieNotDefined('ip'), error('ip required.'); end
if ieNotDefined('param'), error('plotting parameter required'); end
if ieNotDefined('xy'), xy = []; end

uData = [];
g = [];

%%
param    = ieParamFormat(param);
switch param
    case 'horizontalline'
        % Set xy
        [uData, g] = plotDisplayLine(ip,'h',xy);
    case 'verticalline'
        [uData, g] = plotDisplayLine(ip,'v');
    case 'chromaticity'
        [uData, g] = plotDisplayColor(ip,'chromaticity');
    case 'cielab'
        [uData, g] = plotDisplayColor(ip,'CIELAB');
    case 'cieluv'
        [uData, g] = plotDisplayColor(ip,'CIELUV');
    case 'luminance'
        [uData, g] = plotDisplayColor(ip,'luminance');
    case 'rgbhistogram'
        [uData, g] = plotDisplayColor(ip,'RGB');
    case 'rgb3d'
        [uData, g] = plotDisplayColor(ip,'rgb3d');
        
    case {'roi'}
        % [uData,g] = ipPlot(ip,'roi');
        %
        % If the roi is a rect, use its values to plot a white rectangle on
        % the sensor image.  The returned graphics object is a rectangle
        % (g) and you can adjust the colors and linewidth using it.
        if isempty(ipGet(ip,'roi'))
            [~,rect] = vcROISelect(ip);
            ip = ipSet(ip,'roi',rect);
        end
        
        % Make sure the sensor window is selected
        ipWindow;
        g = ieROIDraw('ip','shape','rect','shape data',ipGet(ip,'roi'));
        
    otherwise
        error('Uknown parameter %s\n',param);
end


end
