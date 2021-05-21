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
  h.EdgeColor = 'r';
  pause(1);
  delete(h);
%}
%{
 camera = cameraCreate;  scene = sceneCreate;
 camera = cameraCompute(camera, scene); ip = cameraGet(camera,'ip');
 ipWindow(ip);
 c = ipGet(ip,'center');
 radius = c(1)/4;
 h = ieDrawShape(ip,'circle',c(1:2),radius);
 h.Color = [0 0 1];
 pause(1)
 delete(h);
%}


%% Select the window

select = true;
[~, appAxis] = ieAppGet(obj,'select',select);
axis(appAxis);

%%
switch shape
    case 'circle'
        % ieDrawShape(obj,'circle',[20 20],10);
        % nSamplePoints = 100
        % Should update to permit multiple circles.
        %
        hold on;
        pts = circle(varargin{1},varargin{2},100);
        h = plot(pts(:,2),pts(:,1),'k-');
        
    case 'rectangle'
        % rect = [10 10 50 50];
        % ieDrawShape(obj,'rectangle',rect);
        rects = varargin{1};
        nRects = size(rects,1);
        for ii=1:nRects
            h(ii) = rectangle(appAxis,'Position',rects(ii,:),...
                'EdgeColor',[1 1 1], ...
                'LineWidth',1,...
                'Curvature',0.2); %#ok<AGROW>
        end
        
    case 'line'
        % X = [0 96]; Y = [32 32];
        % ieDrawShape(obj,'line',X ,Y);
        h = line(varargin{1},varargin{2},'LineWidth',8);
        
    otherwise
        error('Unknown shape %s\n',shape);
end

end

%% Not sure why we need this

function pts = circle(center,r,nPts)

t = linspace(0,2*pi,nPts)';
pts = zeros(length(t),2);
pts(:,1) = r.*cos(t) + center(1);
pts(:,2) = r.*sin(t) + center(2);

end




