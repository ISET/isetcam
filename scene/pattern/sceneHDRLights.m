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
%{
  scene = sceneHDRLights('n circles',4,'radius',repmat(0.01,1,4),'circle colors',{'white'});
  sceneWindow(scene);
%}

%%
varargin = ieParamFormat(varargin);
p = inputParser;

p.addParameter('imagesize',384,@isnumeric);

p.addParameter('ncircles',4,@isnumeric);
p.addParameter('radius',[0.01,0.035,0.07,0.1],@isvector);
p.addParameter('circlecolors',{'white','green','blue','yellow','magenta','white'},@iscell);

p.addParameter('nlines',4,@isnumeric);
p.addParameter('linelength',0.02,@isnumeric);
p.addParameter('linecolors',{'white','green','blue','yellow','magenta','white'},@iscell);

p.parse(varargin{:});

%% Spatial pattern
imSize   = p.Results.imagesize;
img = zeros(imSize,imSize);

%% Put circles with different sizes across the top third
nCircles = p.Results.ncircles;
radius   = p.Results.radius;
cColors  = p.Results.circlecolors;
y = round(imSize * 0.25);
xvals = round(linspace(0.2,0.8,nCircles)*imSize);
radius = radius*imSize;
for ii = 1:numel(xvals)
    cc = mod(ii,numel(cColors)) + 1;    
    img = insertShape(img,'filled-circle',[xvals(ii),y,radius(ii)],'Color',cColors{cc});
end

%% Put lines of different thickness and orientation around the middle
nLines       = p.Results.nlines;
lineLength   = p.Results.linelength;
lColors      = p.Results.linecolors;

y = round(imSize * 0.5);
xvals = round(linspace(0.1,0.8,nLines)*imSize);
lineLength = round(lineLength*imSize);
hw = round([1,7*lineLength; 1,3*lineLength; 3*lineLength,1; 8*lineLength,1]);
for ii = 1:numel(xvals)
    cc = mod(ii,numel(lColors)) + 1;
    img = insertShape(img,'filled-rectangle',[xvals(ii),y,hw(ii,1),hw(ii,2)],'Color',lColors{cc});
end

%% Squares
y = round(imSize * 0.75);
xvals = round(linspace(0.1,0.7,3)*imSize);
squareEdge = imSize/64;
hw = [2 2; 5 5; 9 9]*squareEdge;
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




