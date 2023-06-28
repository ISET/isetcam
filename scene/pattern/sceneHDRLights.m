function scene = sceneHDRLights(varargin)
% Create a HDR chart of circles, squares and lines (lights) on a black
% background
%
%   scene = sceneHDRLights()
%
% Inputs
%
% Returns
%   scene:         HDR chart as a scene
%
% See also
%   sceneHDRChart, sceneReflectanceChart, macbethChartCreate

%Examples:
%{
  scene = sceneHDRLights();
  sceneWindow(scene);
%}

%%
p = inputParser;

imSize = 384;

%% Spatial pattern
img = zeros(imSize,imSize);

% Put circles with different sizes across the top third
y = round(imSize * 0.25);
xvals = round(linspace(0.2,0.8,4)*imSize);
radius = [0.02 0.07 0.15 0.2]*imSize/2;
thisColor = {'white','green','blue','red'};
for ii = 1:numel(xvals)
    img = insertShape(img,'filled-circle',[xvals(ii),y,radius(ii)],'Color',thisColor{ii});
end

% Put lines of different thickness and orientation around the middle
y = round(imSize * 0.5);
xvals = round(linspace(0.1,0.8,6)*imSize);
thisColor = {'white','green','blue','yellow','magenta','white'};

squareSize = imSize/64;
hw = round([1,7; 1,3; 2,2; 3,1; 6,1; 8,1]*squareSize);
for ii = 1:numel(xvals)
    img = insertShape(img,'filled-rectangle',[xvals(ii),y,hw(ii,1),hw(ii,2)],'Color',thisColor{ii});
end

y = round(imSize * 0.75);
xvals = round(linspace(0.1,0.7,3)*imSize);
squareSize = imSize/64;
hw = [2 2; 5 5; 9 9]*squareSize;
for ii = 1:numel(xvals)
    img = insertShape(img,'filled-rectangle',[xvals(ii),y,hw(ii,1),hw(ii,2)],'Color','white');
end
% ieNewGraphWin; imagesc(img); axis image

% Add a uniform low level to set the dynamic range
wave = 400:10:700;
scene = sceneFromFile(img,'rgb',1e5,displayCreate,wave);
sceneU = sceneCreate('uniform',imSize,wave);
sceneU = sceneSet(sceneU,'mean luminance',1e-2);
scene = sceneAdd(scene,sceneU);
end




