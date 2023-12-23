function [uData, hdl] = ipPlot(ip,param,xy,varargin)
% Gateway plotting routine for the image processing structure
%
% Syntax
%   [uData, hdl] = ipPlot(ip,param,varargin)
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
 % ipWindow(ip);
 [uData,hdl] = ipPlot(ip,'horizontal line',[20 20]);
%}

%% Decode parameters

% varargin = ieParamFormat(varargin);
if ieNotDefined('ip'), error('ip required.'); end
if ieNotDefined('param'), error('plotting parameter required'); end
if ieNotDefined('xy'), xy = []; end

uData = [];

% Some day this might be unused.
hdl = []; %#ok<NASGU> 

%%
param    = ieParamFormat(param);
switch param
    case 'horizontalline'
        % Set xy
        [uData, hdl] = plotDisplayLine(ip,'h',xy);
    case 'verticalline'
        [uData, hdl] = plotDisplayLine(ip,'v');
    case 'chromaticity'
        [uData, hdl] = plotDisplayColor(ip,'chromaticity');
    case 'cielab'
        [uData, hdl] = plotDisplayColor(ip,'CIELAB');
    case 'cieluv'
        [uData, hdl] = plotDisplayColor(ip,'CIELUV');
    case 'luminance'
        [uData, hdl] = plotDisplayColor(ip,'luminance');
    case 'rgbhistogram'
        [uData, hdl] = plotDisplayColor(ip,'RGB');
    case 'rgb3d'
        [uData, hdl] = plotDisplayColor(ip,'rgb3d');
        
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
        hdl = ieROIDraw('ip','shape','rect','shape data',ipGet(ip,'roi'));
        
    otherwise
        error('Uknown parameter %s\n',param);
end

% Attach the user data to the axis too?
% if exist('uData','var'),set(gca,'UserData',uData); end

end
