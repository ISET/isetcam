function h = ieDrawShape(obj,shape,varargin)
% Draw a shape on the gui window
%
%   h = ieDrawShape(obj,shape,varargin)
%
% Copyright Imageval, LLC 2015
%
% ieExamplesPrint('ieDrawShape');
%
% See also: 
%   ieROIDraw, v_drawShapes
%

% Examples:
%{
  scene = sceneCreate; ieAddObject(scene); sceneWindow;
  h = ieDrawShape(scene,'rectangle',[10 10 50 50]);
  set(h,'edgecolor','r'); pause(1);
  delete(h);
%}
%{
 camera = cameraCreate;  scene = sceneCreate;
 camera = cameraCompute(camera, scene); ip = cameraGet(camera,'ip');
 ipWindow(ip);
 c = ipGet(ip,'center');
 radius = c(1)/4;
 h = ieDrawShape(ip,'circle',c(1:2),radius);
 set(h,'color',[0 0 1]); pause(1)
 delete(h);
%}


%% Select the window
switch obj.type
    case 'scene'
        axes(ieSessionGet('scene axis'));
    case 'opticalimage'
        axes(ieSessionGet('oi axis'));
    case 'sensor'
        axes(ieSessionGet('sensor axis'));
    case 'vcimage'
        axes(ieSessionGet('ip axis'));
    otherwise
        error('Unknown object type %s\n',obj.type);
end

%%
switch shape
    case 'circle'
        % ieDrawShape(obj,'circle',[20 20],10);
        % nSamplePoints = 100
        hold on;
        pts = circle(varargin{1},varargin{2},100);
        h = plot(pts(:,2),pts(:,1),'k-');

    case 'rectangle'
        % rect = [10 10 50 50];
        % ieDrawShape(obj,'rectangle',rect);
        h = rectangle('Position',varargin{1});
        set(h,'edgecolor','k');
        
    case 'line'
        % X = [0 96]; Y = [32 32];
        % ieDrawShape(obj,'line',X ,Y);
        h = line(varargin{1},varargin{2},'LineWidth',8);
        
    otherwise 
        error('Unknown shape %s\n',shape);
end

end

%%
function pts = circle(center,r,nPts)
%
t = linspace(0,2*pi,nPts)'; 
pts = zeros(length(t),2);
pts(:,1) = r.*cos(t) + center(1); 
pts(:,2) = r.*sin(t) + center(2); 
end




