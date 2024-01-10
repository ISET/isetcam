function pngName = sceneThumbnail(scene,varargin)
% Read a sceneFromFile and produce a png thumbnail
%
% Synopsis
%   pngName = sceneThumbnail(scene,varargin)
%
% Inputs
%   sceneFile -
%   rowSize - row size of the thumbnail
%
% Optional key/value pairs
%   row size     - Number of rows in the thumbnail (192)
%   force square - Make the thumbnail square by padding or cropping
%   label        - Logical for label or not
%   font size    - Font size if there is a label
%   outputfilename  - Specify where the file should get written.  This is
%                  is the path including filename, but without the .png
%                  extension.  Default is to take the name from the scene 
%                  name.
%
% Outputs
%   pngName - Thumbnail file name
%
% See also
%   insertInImage


% Examples:
%{
  if (~exist(fullfile(isetRootPath,'local'),'dir'))
      mkdir(fullfile(isetRootPath,'local'));
  end
  outputName = fullfile(isetRootPath,'local','StuffedAnimals_tungsten-hdrs');
  scene = sceneFromFile('StuffedAnimals_tungsten-hdrs.mat','multispectral');
  rowSize = 192;
  pngFile = sceneThumbnail(scene,'output file name',outputName);
%}

%% Check inputs

varargin = ieParamFormat(varargin);

p = inputParser;

p.addRequired('scene',@(x)(isequal(x.type,'scene')));

p.addParameter('rowsize',192,@isnumeric);  % 192 rows
p.addParameter('forcesquare',false,@islogical);   % For a square thumbnail by padding or cropping
p.addParameter('fontsize',9,@isnumeric);   % For a square thumbnail by padding or cropping
p.addParameter('label',true,@islogical);   % For a square thumbnail by padding or cropping
p.addParameter('backcolor',[0.0 0.0 0.3],@isvector);
p.addParameter('outputfilename',[],@ischar);

p.parse(scene,varargin{:});

rowSize     = p.Results.rowsize;
forceSquare = p.Results.forcesquare;
fontSize    = p.Results.fontsize;
label       = p.Results.label;
backColor   = p.Results.backcolor;
outputFilename = p.Results.outputfilename;

%%  Read the scene and figure its size


rgb = sceneGet(scene,'rgb');
[r,c,~] = size(rgb);

% Preserve the aspect ratio
colSize = round((rowSize/r)*c);

rgb = imresize(rgb,[rowSize colSize]);

%% Pad or crop to make the thumbnail square

if forceSquare
    padSize = rowSize - colSize;
    if padSize > 0
        % Too few cols, so pad
        rgb = padarray(rgb,[0 padSize],0.3,'post');
    elseif padSize < 0
        % Too many cols, so crop
        rgb = imcrop(rgb,[1 1 rowSize-1 colSize-1]);
    end
end

% ieNewGraphWin; imagescRGB(rgb); axis image

%% Write it out

if label
    rgb = insertInImage(ieScale(rgb,1), @()text(2,8,scene.name),...
        {'fontweight','bold','color','w','fontsize',fontSize,...
        'linewidth',1,'margin',1,...
        'backgroundcolor',backColor});
    % ieNewGraphWin; imshow(uint8(mean(rgb,3)));
end

if (isempty(outputFilename))
    pngName = [scene.name,'.png'];
else
    pngName = [outputFilename '.png'];
imwrite(rgb,pngName);

end