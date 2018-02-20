function fName = sceneSaveImage(scene,fName,gam)
%Write png image approximating appearance of photon data
%
%   fullpathName = sceneSaveImage(scene,[fullpathname],[gam]);
%
% Save out an RGB image of the photon image as a png file.  If the name is
% not passed in, then the user is queried to select the fullpath name of
% the output file.  This routine is used for scenes.  oiSaveImage is used
% for optical images.
%
% The rgb image is obtained from the scene via the call to sceneGet, which
% gets the photons, converts them to an XYZ image, and then converts the
% XYZ image to an sRGB format.  This is the format that is displayed in the
% scene window, and it is the sRGB format that is saved here.
%
% Copyright ImagEval Consultants, LLC, 2003.


if ~exist('scene','var') || isempty(scene), scene = vcGetObject('scene'); end

% Get RGB file name (tif)
if ieNotDefined('fName')
    fName = vcSelectDataFile('session','w','png','Image file (png)');
end

% open window.
if ~exist('gam','var'), RGB = sceneGet(scene,'rgb image');
else                    RGB = sceneGet(scene,'rgb image',gam);
end

imwrite(RGB,fName,'png');


end