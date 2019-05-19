function fName = sceneSaveImage(scene,fName)
% Write 8-bit png image approximating appearance of photon data
%
% Syntax:
%   fullpathName = sceneSaveImage(scene,[fullpathname]);
%
% Description:
%  Save out an 8-bit RGB image of the photon image as a png file.  If the
%  name is not passed in, then the user is queried to select the fullpath
%  name of the output file.  This routine is used for scenes.   The image
%  is not displayed.  
%
%  The rgb image is obtained from the scene via sceneShowImage, which uses
%  the same method to render as determined by the parameters in the
%  sceneWindow.
%
% Copyright ImagEval Consultants, LLC, 2003.
%
% See also
%   sceneShowImage, oiSaveImage, imageSPD
%

% Examples:
%{
  % We save the data using the flags in the oiWindow, if it is open.
  % Otherwise, the standard RGB with gam = 1.
  scene = sceneCreate; sceneWindow(scene);
  fName = sceneSaveImage(scene,'deleteMe');   % PNG is appended
  img = imread(fName); ieNewGraphWin; image(img);
  delete(fName);
%}

if ~exist('scene','var') || isempty(scene), scene = ieGetObject('scene'); end

% Get RGB file name (tif)
if ieNotDefined('fName')
    fName = vcSelectDataFile('session','w','png','Image file (png)');
end

gam     = sceneGet(scene,'display gamma');
handles = ieSessionGet('scene handles');
% The negative value means we do not bring up a window to show the image in
% this routine.
if isempty(handles),  displayFlag = -1;
else,                 displayFlag = -1*abs(get(handles.popupDisplay,'Value'));
end

% Scale to max of 1 for output below; needed for gray scale case.
RGB = sceneShowImage(scene,displayFlag,gam);

% Make sure file full path is returned
[p,n,e] = fileparts(fName);
if isempty(p), p = pwd; end
if isempty(e), e = '.png'; end
fName = fullfile(p,[n,e]);

% Always has a png extension.  So, no 'png' argument needed.
% Written out as 8 bit for PNG format.
imwrite(RGB,fName);

% Have a look
%  imagescRGB(RGB);

end