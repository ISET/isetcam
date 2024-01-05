function fName = ipSaveImage(ip,fName,showImageFlag,trueSizeFlag, varargin)
% Save the image in the ipWindow to an 8-bit PNG file
%
% Syntax
%   fName = ipSaveImage(ip,fName)
%
% Inputs
%   ip:     image processor struct
%   fName:  png output file
%
%   'cropborder' for whether to remove black areas
% Description:
%
% See also
%   sceneSaveImage, oiSaveImage

% Examples:
%{
  % We save the data using the flags in the oiWindow, if it is open.
  % Otherwise, the standard RGB with gam = 1.
  scene = sceneCreate;
  camera = cameraCreate;
  camera = cameraCompute(camera,scene);
  cameraWindow(camera,'ip');
  ip = cameraGet(camera,'ip');
  showImageFlag = false; trueSizeFlag = false
  if (~exist(fullfile(isetRootPath,'local'),'dir'))
      mkdir(fullfile(isetRootPath,'local'));
  end
  fName = ipSaveImage(ip,fullfile(isetRootPath,'local','deleteMe'),showImageFlag,trueSizeFlag);   % PNG is appended
  img = imread(fName); ieNewGraphWin; image(img);
  delete(fName);
%}

p = inputParser();

% in case our caller wants us to remove the black border
addParameter(p, 'cropborder', false);

% convert our args to ieStandard and parse
varargin = ieParamFormat(varargin);
p.parse(varargin{:});

cropFlag = p.Results.cropborder;

%%
if ~exist('ip','var') || isempty(ip), ip = ieGetObject('ip'); end
gam     = ipGet(ip,'display gamma');

img = imageShowImage(ip, gam, true, 0);

% Get RGB file name (tif)
if ieNotDefined('fName')
    fName = vcSelectDataFile('session','w','png','Image file (png)');
end
if ieNotDefined('showImageFlag'), showImageFlag = false; end
if ieNotDefined('trueSizeFlag'), trueSizeFlag = false; end

%% Make sure file full path is returned and the output is a PNG file

[p,n,e] = fileparts(fName);
if isempty(p), p = pwd; end
if isempty(e), e = '.png'; end
fName = fullfile(p,[n,e]);

% if we've been asked to crop out a black border
if cropFlag, croppedImg = imageCropBorder(img);
else, croppedImg = [];
end

if ~isempty(croppedImg)
    imwrite(croppedImg);
else
    imwrite(img,fName);
end

%% Show or not, true size or not.
if showImageFlag
    imagesc(img);
    if trueSizeFlag, truesize; end
end

end